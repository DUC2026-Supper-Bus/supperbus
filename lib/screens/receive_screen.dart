import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';

import '../services/transfer_service.dart';

class ReceiveScreen extends StatefulWidget {
  const ReceiveScreen({super.key});

  @override
  State<ReceiveScreen> createState() => _ReceiveScreenState();
}

class _ReceiveScreenState extends State<ReceiveScreen> {
  final service = TransferService();

  String ipAddress = '';
  String status = 'Receiver is not running';
  String saveDirectory = 'Loading folder...';

  bool isRunning = false;

  final List<String> receivedFiles = [];

  @override
  void initState() {
    super.initState();
    loadSaveDirectory();
  }

  Future<void> loadSaveDirectory() async {
    final path = await service.getSaveDirectory();

    if (!mounted) return;

    setState(() {
      saveDirectory = path;
    });
  }

  // Let the user choose a destination folder.
  Future<void> chooseSaveFolder() async {
    try {
      // On Android, use app-specific external storage only
      // to avoid permission issues with scoped storage
      if (Platform.isAndroid) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('On Android, files are saved to app storage folder'),
            duration: Duration(seconds: 3),
          ),
        );
        return;
      }

      final selectedDirectory = await FilePicker.getDirectoryPath();

      if (selectedDirectory == null) return;

      final directory = Directory(selectedDirectory);

      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }

      service.setSaveDirectory(selectedDirectory);

      if (!mounted) return;

      setState(() {
        saveDirectory = selectedDirectory;
        status = 'Save location updated';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Save folder updated successfully'),
        ),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not select folder: $error'),
        ),
      );
    }
  }

  Future<void> startReceiving() async {
    setState(() {
      status = 'Starting receiver...';
    });

    try {
      final ip = await service.startReceiver(
        onFileReceived: (fileName) {
          if (!mounted) return;

          setState(() {
            receivedFiles.insert(0, fileName);
            status = 'Received: $fileName';
          });
        },
      );

      if (!mounted) return;

      setState(() {
        ipAddress = ip;
        isRunning = true;
        status = 'Ready to receive files';
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        status = 'Error: $error';
        isRunning = false;
      });
    }
  }

  Future<void> stopReceiving() async {
    await service.stopReceiver();

    if (!mounted) return;

    setState(() {
      isRunning = false;
      status = 'Receiver stopped';
      ipAddress = '';
    });
  }

  Future<void> copyIp() async {
    await Clipboard.setData(
      ClipboardData(text: ipAddress),
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('IP address copied')),
    );
  }

  @override
  void dispose() {
    service.stopReceiver();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Receive Files'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 10),

            Container(
              height: 75,
              width: 75,
              decoration: BoxDecoration(
                color: Colors.greenAccent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(
                Icons.wifi,
                size: 40,
                color: Colors.greenAccent,
              ),
            ),

            const SizedBox(height: 12),

            const Text(
              'Ready to receive?',
              style: TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              status,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white60),
            ),

            const SizedBox(height: 16),

            // Save location card.
            Card(
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.folder,
                          color: Color(0xFF00D9FF),
                        ),
                        SizedBox(width: 10),
                        Text(
                          'SAVE LOCATION',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    SelectableText(
                      saveDirectory,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white70,
                      ),
                    ),

                    const SizedBox(height: 12),

                    SizedBox(
                      width: double.infinity,
                      child: Platform.isAndroid
                          ? OutlinedButton.icon(
                              onPressed: null, // Disabled on Android
                              icon: const Icon(Icons.info_outline),
                              label: const Text('Android uses app storage'),
                            )
                          : OutlinedButton.icon(
                              onPressed: chooseSaveFolder,
                              icon: const Icon(Icons.folder_open),
                              label: const Text('Choose Save Folder'),
                            ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            if (isRunning)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    children: [
                      const Text(
                        'YOUR IP ADDRESS',
                        style: TextStyle(
                          color: Colors.white60,
                          letterSpacing: 1,
                        ),
                      ),

                      const SizedBox(height: 8),

                      SelectableText(
                        ipAddress,
                        style: const TextStyle(
                          fontSize: 23,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF00D9FF),
                        ),
                      ),

                      TextButton.icon(
                        onPressed: copyIp,
                        icon: const Icon(Icons.copy),
                        label: const Text('Copy IP Address'),
                      ),

                      Text('Port: ${service.receiverPort}'),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: isRunning
                    ? stopReceiving
                    : startReceiving,
                icon: Icon(
                  isRunning ? Icons.stop : Icons.wifi,
                ),
                label: Text(
                  isRunning ? 'Stop Receiving' : 'Start Receiving',
                ),
              ),
            ),

            const SizedBox(height: 16),

            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Received Files',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 8),

            Expanded(
              child: receivedFiles.isEmpty
                  ? const Center(
                      child: Text(
                        'No files received yet',
                        style: TextStyle(color: Colors.white54),
                      ),
                    )
                  : ListView.builder(
                      itemCount: receivedFiles.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          leading: const Icon(
                            Icons.check_circle,
                            color: Colors.greenAccent,
                          ),
                          title: Text(
                            receivedFiles[index],
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
