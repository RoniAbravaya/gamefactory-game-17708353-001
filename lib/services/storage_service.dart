import 'package:shared_preferences/shared_preferences.dart';

/// Storage service for persisting game data
/// 
/// Handles level unlock state, high scores, and settings.
class StorageService {
  late SharedPreferences _prefs;
  bool _initialized = false;
  
  static const String _unlockedLevelsKey = 'unlocked_levels';
  static const String _highScoresKey = 'high_scores';
  static const String _soundEnabledKey = 'sound_enabled';
  static const String _musicEnabledKey = 'music_enabled';
  
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    _initialized = true;
  }
  
  // Level unlock management
  
  List<int> getUnlockedLevels() {
    final data = _prefs.getStringList(_unlockedLevelsKey);
    if (data == null) return [1, 2, 3]; // Default free levels
    return data.map((e) => int.parse(e)).toList();
  }
  
  Future<void> unlockLevel(int level) async {
    final unlocked = getUnlockedLevels();
    if (!unlocked.contains(level)) {
      unlocked.add(level);
      await _prefs.setStringList(
        _unlockedLevelsKey,
        unlocked.map((e) => e.toString()).toList(),
      );
    }
  }
  
  bool isLevelUnlocked(int level) {
    return getUnlockedLevels().contains(level);
  }
  
  // High scores
  
  Map<int, int> getHighScores() {
    final data = _prefs.getStringList(_highScoresKey);
    if (data == null) return {};
    
    final scores = <int, int>{};
    for (final entry in data) {
      final parts = entry.split(':');
      if (parts.length == 2) {
        scores[int.parse(parts[0])] = int.parse(parts[1]);
      }
    }
    return scores;
  }
  
  Future<void> setHighScore(int level, int score) async {
    final scores = getHighScores();
    if (!scores.containsKey(level) || scores[level]! < score) {
      scores[level] = score;
      await _prefs.setStringList(
        _highScoresKey,
        scores.entries.map((e) => '${e.key}:${e.value}').toList(),
      );
    }
  }
  
  // Settings
  
  bool get soundEnabled => _prefs.getBool(_soundEnabledKey) ?? true;
  bool get musicEnabled => _prefs.getBool(_musicEnabledKey) ?? true;
  
  Future<void> setSoundEnabled(bool enabled) async {
    await _prefs.setBool(_soundEnabledKey, enabled);
  }
  
  Future<void> setMusicEnabled(bool enabled) async {
    await _prefs.setBool(_musicEnabledKey, enabled);
  }
}
