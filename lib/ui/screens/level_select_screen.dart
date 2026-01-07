import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/storage_service.dart';
import '../../config/levels.dart';

/// Level selection screen
class LevelSelectScreen extends StatelessWidget {
  const LevelSelectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final storage = Provider.of<StorageService>(context, listen: false);
    final unlockedLevels = storage.getUnlockedLevels();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Level'),
        backgroundColor: const Color(0xFF1A1A2E),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
          ),
        ),
        child: GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
          ),
          itemCount: LevelConfigs.levels.length,
          itemBuilder: (context, index) {
            final level = LevelConfigs.levels[index];
            final isUnlocked = unlockedLevels.contains(level.levelNumber);
            
            return GestureDetector(
              onTap: isUnlocked
                  ? () {
                      // Navigate to game with specific level
                      Navigator.pop(context);
                    }
                  : null,
              child: Container(
                decoration: BoxDecoration(
                  color: isUnlocked ? Colors.deepPurple : Colors.grey[800],
                  borderRadius: BorderRadius.circular(12),
                  border: level.isFree
                      ? Border.all(color: Colors.amber, width: 2)
                      : null,
                ),
                child: Center(
                  child: isUnlocked
                      ? Text(
                          '${level.levelNumber}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : const Icon(Icons.lock, color: Colors.white54),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
