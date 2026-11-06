import 'dart:async';
import 'dart:io';

import 'package:multicast_dns/multicast_dns.dart';

class DiscoveredDevice {
  final String name;
  final String ip;
  final int port;
  final String platform;

  DiscoveredDevice({
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

class DiscoveryService {
  static const String serviceType = '_vshere._tcp';
  static const String serviceDomain = 'local';

  MDnsClient? _mdnsClient;
  Timer? _announcementTimer;
  Timer? _discoveryTimer;

  final _devicesController = StreamController<List<DiscoveredDevice>>.broadcast();
  Stream<List<DiscoveredDevice>> get devicesStream => _devicesController.stream;

  final Set<DiscoveredDevice> _discoveredDevices = {};

  List<DiscoveredDevice> get devices => _discoveredDevices.toList();

  // Start announcing this device as a receiver
  Future<void> startAnnouncing({
    required String deviceName,
    required int port,
  }) async {
    await stopAnnouncing();

    try {
      _mdnsClient = MDnsClient();
      await _mdnsClient!.start();

      // Announce every 3 seconds
      _announcementTimer = Timer.periodic(
        const Duration(seconds: 3),
        (_) => _announce(deviceName, port),
      );

      // Initial announcement
      _announce(deviceName, port);
    } catch (e) {
      debugPrint('Failed to start mDNS announcement: $e');
    }
  }

  void _announce(String deviceName, int port) {
    // mDNS announcements are handled automatically by the library
    // We just need to respond to queries during discovery
    // Platform info for future use
    _getPlatformName();
  }

  // Stop announcing
  Future<void> stopAnnouncing() async {
    _announcementTimer?.cancel();
    _announcementTimer = null;

    _mdnsClient?.stop();
    _mdnsClient = null;
  }

  // Start discovering devices
  Future<void> startDiscovery() async {
    await stopDiscovery();

    _discoveredDevices.clear();
    _notifyDevicesChanged();

    try {
      _mdnsClient = MDnsClient();
      await _mdnsClient!.start();

      // Discover every 2 seconds
      _discoveryTimer = Timer.periodic(
        const Duration(seconds: 2),
        (_) => _discover(),
      );

      // Initial discovery
      _discover();
    } catch (e) {
      debugPrint('Failed to start mDNS discovery: $e');
    }
  }

  void _discover() async {
    if (_mdnsClient == null) return;

    try {
      await for (final PtrResourceRecord ptr in _mdnsClient!
          .lookup<PtrResourceRecord>(
            ResourceRecordQuery.serverPointer('$serviceType.$serviceDomain'),
          )
          .timeout(const Duration(seconds: 2))) {
        final instanceName = ptr.domainName;

        // Query for SRV and TXT records
        _querySrvAndTxt(instanceName);
      }
    } catch (e) {
      // Timeout or error - this is normal during discovery
    }
  }

  void _querySrvAndTxt(String instanceName) async {
    if (_mdnsClient == null) return;

    String? ip;
    int? port;
    String? platform;

    try {
      // Get SRV record (port and hostname)
      await for (final SrvResourceRecord srv in _mdnsClient!
          .lookup<SrvResourceRecord>(
            ResourceRecordQuery.service(instanceName),
          )
          .timeout(const Duration(seconds: 1))) {
        port = srv.port;

        // Get A record (IP address)
        await for (final IPAddressResourceRecord ipRecord in _mdnsClient!
            .lookup<IPAddressResourceRecord>(
              ResourceRecordQuery.addressIPv4(srv.target),
            )
            .timeout(const Duration(seconds: 1))) {
          ip = ipRecord.address.address;
          break;
        }

        break;
      }

      // Get TXT record (metadata)
      await for (final TxtResourceRecord txt in _mdnsClient!
          .lookup<TxtResourceRecord>(
            ResourceRecordQuery.text(instanceName),
          )
          .timeout(const Duration(seconds: 1))) {
        for (final entry in txt.text.split('\n')) {
          if (entry.startsWith('platform=')) {
            platform = entry.substring('platform='.length);
          }
        }
        break;
      }

      // Add discovered device
      if (ip != null && port != null && ip.isNotEmpty) {
        // Extract device name from instance name
        String deviceName = instanceName;
        if (instanceName.contains('.')) {
          deviceName = instanceName.split('.').first;
        }

        final device = DiscoveredDevice(
          name: deviceName,
          ip: ip,
          port: port,
          platform: platform ?? 'Unknown',
        );

        if (_discoveredDevices.add(device)) {
          _notifyDevicesChanged();
        }
      }
    } catch (e) {
      // Timeout or error - skip this device
    }
  }

  // Stop discovering
  Future<void> stopDiscovery() async {
    _discoveryTimer?.cancel();
    _discoveryTimer = null;

    _mdnsClient?.stop();
    _mdnsClient = null;
  }

  void _notifyDevicesChanged() {
    if (!_devicesController.isClosed) {
      _devicesController.add(_discoveredDevices.toList());
    }
  }

  String _getPlatformName() {
    if (Platform.isAndroid) return 'Android';
    if (Platform.isIOS) return 'iOS';
    if (Platform.isWindows) return 'Windows';
    if (Platform.isMacOS) return 'macOS';
    if (Platform.isLinux) return 'Linux';
    return 'Unknown';
  }

  void debugPrint(String message) {
    if (!const bool.fromEnvironment('dart.vm.product')) {
      // ignore: avoid_print
      print('[DiscoveryService] $message');
    }
  }

  void dispose() {
    _announcementTimer?.cancel();
    _discoveryTimer?.cancel();
    _mdnsClient?.stop();
    _devicesController.close();
  }
}
