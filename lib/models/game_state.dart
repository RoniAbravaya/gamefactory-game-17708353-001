import 'package:equatable/equatable.dart';

/// Represents the current state of the game
class GameState extends Equatable {
  final int currentLevel;
  final int score;
  final int lives;
  final bool isPaused;
  final bool isGameOver;
  final bool isLevelComplete;
  final Duration playTime;

  const GameState({
    this.currentLevel = 1,
    this.score = 0,
    this.lives = 3,
    this.isPaused = false,
    this.isGameOver = false,
    this.isLevelComplete = false,
    this.playTime = Duration.zero,
  });

  GameState copyWith({
    int? currentLevel,
    int? score,
    int? lives,
    bool? isPaused,
    bool? isGameOver,
    bool? isLevelComplete,
    Duration? playTime,
  }) {
    return GameState(
      currentLevel: currentLevel ?? this.currentLevel,
      score: score ?? this.score,
      lives: lives ?? this.lives,
      isPaused: isPaused ?? this.isPaused,
      isGameOver: isGameOver ?? this.isGameOver,
      isLevelComplete: isLevelComplete ?? this.isLevelComplete,
      playTime: playTime ?? this.playTime,
    );
  }

  @override
  List<Object?> get props => [
        currentLevel,
        score,
        lives,
        isPaused,
        isGameOver,
        isLevelComplete,
        playTime,
      ];
}
