import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:path_provider/path_provider.dart';

class DiscoveredDevice {
  final String name;
  final String ip;
  final int port;
  final String platform;

  const DiscoveredDevice({
    required this.name,
    required this.ip,
    required this.port,
    required this.platform,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DiscoveredDevice &&
          runtimeType == other.runtimeType &&
          ip == other.ip &&
          port == other.port;

  @override
  int get hashCode => ip.hashCode ^ port.hashCode;
}

class DiscoverySession {
  final void Function() onCancel;
  DiscoverySession({required this.onCancel});
  void stop() => onCancel();
}

class TransferService {
  static const int defaultPort = 4040;
  static const int fallbackPort = 4041;
  static const int discoveryPort = 4042;

  HttpServer? _server;
  String? _selectedSaveDirectory;
  static String? _customDeviceName;

  RawDatagramSocket? _discoveryResponderSocket;
  Timer? _beaconTimer;

  int _actualPort = defaultPort;
  int get receiverPort => _actualPort;

  String getDeviceName() {
    if (_customDeviceName != null && _customDeviceName!.isNotEmpty) {
      return _customDeviceName!;
    }
    final hostname = Platform.localHostname.trim();
    if (hostname.isNotEmpty && hostname != 'localhost') {
      return hostname;
    }
    if (Platform.isWindows) return 'Windows PC';
    if (Platform.isAndroid) return 'Android Phone';
    if (Platform.isIOS) return 'iPhone';
    if (Platform.isMacOS) return 'Mac';
    if (Platform.isLinux) return 'Linux PC';
    return 'V-Shere Device';
  }

  void setDeviceName(String name) {
    _customDeviceName = name.trim();
  }

  Future<String> getDefaultSaveDirectory() async {
    if (Platform.isAndroid) {
      final directory = await getExternalStorageDirectory();
      if (directory != null) {
        final folder = Directory(
          '${directory.path}${Platform.pathSeparator}V-Shere-Received',
        );
        await folder.create(recursive: true);
        return folder.path;
      }
    }

    final directory = await getApplicationDocumentsDirectory();
    final folder = Directory(
      '${directory.path}${Platform.pathSeparator}V-Shere-Received',
    );
    await folder.create(recursive: true);
    return folder.path;
  }

  void setSaveDirectory(String directory) {
    _selectedSaveDirectory = directory;
  }

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

    try {
      final interfaces = await NetworkInterface.list(
        type: InternetAddressType.IPv4,
        includeLoopback: false,
      );

      for (final interface in interfaces) {
        for (final address in interface.addresses) {
          if (!address.isLoopback &&
              !address.address.startsWith('169.254.')) {
            return address.address;
          }
        }
      }
    } catch (_) {}

    return '127.0.0.1';
  }

  InternetAddress? _getSubnetBroadcast(String ip) {
    try {
      final parts = ip.split('.');
      if (parts.length == 4) {
        return InternetAddress('${parts[0]}.${parts[1]}.${parts[2]}.255');
      }
    } catch (_) {}
    return null;
  }

  Future<void> _startDiscoveryResponder(String localIp) async {
    try {
      _discoveryResponderSocket = await RawDatagramSocket.bind(
        InternetAddress.anyIPv4,
        discoveryPort,
        reuseAddress: true,
        reusePort: false,
      );
      _discoveryResponderSocket?.broadcastEnabled = true;
      _discoveryResponderSocket?.listen((event) {
        if (event == RawSocketEvent.read) {
          final datagram = _discoveryResponderSocket?.receive();
          if (datagram == null) return;
          try {
            final message = utf8.decode(datagram.data).trim();
            if (message.startsWith('V_SHERE_DISCOVER')) {
              final payload = jsonEncode({
                'type': 'V_SHERE_ANNOUNCE',
                'name': getDeviceName(),
                'ip': localIp,
                'port': receiverPort,
                'platform': Platform.operatingSystem,
              });
              final bytes = utf8.encode(payload);

              // Reply directly to sender
              _discoveryResponderSocket?.send(
                bytes,
                datagram.address,
                datagram.port,
              );

              // Also broadcast on discovery port in case direct reply is blocked
              _discoveryResponderSocket?.send(
                bytes,
                InternetAddress('255.255.255.255'),
                discoveryPort,
              );
            }
          } catch (_) {}
        }
      });
    } catch (_) {}
  }

  void _startBeacon(String localIp) {
    _beaconTimer?.cancel();
    _beaconTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      try {
        final payload = jsonEncode({
          'type': 'V_SHERE_ANNOUNCE',
          'name': getDeviceName(),
          'ip': localIp,
          'port': receiverPort,
          'platform': Platform.operatingSystem,
        });
        final bytes = utf8.encode(payload);

        // Broadcast to 255.255.255.255
        _discoveryResponderSocket?.send(
          bytes,
          InternetAddress('255.255.255.255'),
          discoveryPort,
        );

        // Also broadcast to subnet
        final subnet = _getSubnetBroadcast(localIp);
        if (subnet != null) {
          _discoveryResponderSocket?.send(bytes, subnet, discoveryPort);
        }
      } catch (_) {}
    });
  }

  Future<String> startReceiver({
    required Function(String) onFileReceived,
  }) async {
    if (_server != null) {
      return getLocalIp();
    }

    try {
      _server = await HttpServer.bind(
        InternetAddress.anyIPv4,
        defaultPort,
      );
      _actualPort = defaultPort;
    } catch (_) {
      // Fallback if 4040 is in use
      _server = await HttpServer.bind(
        InternetAddress.anyIPv4,
        fallbackPort,
      );
      _actualPort = fallbackPort;
    }

    final localIp = await getLocalIp();
    await _startDiscoveryResponder(localIp);
    _startBeacon(localIp);

    _server!.listen((request) async {
      try {
        if (request.method == 'GET' && request.uri.path == '/health') {
          request.response.statusCode = HttpStatus.ok;
          request.response.headers.contentType = ContentType.json;
          request.response.write(jsonEncode({
            'type': 'V_SHERE_ANNOUNCE',
            'name': getDeviceName(),
            'platform': Platform.operatingSystem,
            'port': receiverPort,
          }));
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
        final safeName = originalName.replaceAll(
          RegExp(r'[\\/:*?"<>|]'),
          '_',
        );
        final fileName =
            '${DateTime.now().microsecondsSinceEpoch}_$safeName';

        final savePath = await getSaveDirectory();
        File outputFile;

        if (Platform.isAndroid && _selectedSaveDirectory != null) {
          try {
            final saveFolder = Directory(savePath);
            await saveFolder.create(recursive: true);
            outputFile = File('$savePath${Platform.pathSeparator}$fileName');
          } catch (_) {
            final defaultPath = await getDefaultSaveDirectory();
            outputFile = File('$defaultPath${Platform.pathSeparator}$fileName');
          }
        } else {
          final saveFolder = Directory(savePath);
          await saveFolder.create(recursive: true);
          outputFile = File('$savePath${Platform.pathSeparator}$fileName');
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

    return localIp;
  }

  Future<void> stopReceiver() async {
    _beaconTimer?.cancel();
    _beaconTimer = null;
    _discoveryResponderSocket?.close();
    _discoveryResponderSocket = null;

    await _server?.close(force: true);
    _server = null;
  }

  DiscoverySession startDiscovery({
    required Function(DiscoveredDevice) onDeviceFound,
  }) {
    RawDatagramSocket? socket;
    Timer? pingTimer;

    void sendPing() async {
      try {
        final localIp = await getLocalIp();
        final bytes = utf8.encode('V_SHERE_DISCOVER');
        socket?.send(bytes, InternetAddress('255.255.255.255'), discoveryPort);
        final subnet = _getSubnetBroadcast(localIp);
        if (subnet != null) {
          socket?.send(bytes, subnet, discoveryPort);
        }
      } catch (_) {}
    }

    RawDatagramSocket.bind(
      InternetAddress.anyIPv4,
      0,
      reuseAddress: true,
      reusePort: false,
    ).then((s) {
      socket = s;
      socket!.broadcastEnabled = true;

      socket!.listen((event) {
        if (event == RawSocketEvent.read) {
          final datagram = socket?.receive();
          if (datagram == null) return;
          try {
            final raw = utf8.decode(datagram.data);
            final data = jsonDecode(raw);
            if (data is Map && data['type'] == 'V_SHERE_ANNOUNCE') {
              final senderIp = datagram.address.address;
              final reportedIp = (data['ip'] as String?)?.trim() ?? senderIp;
              final resolvedIp = (reportedIp.isNotEmpty && reportedIp != '127.0.0.1')
                  ? reportedIp
                  : senderIp;

              // Ensure valid receiver port (4040 / 4041), never ephemeral socket port
              int targetPort = defaultPort;
              if (data['port'] is int && data['port'] > 0 && data['port'] < 65535) {
                final p = data['port'] as int;
                if (p == defaultPort || p == fallbackPort || p < 10000) {
                  targetPort = p;
                }
              }

              final device = DiscoveredDevice(
                name: (data['name'] as String?) ?? 'Unknown Device',
                ip: resolvedIp,
                port: targetPort,
                platform: (data['platform'] as String?) ?? '',
              );
              onDeviceFound(device);
            }
          } catch (_) {}
        }
      });

      sendPing();
      pingTimer = Timer.periodic(const Duration(seconds: 2), (_) => sendPing());
    }).catchError((_) {});

    bool cancelled = false;
    _scanSubnetHttp(onDeviceFound, () => cancelled);

    return DiscoverySession(
      onCancel: () {
        cancelled = true;
        pingTimer?.cancel();
        socket?.close();
      },
    );
  }

  Future<void> _scanSubnetHttp(
    Function(DiscoveredDevice) onDeviceFound,
    bool Function() isCancelled,
  ) async {
    try {
      final localIp = await getLocalIp();
      if (localIp == '127.0.0.1') return;
      final parts = localIp.split('.');
      if (parts.length != 4) return;
      final prefix = '${parts[0]}.${parts[1]}.${parts[2]}';
      final myOctet = int.tryParse(parts[3]) ?? 0;

      final client = HttpClient()
        ..connectionTimeout = const Duration(milliseconds: 900);

      const chunkSize = 30;
      for (int i = 1; i <= 254; i += chunkSize) {
        if (isCancelled()) break;
        final futures = <Future>[];
        for (int j = i; j < i + chunkSize && j <= 254; j++) {
          if (j == myOctet) continue;
          final targetIp = '$prefix.$j';
          futures.add(() async {
            if (isCancelled()) return;
            for (final port in [defaultPort, fallbackPort]) {
              try {
                final uri = Uri.parse('http://$targetIp:$port/health');
                final request = await client.getUrl(uri);
                final response = await request.close();
                if (response.statusCode == HttpStatus.ok) {
                  final text = await response.transform(utf8.decoder).join();
                  try {
                    final data = jsonDecode(text);
                    if (data is Map && data['type'] == 'V_SHERE_ANNOUNCE') {
                      onDeviceFound(DiscoveredDevice(
                        name: (data['name'] as String?) ?? 'Device ($targetIp)',
                        ip: targetIp,
                        port: (data['port'] as int?) ?? port,
                        platform: (data['platform'] as String?) ?? '',
                      ));
                      return;
                    }
                  } catch (_) {
                    if (text.contains('V-Shere')) {
                      onDeviceFound(DiscoveredDevice(
                        name: 'Device ($targetIp)',
                        ip: targetIp,
                        port: port,
                        platform: '',
                      ));
                      return;
                    }
                  }
                }
              } catch (_) {}
            }
          }());
        }
        await Future.wait(futures);
      }
      client.close(force: true);
    } catch (_) {}
  }

  Future<DiscoveredDevice?> resolveTargetDevice(
    String input,
    List<DiscoveredDevice> discovered,
  ) async {
    final trimmed = input.trim();
    if (trimmed.isEmpty) return null;

    // 1. Check if matches any discovered device by name or IP
    for (final device in discovered) {
      if (device.name.toLowerCase() == trimmed.toLowerCase() ||
          device.ip == trimmed) {
        return device;
      }
    }

    // 2. Check if valid IPv4 format
    final ipRegex = RegExp(r'^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$');
    if (ipRegex.hasMatch(trimmed)) {
      return DiscoveredDevice(
        name: trimmed,
        ip: trimmed,
        port: defaultPort,
        platform: '',
      );
    }

    // 3. Try DNS / hostname lookup
    try {
      final addresses = await InternetAddress.lookup(trimmed);
      for (final addr in addresses) {
        if (addr.type == InternetAddressType.IPv4) {
          return DiscoveredDevice(
            name: trimmed,
            ip: addr.address,
            port: defaultPort,
            platform: '',
          );
        }
      }
    } catch (_) {}

    return null;
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

    // List of ports to attempt (primary port first, fallback port next)
    final portsToTry = <int>[receiverPort];
    if (receiverPort == defaultPort) {
      portsToTry.add(fallbackPort);
    } else if (receiverPort == fallbackPort) {
      portsToTry.add(defaultPort);
    } else {
      portsToTry.add(defaultPort);
      portsToTry.add(fallbackPort);
    }

    Object? lastError;

    for (final port in portsToTry) {
      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 8);

      try {
        final uri = Uri(
          scheme: 'http',
          host: receiverIp,
          port: port,
          path: '/upload',
          queryParameters: {
            'name': file.name,
          },
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

        // Succeeded!
        return;
      } on SocketException catch (e) {
        lastError = e;
        // If connection refused, try next port in list
        continue;
      } finally {
        client.close(force: true);
      }
    }

    throw lastError ?? Exception('Could not connect to $receiverIp on port $receiverPort');
  }
}
