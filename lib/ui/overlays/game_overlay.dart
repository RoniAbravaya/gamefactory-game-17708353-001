import 'package:flutter/material.dart';
import '../../game/game.dart';

/// Main game HUD overlay showing score, lives, and pause button
class GameOverlay extends StatelessWidget {
  final dynamic game;
  
  const GameOverlay({super.key, required this.game});
  
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Score
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 24),
                  const SizedBox(width: 8),
                  Text(
                    '${game.score}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            
            // Pause button
            IconButton(
              onPressed: () {
                game.pauseEngine();
                game.overlays.add('PauseOverlay');
              },
              icon: const Icon(Icons.pause_circle, color: Colors.white, size: 40),
            ),
          ],
        ),
      ),
    );
  }
}
