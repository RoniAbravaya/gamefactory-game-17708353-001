import 'package:equatable/equatable.dart';

/// Persistent player data
class PlayerData extends Equatable {
  final List<int> unlockedLevels;
  final Map<int, int> highScores;
  final int totalCoins;
  final bool soundEnabled;
  final bool musicEnabled;

  const PlayerData({
    this.unlockedLevels = const [1, 2, 3],
    this.highScores = const {},
    this.totalCoins = 0,
    this.soundEnabled = true,
    this.musicEnabled = true,
  });

  PlayerData copyWith({
    List<int>? unlockedLevels,
    Map<int, int>? highScores,
    int? totalCoins,
    bool? soundEnabled,
    bool? musicEnabled,
  }) {
    return PlayerData(
      unlockedLevels: unlockedLevels ?? this.unlockedLevels,
      highScores: highScores ?? this.highScores,
      totalCoins: totalCoins ?? this.totalCoins,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      musicEnabled: musicEnabled ?? this.musicEnabled,
    );
  }

  bool isLevelUnlocked(int level) => unlockedLevels.contains(level);

  int getHighScore(int level) => highScores[level] ?? 0;

  @override
  List<Object?> get props => [
        unlockedLevels,
        highScores,
        totalCoins,
        soundEnabled,
        musicEnabled,
      ];
}
