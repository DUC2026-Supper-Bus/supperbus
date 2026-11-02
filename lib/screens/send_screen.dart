import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

import '../services/transfer_service.dart';

class SendScreen extends StatefulWidget {
  const SendScreen({super.key});

  @override
  State<SendScreen> createState() => _SendScreenState();
}

class _SendScreenState extends State<SendScreen> {
  final ipController = TextEditingController();
  final portController = TextEditingController(text: '4040');

  final service = TransferService();

  List<PlatformFile> selectedFiles = [];

  bool sending = false;

  String status = 'Select files to begin';

  Future<void> pickFiles() async {
    final result = await FilePicker.pickFiles(
      allowMultiple: true,
      withData: false,
    );

    if (result != null) {
      setState(() {
        selectedFiles = result.files;
        status = '${selectedFiles.length} file(s) selected';
      });
    }
  }

  Future<void> sendFiles() async {
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
          status =
              'Sending ${i + 1}/${selectedFiles.length}: ${file.name}';
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Send Files')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
              child: OutlinedButton.icon(
                onPressed: sending ? null : pickFiles,
                icon: const Icon(Icons.attach_file),
                label: const Text('Choose Files'),
              ),
            ),

            const SizedBox(height: 15),

            Expanded(
              child: selectedFiles.isEmpty
                  ? const Center(
                      child: Text(
                        'No files selected',
                        style: TextStyle(color: Colors.white54),
                      ),
                    )
                  : ListView.builder(
                      itemCount: selectedFiles.length,
                      itemBuilder: (context, index) {
                        final file = selectedFiles[index];

                        return Card(
                          child: ListTile(
                            leading: const Icon(
                              Icons.insert_drive_file,
                              color: Color(0xFF00D9FF),
                            ),
                            title: Text(
                              file.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Text(
                              '${(file.size / 1024 / 1024).toStringAsFixed(2)} MB',
                            ),
                          ),
                        );
                      },
                    ),
            ),

            Text(
              status,
              style: const TextStyle(color: Colors.white70),
            ),

            const SizedBox(height: 15),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: sending ? null : sendFiles,
                icon: sending
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.send),
                label: Text(sending ? 'Sending...' : 'Send Now'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
