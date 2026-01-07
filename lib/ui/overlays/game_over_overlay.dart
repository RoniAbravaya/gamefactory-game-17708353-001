import 'package:flutter/material.dart';

/// Game over overlay with retry option
class GameOverOverlay extends StatelessWidget {
  final dynamic game;
  
  const GameOverOverlay({super.key, required this.game});
  
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black87,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.sentiment_dissatisfied, color: Colors.red, size: 80),
            const SizedBox(height: 20),
            const Text(
              'GAME OVER',
              style: TextStyle(
                color: Colors.white,
                fontSize: 36,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Score: ${game.score}',
              style: const TextStyle(color: Colors.white70, fontSize: 24),
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: () {
                game.overlays.remove('GameOverOverlay');
                game.restartLevel();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('TRY AGAIN'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
