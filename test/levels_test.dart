import 'package:flutter_test/flutter_test.dart';
import 'package:game_17708353_001/config/levels.dart';

void main() {
  group('LevelConfigs', () {
    test('should have 10 levels', () {
      expect(LevelConfigs.levels.length, 10);
    });

    test('should have first 3 levels free', () {
      expect(LevelConfigs.isLevelFree(1), true);
      expect(LevelConfigs.isLevelFree(2), true);
      expect(LevelConfigs.isLevelFree(3), true);
      expect(LevelConfigs.isLevelFree(4), false);
    });

    test('should get correct level config', () {
      final level = LevelConfigs.getLevel(1);
      
      expect(level.levelNumber, 1);
      expect(level.isFree, true);
    });

    test('should return first level for invalid level number', () {
      final level = LevelConfigs.getLevel(0);
      
      expect(level.levelNumber, 1);
    });
  });
}
