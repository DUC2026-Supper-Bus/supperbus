import 'package:flutter/material.dart';

import 'send_screen.dart';
import 'receive_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Widget featureCard({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(icon, color: color, size: 30),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      description,
                      style: const TextStyle(
                        color: Colors.white60,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 17),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              Row(
                children: [
                  Container(
                    height: 48,
                    width: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFF00D9FF),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Icon(
                      Icons.bolt,
                      color: Colors.black,
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'V-SHERE',
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 45),

              const Text(
                'Share files.',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const Text(
                'Fast. Private. Direct.',
                style: TextStyle(
                  fontSize: 17,
                  color: Colors.white60,
                ),
              ),

              const SizedBox(height: 35),

              featureCard(
                icon: Icons.upload_rounded,
                title: 'Send Files',
                description: 'Send photos, videos and documents',
                color: const Color(0xFF00D9FF),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const SendScreen(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 16),

              featureCard(
                icon: Icons.download_rounded,
                title: 'Receive Files',
                description: 'Make this device ready to receive',
                color: Colors.greenAccent,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ReceiveScreen(),
                    ),
                  );
                },
              ),

              const Spacer(),

              const Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.wifi,
                      color: Color(0xFF00D9FF),
                      size: 26,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'DIRECT WI-FI TRANSFER',
                      style: TextStyle(
                        letterSpacing: 1.5,
                        fontSize: 12,
                        color: Colors.white70,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'V-Shere • Version 1.0',
                      style: TextStyle(
                        color: Colors.white38,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
