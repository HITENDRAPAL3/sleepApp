import 'package:flutter/material.dart';
import '../services/background_service.dart';
import '../widgets/background_container.dart';

class BackgroundTestPage extends StatefulWidget {
  const BackgroundTestPage({super.key});

  @override
  State<BackgroundTestPage> createState() => _BackgroundTestPageState();
}

class _BackgroundTestPageState extends State<BackgroundTestPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Background Test'),
        backgroundColor: Colors.black54,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildTestCard('Welcome Page', BackgroundType.welcome),
            const SizedBox(height: 16),
            _buildTestCard('Night Timer Page', BackgroundType.night),
            const SizedBox(height: 16),
            _buildTestCard('Morning Timer Page', BackgroundType.morning),
            const SizedBox(height: 16),
            _buildTestCard('Completion Page', BackgroundType.completion),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () async {
                await BackgroundService.resetAllBackgrounds();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Background indices reset! Restart app to see changes.'),
                  ),
                );
              },
              child: const Text('Reset All Backgrounds'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTestCard(String title, BackgroundType type) {
    return Card(
      elevation: 8,
      child: Container(
        height: 200,
        width: double.infinity,
        child: BackgroundContainer(
          backgroundType: type,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black45,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  FutureBuilder<int>(
                    future: BackgroundService.getCurrentIndex(type),
                    builder: (context, snapshot) {
                      return Text(
                        'Current Index: ${snapshot.data ?? 0}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}