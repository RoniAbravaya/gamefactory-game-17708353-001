import 'package:flutter_test/flutter_test.dart';
import 'package:game_17708353_001/models/game_state.dart';

void main() {
  group('GameState', () {
    test('should create with default values', () {
      const state = GameState();
      
      expect(state.currentLevel, 1);
      expect(state.score, 0);
      expect(state.lives, 3);
      expect(state.isPaused, false);
      expect(state.isGameOver, false);
      expect(state.isLevelComplete, false);
    });

    test('should copy with new values', () {
      const state = GameState();
      final newState = state.copyWith(score: 100, lives: 2);
      
      expect(newState.score, 100);
      expect(newState.lives, 2);
      expect(newState.currentLevel, 1); // unchanged
    });

    test('should be equal with same values', () {
      const state1 = GameState(score: 100);
      const state2 = GameState(score: 100);
      
      expect(state1, state2);
    });
  });
}
