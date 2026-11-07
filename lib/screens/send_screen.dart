import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

import '../services/transfer_service.dart';

class SendScreen extends StatefulWidget {
  const SendScreen({super.key});

  @override
  State<SendScreen> createState() => _SendScreenState();
}

class _SendScreenState extends State<SendScreen> {
  final deviceController = TextEditingController();
  final portController = TextEditingController(text: '4040');

  final service = TransferService();

  List<PlatformFile> selectedFiles = [];
  bool sending = false;
  double transferProgress = 0.0;
  String status = '';

  List<DiscoveredDevice> discoveredDevices = [];
  DiscoverySession? discoverySession;
  DiscoveredDevice? selectedDevice;
  bool showPortField = false;

  @override
  void initState() {
    super.initState();
    startScanning();
  }

  Future<void> startScanning() async {
    discoverySession?.stop();
    final session = await service.startDiscovery(
      onDeviceFound: (device) {
        if (!mounted) return;
        setState(() {
          final index = discoveredDevices.indexWhere(
            (d) => d.ip == device.ip && d.port == device.port,
          );
          if (index >= 0) {
            discoveredDevices[index] = device;
          } else {
            discoveredDevices.add(device);
          }
        });
      },
    );
    if (!mounted) {
      session.stop();
      return;
    }
    discoverySession = session;
  }

  void selectDevice(DiscoveredDevice device) {
    setState(() {
      selectedDevice = device;
      deviceController.text = device.name;
      portController.text = device.port.toString();
      status = '✓ Connected to ${device.name}';
    });
  }

  Future<void> pickFiles() async {
    final result = await FilePicker.pickFiles(
      allowMultiple: true,
      withData: false,
    );

    if (result != null) {
      setState(() {
        selectedFiles = [...selectedFiles, ...result.files];
        final seen = <String>{};
        selectedFiles = selectedFiles.where((f) {
          if (f.path == null) return true;
          return seen.add(f.path!);
        }).toList();
      });
    }
  }

  void removeFile(int index) {
    setState(() {
      selectedFiles.removeAt(index);
    });
  }

