import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/storage_service.dart';
import '../../services/ad_service.dart';
import '../../services/analytics_service.dart';
import '../../config/levels.dart';

/// Level complete overlay with next level or ad unlock
class LevelCompleteOverlay extends StatelessWidget {
  final dynamic game;
  
  const LevelCompleteOverlay({super.key, required this.game});
  
  @override
  Widget build(BuildContext context) {
    final storage = Provider.of<StorageService>(context, listen: false);
    final adService = Provider.of<AdService>(context, listen: false);
    final analytics = Provider.of<AnalyticsService>(context, listen: false);
    
    final nextLevel = game.currentLevel + 1;
    final isNextLevelFree = LevelConfigs.isLevelFree(nextLevel);
    final isNextLevelUnlocked = storage.isLevelUnlocked(nextLevel);
    
    return Container(
      color: Colors.black87,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.celebration, color: Colors.amber, size: 80),
            const SizedBox(height: 20),
            const Text(
              'LEVEL COMPLETE!',
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
            
            if (nextLevel <= 10) ...[
              if (isNextLevelFree || isNextLevelUnlocked)
                ElevatedButton.icon(
                  onPressed: () {
                    game.overlays.remove('LevelCompleteOverlay');
                    game.nextLevel();
                  },
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text('NEXT LEVEL'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  ),
                )
              else
                Column(
                  children: [
                    const Text(
                      'Watch an ad to unlock the next level',
                      style: TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () async {
                        analytics.logUnlockPromptShown(nextLevel);
                        analytics.logRewardedAdStarted(nextLevel);
                        
                        await adService.showRewardedAd(
                          onRewarded: () async {
                            await storage.unlockLevel(nextLevel);
                            analytics.logRewardedAdCompleted(nextLevel);
                            analytics.logLevelUnlocked(nextLevel);
                            
                            game.overlays.remove('LevelCompleteOverlay');
                            game.nextLevel();
                          },
                          onFailed: () {
                            analytics.logRewardedAdFailed(nextLevel, 'ad_not_available');
                          },
                        );
                      },
                      icon: const Icon(Icons.play_circle),
                      label: const Text('WATCH AD'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      ),
                    ),
                  ],
                ),
            ] else
              const Text(
                'Congratulations! You completed all levels!',
                style: TextStyle(color: Colors.amber, fontSize: 18),
              ),
          ],
        ),
      ),
    );
  }
}
