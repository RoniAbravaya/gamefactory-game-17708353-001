/// Level configurations for the game
/// 
/// Defines parameters for all 10 levels including difficulty,
/// time limits, and unlock requirements.

class LevelConfig {
  final int levelNumber;
  final String name;
  final bool isFree;
  final double difficulty;
  final int? timeLimitSeconds;
  final int targetScore;
  final int obstacleCount;
  final double obstacleSpeed;
  final int collectibleCount;
  final String backgroundTheme;
  
  const LevelConfig({
    required this.levelNumber,
    required this.name,
    required this.isFree,
    required this.difficulty,
    this.timeLimitSeconds,
    required this.targetScore,
    required this.obstacleCount,
    required this.obstacleSpeed,
    required this.collectibleCount,
    required this.backgroundTheme,
  });
}

class LevelConfigs {
  static const List<LevelConfig> levels = [
    LevelConfig(
      levelNumber: 1,
      name: 'Tutorial',
      isFree: true,
      difficulty: 0.1,
      timeLimitSeconds: null,
      targetScore: 100,
      obstacleCount: 3,
      obstacleSpeed: 1.0,
      collectibleCount: 10,
      backgroundTheme: 'meadow',
    ),
    LevelConfig(
      levelNumber: 2,
      name: 'Getting Started',
      isFree: true,
      difficulty: 0.2,
      timeLimitSeconds: 120,
      targetScore: 200,
      obstacleCount: 5,
      obstacleSpeed: 1.2,
      collectibleCount: 15,
      backgroundTheme: 'meadow',
    ),
    LevelConfig(
      levelNumber: 3,
      name: 'First Challenge',
      isFree: true,
      difficulty: 0.3,
      timeLimitSeconds: 90,
      targetScore: 300,
      obstacleCount: 7,
      obstacleSpeed: 1.4,
      collectibleCount: 20,
      backgroundTheme: 'forest',
    ),
    LevelConfig(
      levelNumber: 4,
      name: 'Into the Woods',
      isFree: false,
      difficulty: 0.4,
      timeLimitSeconds: 90,
      targetScore: 400,
      obstacleCount: 10,
      obstacleSpeed: 1.6,
      collectibleCount: 25,
      backgroundTheme: 'forest',
    ),
    LevelConfig(
      levelNumber: 5,
      name: 'Midway Point',
      isFree: false,
      difficulty: 0.5,
      timeLimitSeconds: 75,
      targetScore: 500,
      obstacleCount: 12,
      obstacleSpeed: 1.8,
      collectibleCount: 30,
      backgroundTheme: 'mountain',
    ),
    LevelConfig(
      levelNumber: 6,
      name: 'Rising Difficulty',
      isFree: false,
      difficulty: 0.6,
      timeLimitSeconds: 75,
      targetScore: 600,
      obstacleCount: 15,
      obstacleSpeed: 2.0,
      collectibleCount: 35,
      backgroundTheme: 'mountain',
    ),
    LevelConfig(
      levelNumber: 7,
      name: 'Expert Zone',
      isFree: false,
      difficulty: 0.7,
      timeLimitSeconds: 60,
      targetScore: 700,
      obstacleCount: 18,
      obstacleSpeed: 2.2,
      collectibleCount: 40,
      backgroundTheme: 'cave',
    ),
    LevelConfig(
      levelNumber: 8,
      name: 'Master Level',
      isFree: false,
      difficulty: 0.8,
      timeLimitSeconds: 60,
      targetScore: 800,
      obstacleCount: 20,
      obstacleSpeed: 2.5,
      collectibleCount: 45,
      backgroundTheme: 'cave',
    ),
    LevelConfig(
      levelNumber: 9,
      name: 'Ultimate Challenge',
      isFree: false,
      difficulty: 0.9,
      timeLimitSeconds: 45,
      targetScore: 900,
      obstacleCount: 25,
      obstacleSpeed: 2.8,
      collectibleCount: 50,
      backgroundTheme: 'sky',
    ),
    LevelConfig(
      levelNumber: 10,
      name: 'Final Boss',
      isFree: false,
      difficulty: 1.0,
      timeLimitSeconds: 45,
      targetScore: 1000,
      obstacleCount: 30,
      obstacleSpeed: 3.0,
      collectibleCount: 60,
      backgroundTheme: 'sky',
    ),
  ];
  
  static LevelConfig getLevel(int level) {
    if (level < 1 || level > levels.length) {
      return levels.first;
    }
    return levels[level - 1];
  }
  
  static bool isLevelFree(int level) {
    return level >= 1 && level <= 3;
  }
}
