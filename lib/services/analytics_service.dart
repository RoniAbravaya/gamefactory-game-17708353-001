import 'package:firebase_analytics/firebase_analytics.dart';

/// Analytics service for tracking game events
/// 
/// Implements the GameFactory standard event schema.
class AnalyticsService {
  late FirebaseAnalytics _analytics;
  bool _initialized = false;
  
  Future<void> initialize() async {
    _analytics = FirebaseAnalytics.instance;
    _initialized = true;
  }
  
  Future<void> logEvent(String name, Map<String, dynamic>? params) async {
    if (!_initialized) return;
    await _analytics.logEvent(name: name, parameters: params);
  }
  
  // Standard GameFactory events
  
  Future<void> logGameStart() async {
    await logEvent('game_start', {'timestamp': DateTime.now().toIso8601String()});
  }
  
  Future<void> logLevelStart(int level) async {
    await logEvent('level_start', {'level': level});
  }
  
  Future<void> logLevelComplete(int level, int score) async {
    await logEvent('level_complete', {'level': level, 'score': score});
  }
  
  Future<void> logLevelFail(int level, int score) async {
    await logEvent('level_fail', {'level': level, 'score': score});
  }
  
  Future<void> logUnlockPromptShown(int level) async {
    await logEvent('unlock_prompt_shown', {'level': level});
  }
  
  Future<void> logRewardedAdStarted(int level) async {
    await logEvent('rewarded_ad_started', {'level': level});
  }
  
  Future<void> logRewardedAdCompleted(int level) async {
    await logEvent('rewarded_ad_completed', {'level': level});
  }
  
  Future<void> logRewardedAdFailed(int level, String reason) async {
    await logEvent('rewarded_ad_failed', {'level': level, 'reason': reason});
  }
  
  Future<void> logLevelUnlocked(int level) async {
    await logEvent('level_unlocked', {'level': level});
  }
}
