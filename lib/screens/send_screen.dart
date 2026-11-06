import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

import '../services/transfer_service.dart';
import '../services/discovery_service.dart';

class SendScreen extends StatefulWidget {
  const SendScreen({super.key});

  @override
  State<SendScreen> createState() => _SendScreenState();
}

class _SendScreenState extends State<SendScreen> {
  final ipController = TextEditingController();
  final portController = TextEditingController(text: '4040');

  final service = TransferService();
  final discoveryService = DiscoveryService();

  List<PlatformFile> selectedFiles = [];
  List<DiscoveredDevice> discoveredDevices = [];

  bool sending = false;
  bool discovering = true;
  bool showManualEntry = false;

  String status = 'Searching for devices...';

  @override
  void initState() {
    super.initState();
    startDiscovery();
  }

  Future<void> startDiscovery() async {
    setState(() {
      discovering = true;
      status = 'Searching for devices...';
    });

    await discoveryService.startDiscovery();

    discoveryService.devicesStream.listen((devices) {
      if (!mounted) return;

      setState(() {
        discoveredDevices = devices;
        if (devices.isEmpty) {
          status = 'No devices found. Make sure receiver is running.';
        } else {
          status = '${devices.length} device(s) found';
        }
      });
    });
  }

  Future<void> pickFiles() async {
    final result = await FilePicker.pickFiles(
      allowMultiple: true,
      withData: false,
    );

    if (result != null) {
      setState(() {
        selectedFiles = result.files;
        if (!showManualEntry) {
          status = '${selectedFiles.length} file(s) selected';
        }
      });
    }
  }

  Future<void> sendToDevice(DiscoveredDevice device) async {
    if (selectedFiles.isEmpty) {
      setState(() => status = 'Please choose files first');
      return;
    }

    setState(() {
      sending = true;
      status = 'Preparing transfer...';
    });

    try {
      for (int i = 0; i < selectedFiles.length; i++) {
        final file = selectedFiles[i];

        setState(() {
          status = 'Sending ${i + 1}/${selectedFiles.length}: ${file.name}';
        });

        await service.sendFile(
          receiverIp: device.ip,
          receiverPort: device.port,
          file: file,
        );
      }

      setState(() {
        status = 'All files sent successfully!';
      });
    } catch (error) {
      setState(() {
        status = 'Transfer failed: $error';
      });
    } finally {
      setState(() {
        sending = false;
      });
    }
  }

  Future<void> sendFilesManual() async {
    final ip = ipController.text.trim();
    final port = int.tryParse(portController.text.trim());

    if (ip.isEmpty) {
      setState(() => status = 'Enter receiver IP address');
      return;
    }

    if (port == null || port < 1 || port > 65535) {
      setState(() => status = 'Enter a valid port number');
      return;
    }

    if (selectedFiles.isEmpty) {
      setState(() => status = 'Please choose files first');
      return;
    }

    setState(() {
      sending = true;
      status = 'Preparing transfer...';
    });

    try {
      for (int i = 0; i < selectedFiles.length; i++) {
        final file = selectedFiles[i];

        setState(() {
          status = 'Sending ${i + 1}/${selectedFiles.length}: ${file.name}';
        });

        await service.sendFile(
          receiverIp: ip,
          receiverPort: port,
          file: file,
        );
      }

      setState(() {
        status = 'All files sent successfully!';
      });
    } catch (error) {
      setState(() {
        status = 'Transfer failed: $error';
      });
    } finally {
      setState(() {
        sending = false;
      });
    }
  }

  @override
  void dispose() {
    ipController.dispose();
    portController.dispose();
    discoveryService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Send Files'),
        actions: [
          IconButton(
            icon: Icon(showManualEntry ? Icons.devices : Icons.edit),
            onPressed: () {
              setState(() {
                showManualEntry = !showManualEntry;
                if (showManualEntry) {
                  status = 'Manual IP entry mode';
                } else {
                  status = discoveredDevices.isEmpty
                      ? 'No devices found'
                      : '${discoveredDevices.length} device(s) found';
                }
              });
            },
            tooltip: showManualEntry ? 'Show Devices' : 'Manual Entry',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              discoveredDevices.clear();
              startDiscovery();
            },
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Choose Files Button
            SizedBox(
              width: double.infinity,
              height: 55,
              child: OutlinedButton.icon(
                onPressed: sending ? null : pickFiles,
                icon: const Icon(Icons.attach_file),
                label: Text(
                  selectedFiles.isEmpty
                      ? 'Choose Files'
                      : '${selectedFiles.length} file(s) selected',
                ),
              ),
            ),

            const SizedBox(height: 15),

            // Status
            Text(
              status,
              style: const TextStyle(color: Colors.white70),
            ),

            const SizedBox(height: 18),

            // Show either device list or manual entry
            if (showManualEntry) ...[
              // Manual IP Entry
              const Text('Receiver IP Address'),
              const SizedBox(height: 10),
              TextField(
                controller: ipController,
                keyboardType: TextInputType.url,
                decoration: InputDecoration(
                  hintText: 'Example: 192.168.1.100',
                  prefixIcon: const Icon(Icons.wifi),
                  filled: true,
                  fillColor: const Color(0xFF171F35),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              const Text('Receiver Port'),
              const SizedBox(height: 10),
              TextField(
                controller: portController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: '4040',
                  prefixIcon: const Icon(Icons.settings_ethernet),
                  filled: true,
                  fillColor: const Color(0xFF171F35),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton.icon(
                  onPressed: sending ? null : sendFilesManual,
                  icon: sending
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.send),
                  label: Text(sending ? 'Sending...' : 'Send Now'),
                ),
              ),
            ] else ...[
              // Device List
              const Text(
                'Available Devices',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: discoveredDevices.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (discovering)
                              const CircularProgressIndicator()
                            else
                              const Icon(
                                Icons.devices_other,
                                size: 64,
                                color: Colors.white24,
                              ),
                            const SizedBox(height: 16),
                            Text(
                              discovering
                                  ? 'Searching for devices...'
                                  : 'No devices found',
                              style: const TextStyle(color: Colors.white54),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Make sure the receiver is running\nand on the same Wi-Fi network',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white38,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: discoveredDevices.length,
                        itemBuilder: (context, index) {
                          final device = discoveredDevices[index];

                          IconData platformIcon;
                          Color platformColor;

                          switch (device.platform.toLowerCase()) {
                            case 'android':
                              platformIcon = Icons.android;
                              platformColor = Colors.greenAccent;
                              break;
                            case 'ios':
                              platformIcon = Icons.apple;
                              platformColor = Colors.white;
                              break;
                            case 'windows':
                              platformIcon = Icons.computer;
                              platformColor = Colors.blueAccent;
                              break;
                            default:
                              platformIcon = Icons.devices;
                              platformColor = Colors.grey;
                          }

                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              leading: Icon(
                                platformIcon,
                                color: platformColor,
                                size: 32,
                              ),
                              title: Text(
                                device.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                '${device.ip}:${device.port} • ${device.platform}',
                                style: const TextStyle(fontSize: 12),
                              ),
                              trailing: sending
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Icon(Icons.arrow_forward_ios, size: 16),
                              onTap: sending ? null : () => sendToDevice(device),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
