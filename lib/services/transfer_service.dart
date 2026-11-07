import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:path_provider/path_provider.dart';

class DiscoveredDevice {
  const DiscoveredDevice({
    required this.name,
    required this.ip,
    required this.port,
    required this.platform,
  });

  final String name;
  final String ip;
  final int port;
  final String platform;
}

class DiscoverySession {
  DiscoverySession(this._socket, this._timer);

  final RawDatagramSocket _socket;
  final Timer _timer;
  bool _stopped = false;

  void stop() {
    if (_stopped) return;
    _stopped = true;
    _timer.cancel();
    _socket.close();
  }
}

class TransferService {
  static const int androidPort = 4040;
  static const int windowsPort = 4041;
  static const int discoveryPort = 4042;

  HttpServer? _server;
  RawDatagramSocket? _discoveryResponder;
  String? _selectedSaveDirectory;

  int get receiverPort {
    return Platform.isWindows ? windowsPort : androidPort;
  }

  String get _platformName {
    if (Platform.isWindows) return 'Windows';
    if (Platform.isAndroid) return 'Android';
    if (Platform.isIOS) return 'iOS';
    if (Platform.isMacOS) return 'macOS';
    if (Platform.isLinux) return 'Linux';
    return 'Unknown';
  }

  Future<DiscoverySession> startDiscovery({
    required void Function(DiscoveredDevice device) onDeviceFound,
  }) async {
    final socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);
    socket.broadcastEnabled = true;

    void scan() {
      final query = utf8.encode('V_SHERE_DISCOVER');
      socket.send(query, InternetAddress('255.255.255.255'), discoveryPort);
    }

    socket.listen((event) {
      if (event != RawSocketEvent.read) return;

      Datagram? datagram;
      while ((datagram = socket.receive()) != null) {
        try {
          final data = jsonDecode(utf8.decode(datagram!.data));
          if (data is! Map<String, dynamic> || data['service'] != 'v-shere') {
            continue;
          }

          final ip = data['ip'];
          final name = data['name'];
          final port = data['port'];
          final platform = data['platform'];
          if (ip is! String ||
              name is! String ||
              port is! int ||
              platform is! String) {
            continue;
          }

          onDeviceFound(
            DiscoveredDevice(
              name: name,
              ip: ip,
              port: port,
              platform: platform,
            ),
          );
        } on FormatException {
          // Ignore unrelated UDP packets.
        }
      }
    });