  String _formatBytes(int bytes) {
    if (bytes <= 0) return '0 B';
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  Future<void> sendFiles() async {
    final target = deviceController.text.trim();
    final port = int.tryParse(portController.text.trim());

    if (target.isEmpty) {
      setState(() => status = '⚠ Please choose a receiver device');
      return;
    }
    if (port == null || port < 1 || port > 65535) {
      setState(() => status = '⚠ Invalid port number');
      return;
    }
    if (selectedFiles.isEmpty) {
      setState(() => status = '⚠ Please choose at least one file');
      return;
    }

    setState(() {
      sending = true;
      transferProgress = 0.0;
      status = 'Finding device...';
    });

    final targetDevice = await service.resolveTargetDevice(
      target,
      discoveredDevices,
    );

    if (targetDevice == null) {
      setState(() {
        sending = false;
        status = '✗ Device "$target" not found';
      });
      return;
    }

    final targetIp = targetDevice.ip;
    final targetPort =
        (selectedDevice != null && selectedDevice!.name == target)
        ? selectedDevice!.port
        : port;

    try {
      for (int i = 0; i < selectedFiles.length; i++) {
        final file = selectedFiles[i];
        setState(() {
          transferProgress = (i + 1) / selectedFiles.length;
          status = 'Sending ${i + 1}/${selectedFiles.length}: ${file.name}';
        });

        await service.sendFile(
          receiverIp: targetIp,
          receiverPort: targetPort,
          file: file,
        );
      }

      setState(() {
        status = '✓ All files sent successfully!';
        transferProgress = 1.0;
      });
    } catch (error) {
      setState(() => status = '✗ $error');
    } finally {
      setState(() => sending = false);
    }
  }

  @override
  void dispose() {
    discoverySession?.stop();
    deviceController.dispose();
    portController.dispose();
    super.dispose();
  }

  IconData _getPlatformIcon(String platform) {
    final p = platform.toLowerCase();
    if (p.contains('win')) return Icons.laptop_windows_rounded;
    if (p.contains('android')) return Icons.phone_android_rounded;
    if (p.contains('ios')) return Icons.phone_iphone_rounded;
    if (p.contains('mac')) return Icons.laptop_mac_rounded;
    if (p.contains('linux')) return Icons.terminal_rounded;
    return Icons.devices_rounded;
  }

  Color _getFileColor(String name) {
    final ext = name.split('.').last.toLowerCase();
    switch (ext) {
      case 'pdf':
        return const Color(0xFFEF4444);
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
      case 'webp':
      case 'svg':
        return const Color(0xFFA855F7);
      case 'mp4':
      case 'mkv':
      case 'mov':
      case 'avi':
        return const Color(0xFFF97316);
      case 'mp3':
      case 'wav':
      case 'flac':
      case 'm4a':
        return const Color(0xFFEC4899);
      case 'apk':
      case 'zip':
      case 'rar':
      case '7z':
        return const Color(0xFF10B981);
      case 'doc':
      case 'docx':
      case 'txt':
      case 'xls':
      case 'xlsx':
        return const Color(0xFF3B82F6);
      default:
        return const Color(0xFF64748B);
    }
  }

  IconData _getFileIcon(String name) {
    final ext = name.split('.').last.toLowerCase();
    switch (ext) {
      case 'pdf':
        return Icons.picture_as_pdf_rounded;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
      case 'webp':
      case 'svg':
        return Icons.image_rounded;
      case 'mp4':
      case 'mkv':
      case 'mov':
      case 'avi':
        return Icons.videocam_rounded;
      case 'mp3':
      case 'wav':
      case 'flac':
      case 'm4a':
        return Icons.audio_file_rounded;
      case 'apk':
        return Icons.android_rounded;
      case 'zip':
      case 'rar':
      case '7z':
        return Icons.folder_zip_rounded;
      case 'doc':
      case 'docx':
      case 'txt':
        return Icons.description_rounded;
      default:
        return Icons.insert_drive_file_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalBytes = selectedFiles.fold<int>(0, (sum, f) => sum + f.size);

    return Scaffold(
      backgroundColor: const Color(0xFF060A12),
      appBar: AppBar(
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.arrow_back_rounded, size: 18),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Send Files'),
        actions: [
          IconButton(
            icon: Icon(
              showPortField ? Icons.tune_rounded : Icons.tune_outlined,
              color: showPortField ? const Color(0xFF00E5FF) : Colors.white38,
              size: 20,
            ),
            onPressed: () => setState(() => showPortField = !showPortField),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─── Receiver Input ───
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F1520),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: selectedDevice != null
                        ? const Color(0xFF00E5FF).withValues(alpha: 0.2)
                        : Colors.white.withValues(alpha: 0.04),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Label
                    Row(
                      children: [
                        Text(
                          'RECEIVER',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.5,
                            color: const Color(
                              0xFF00E5FF,
                            ).withValues(alpha: 0.8),
                          ),
                        ),
                        const Spacer(),
                        if (selectedDevice != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(
                                0xFF10B981,
                              ).withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 5,
                                  height: 5,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF10B981),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Text(
                                  'Linked',
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF10B981),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Text field
                    TextField(
                      controller: deviceController,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Device name or IP',
                        hintStyle: TextStyle(
                          color: Colors.white.withValues(alpha: 0.2),
                          fontWeight: FontWeight.normal,
                          fontSize: 13,
                        ),
                        prefixIcon: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Icon(
                            Icons.devices_rounded,
                            size: 18,
                            color: const Color(
                              0xFF00E5FF,
                            ).withValues(alpha: 0.6),
                          ),
                        ),
                        suffixIcon: deviceController.text.isNotEmpty
                            ? IconButton(
                                icon: Icon(
                                  Icons.close_rounded,
                                  size: 16,
                                  color: Colors.white.withValues(alpha: 0.3),
                                ),
                                onPressed: () {
                                  setState(() {
                                    deviceController.clear();
                                    selectedDevice = null;
                                  });
                                },
                              )
                            : null,
                        isDense: true,
                        filled: true,
                        fillColor: const Color(0xFF080D18),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 14,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                            color: Color(0xFF00E5FF),
                            width: 1,
                          ),
                        ),
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                    // Port field (hidden by default)
                    if (showPortField) ...[
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Icon(
                            Icons.tag_rounded,
                            size: 14,
                            color: Colors.white.withValues(alpha: 0.3),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Port',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.white.withValues(alpha: 0.4),
                            ),
                          ),
                          const SizedBox(width: 10),
                          SizedBox(
                            width: 80,
                            child: TextField(
                              controller: portController,
                              keyboardType: TextInputType.number,
                              style: const TextStyle(fontSize: 12),
                              decoration: InputDecoration(
                                isDense: true,
                                filled: true,
                                fillColor: const Color(0xFF080D18),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 8,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '4040 Android / 4041 Windows',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.white.withValues(alpha: 0.25),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // ─── Nearby Devices ───
              Row(
                children: [
                  Icon(
                    Icons.radar_rounded,
                    size: 14,
                    color: const Color(0xFF00E5FF).withValues(alpha: 0.6),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    'NEARBY',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.5,
                      color: Colors.white.withValues(alpha: 0.4),
                    ),
                  ),
                  if (discoveredDevices.isNotEmpty) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 1,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00E5FF).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${discoveredDevices.length}',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF00E5FF),
                        ),
                      ),
                    ),
                  ],
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      setState(() => discoveredDevices.clear());
                      startScanning();
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.refresh_rounded,
                          size: 12,
                          color: Colors.white.withValues(alpha: 0.35),
                        ),
                        const SizedBox(width: 3),
                        Text(
                          'Scan',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.white.withValues(alpha: 0.35),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              if (discoveredDevices.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F1520),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(
                          strokeWidth: 1.5,
                          color: Color(0xFF00E5FF),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Scanning for receivers...',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.white.withValues(alpha: 0.35),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              else
                SizedBox(
                  height: 40,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: discoveredDevices.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final device = discoveredDevices[index];
                      final isSelected =
                          selectedDevice == device ||
                          deviceController.text.trim().toLowerCase() ==
                              device.name.toLowerCase();

                      return GestureDetector(
                        onTap: () => selectDevice(device),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            gradient: isSelected
                                ? const LinearGradient(
                                    colors: [
                                      Color(0xFF00B4D8),
                                      Color(0xFF0077B6),
                                    ],
                                  )
                                : null,
                            color: isSelected ? null : const Color(0xFF0F1520),
                            borderRadius: BorderRadius.circular(12),
                            border: isSelected
                                ? null
                                : Border.all(
                                    color: Colors.white.withValues(alpha: 0.06),
                                  ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: const Color(
                                        0xFF00E5FF,
                                      ).withValues(alpha: 0.25),
                                      blurRadius: 10,
                                    ),
                                  ]
                                : null,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isSelected
                                    ? Icons.check_circle_rounded
                                    : _getPlatformIcon(device.platform),
                                size: 15,
                                color: isSelected
                                    ? Colors.white
                                    : Colors.white60,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                device.name,
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

              const SizedBox(height: 14),

              // ─── Files Header ───
              Row(
                children: [
                  Text(
                    'FILES',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.5,
                      color: Colors.white.withValues(alpha: 0.4),
                    ),
                  ),
                  if (selectedFiles.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${selectedFiles.length} • ${_formatBytes(totalBytes)}',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => setState(() => selectedFiles.clear()),
                      child: Text(
                        'Clear',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.redAccent.withValues(alpha: 0.7),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 8),

              // ─── Files List ───
              Expanded(
                child: selectedFiles.isEmpty
                    ? GestureDetector(
                        onTap: sending ? null : pickFiles,
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: const Color(0xFF0F1520),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: const Color(
                                0xFF00E5FF,
                              ).withValues(alpha: 0.1),
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      const Color(
                                        0xFF00E5FF,
                                      ).withValues(alpha: 0.12),
                                      const Color(
                                        0xFF7C3AED,
                                      ).withValues(alpha: 0.08),
                                    ],
                                  ),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.add_rounded,
                                  size: 32,
                                  color: Color(0xFF00E5FF),
                                ),
                              ),
                              const SizedBox(height: 14),
                              const Text(
                                'Choose Files',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Tap to select photos, videos, docs',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.white.withValues(alpha: 0.35),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : Column(
                        children: [
                          Expanded(
                            child: ListView.separated(
                              physics: const BouncingScrollPhysics(),
                              itemCount: selectedFiles.length,
                              separatorBuilder: (_, _) =>
                                  const SizedBox(height: 6),
                              itemBuilder: (context, index) {
                                final file = selectedFiles[index];
                                final color = _getFileColor(file.name);
                                final icon = _getFileIcon(file.name);

                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF0F1520),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: color.withValues(alpha: 0.12),
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        child: Icon(
                                          icon,
                                          color: color,
                                          size: 18,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              file.name,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            Text(
                                              _formatBytes(file.size),
                                              style: TextStyle(
                                                fontSize: 10,
                                                color: Colors.white.withValues(
                                                  alpha: 0.35,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () => removeFile(index),
                                        child: Icon(
                                          Icons.close_rounded,
                                          size: 16,
                                          color: Colors.white.withValues(
                                            alpha: 0.25,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 6),
                          SizedBox(
                            width: double.infinity,
                            height: 38,
                            child: OutlinedButton.icon(
                              onPressed: sending ? null : pickFiles,
                              icon: const Icon(Icons.add_rounded, size: 16),
                              label: const Text(
                                'Add More',
                                style: TextStyle(fontSize: 12),
                              ),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFF00E5FF),
                                side: BorderSide(
                                  color: const Color(
                                    0xFF00E5FF,
                                  ).withValues(alpha: 0.2),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
              ),

              const SizedBox(height: 10),

              // ─── Progress ───
              if (sending)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: transferProgress > 0 ? transferProgress : null,
                      minHeight: 4,
                      backgroundColor: Colors.white.withValues(alpha: 0.06),
                      color: const Color(0xFF00E5FF),
                    ),
                  ),
                ),

              // ─── Status ───
              if (status.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Center(
                    child: Text(
                      status,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: status.contains('✗') || status.contains('⚠')
                            ? const Color(0xFFEF4444)
                            : status.contains('✓')
                            ? const Color(0xFF10B981)
                            : Colors.white.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                ),

              // ─── Send Button ───
              Container(
                width: double.infinity,
                height: 52,
                margin: const EdgeInsets.only(bottom: 4),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF00B4D8), Color(0xFF7C3AED)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00E5FF).withValues(alpha: 0.25),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ElevatedButton.icon(
                  onPressed: sending ? null : sendFiles,
                  icon: sending
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(
                          Icons.send_rounded,
                          size: 18,
                          color: Colors.white,
                        ),
                  label: Text(
                    sending ? 'Sending...' : 'Send Files',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
