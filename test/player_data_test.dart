import 'package:flutter_test/flutter_test.dart';
import 'package:game_17708353_001/models/player_data.dart';

void main() {
  group('PlayerData', () {
    test('should have first 3 levels unlocked by default', () {
      const data = PlayerData();
      
      expect(data.isLevelUnlocked(1), true);
      expect(data.isLevelUnlocked(2), true);
      expect(data.isLevelUnlocked(3), true);
      expect(data.isLevelUnlocked(4), false);
    });

    test('should return 0 for levels without high score', () {
      const data = PlayerData();
      
      expect(data.getHighScore(1), 0);
    });

    test('should copy with new unlocked levels', () {
      const data = PlayerData();
      final newData = data.copyWith(unlockedLevels: [1, 2, 3, 4]);
      
      expect(newData.isLevelUnlocked(4), true);
    });
  });
}