    scan();
    final timer = Timer.periodic(const Duration(seconds: 3), (_) => scan());
    return DiscoverySession(socket, timer);
  }

  Future<DiscoveredDevice?> resolveTargetDevice(
    String target,
    List<DiscoveredDevice> devices,
  ) async {
    final normalizedTarget = target.toLowerCase();
    for (final device in devices) {
      if (device.name.toLowerCase() == normalizedTarget ||
          device.ip.toLowerCase() == normalizedTarget) {
        return device;
      }
    }

    final parsedAddress = InternetAddress.tryParse(target);
    if (parsedAddress != null) {
      return DiscoveredDevice(
        name: target,
        ip: target,
        port: androidPort,
        platform: 'Unknown',
      );
    }

    return null;
  }

  // Default folder when the user hasn't selected one.
  Future<String> getDefaultSaveDirectory() async {
    if (Platform.isAndroid) {
      // Use app-specific external storage (doesn't require permissions)
      final directory = await getExternalStorageDirectory();
      if (directory != null) {
        final folder = Directory(
          '${directory.path}${Platform.pathSeparator}V-Shere-Received',
        );
        await folder.create(recursive: true);
        return folder.path;
      }
    }

    // Fallback for other platforms or if external storage fails
    final directory = await getApplicationDocumentsDirectory();

    final folder = Directory(
      '${directory.path}${Platform.pathSeparator}V-Shere-Received',
    );

    await folder.create(recursive: true);
    return folder.path;
  }

  // Set the folder selected by the user.
  void setSaveDirectory(String directory) {
    _selectedSaveDirectory = directory;
  }

  // Return the current folder.
  Future<String> getSaveDirectory() async {
    return _selectedSaveDirectory ?? await getDefaultSaveDirectory();
  }

  Future<String> getLocalIp() async {
    try {
      final ip = await NetworkInfo().getWifiIP();

      if (ip != null && ip.isNotEmpty) {
        return ip;
      }
    } catch (_) {}

    final interfaces = await NetworkInterface.list(
      type: InternetAddressType.IPv4,
      includeLoopback: false,
    );

    for (final interface in interfaces) {
      for (final address in interface.addresses) {
        if (!address.isLoopback && !address.address.startsWith('169.254.')) {
          return address.address;
        }
      }
    }

    return '127.0.0.1';
  }

  Future<String> startReceiver({
    required Function(String) onFileReceived,
  }) async {
    if (_server != null) {
      return getLocalIp();
    }

    _server = await HttpServer.bind(InternetAddress.anyIPv4, receiverPort);
    await _startDiscoveryResponder();

    _server!.listen((request) async {
      try {
        if (request.method == 'GET' && request.uri.path == '/health') {
          request.response.statusCode = HttpStatus.ok;
          request.response.write('V-Shere is ready');
          await request.response.close();
          return;
        }

        if (request.method != 'POST' || request.uri.path != '/upload') {
          request.response.statusCode = HttpStatus.notFound;
          await request.response.close();
          return;
        }

        final originalName =
            request.uri.queryParameters['name'] ?? 'received_file';

        final safeName = originalName.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');

        final fileName = '${DateTime.now().microsecondsSinceEpoch}_$safeName';

        // Get the latest save directory (allows changing while receiving)
        final savePath = await getSaveDirectory();

        File outputFile;

        // Check if we're using SAF-managed directory (Android custom folder)
        if (Platform.isAndroid && _selectedSaveDirectory != null) {
          // For SAF directories, use a safer write method
          try {
            final saveFolder = Directory(savePath);
            await saveFolder.create(recursive: true);

            final filePath = '$savePath${Platform.pathSeparator}$fileName';
            outputFile = File(filePath);
          } catch (e) {
            // If SAF folder fails, fall back to default
            final defaultPath = await getDefaultSaveDirectory();
            final filePath = '$defaultPath${Platform.pathSeparator}$fileName';
            outputFile = File(filePath);
          }
        } else {
          // Non-Android or default folder
          final saveFolder = Directory(savePath);
          await saveFolder.create(recursive: true);

          final filePath = '$savePath${Platform.pathSeparator}$fileName';
          outputFile = File(filePath);
        }

        final sink = outputFile.openWrite();

        await sink.addStream(request);
        await sink.flush();
        await sink.close();

        onFileReceived(fileName);

        request.response.statusCode = HttpStatus.ok;
        request.response.write('File received successfully');

        await request.response.close();
      } catch (error) {
        request.response.statusCode = HttpStatus.internalServerError;

        request.response.write('Receive failed: $error');

        try {
          await request.response.close();
        } catch (_) {}
      }
    });

    return getLocalIp();
  }

  Future<void> stopReceiver() async {
    _discoveryResponder?.close();
    _discoveryResponder = null;
    await _server?.close(force: true);
    _server = null;
  }

  Future<void> _startDiscoveryResponder() async {
    _discoveryResponder = await RawDatagramSocket.bind(
      InternetAddress.anyIPv4,
      discoveryPort,
      reuseAddress: true,
    );
    final ip = await getLocalIp();
    _discoveryResponder!.listen((event) {
      if (event != RawSocketEvent.read) return;

      Datagram? datagram;
      while ((datagram = _discoveryResponder!.receive()) != null) {
        if (utf8.decode(datagram!.data, allowMalformed: true) !=
            'V_SHERE_DISCOVER') {
          continue;
        }

        final response = utf8.encode(
          jsonEncode({
            'service': 'v-shere',
            'name': Platform.localHostname,
            'ip': ip,
            'port': receiverPort,
            'platform': _platformName,
          }),
        );
        _discoveryResponder!.send(response, datagram.address, datagram.port);
      }
    });
  }

  Future<void> sendFile({
    required String receiverIp,
    required int receiverPort,
    required PlatformFile file,
  }) async {
    if (file.path == null) {
      throw Exception('Cannot access ${file.name}');
    }

    final sourceFile = File(file.path!);

    if (!await sourceFile.exists()) {
      throw Exception('File does not exist: ${file.name}');
    }

    final client = HttpClient();
    client.connectionTimeout = const Duration(seconds: 15);

    try {
      final uri = Uri(
        scheme: 'http',
        host: receiverIp,
        port: receiverPort,
        path: '/upload',
        queryParameters: {'name': file.name},
      );

      final request = await client.postUrl(uri);
      request.contentLength = await sourceFile.length();

      await request.addStream(sourceFile.openRead());

      final response = await request.close();

      final responseText = await response.transform(utf8.decoder).join();

      if (response.statusCode != HttpStatus.ok) {
        throw Exception(
          responseText.isEmpty ? 'Transfer failed' : responseText,
        );
      }
    } finally {
      client.close(force: true);
    }
  }
}
