import 'dart:async';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'analytics_config.dart';
import 'backend_service.dart';

/// Analytics service for Batch-20260107-110734-puzzle-01
/// 
/// Handles all analytics tracking via Firebase Analytics
/// with automatic backend forwarding for GameFactory metrics.
class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;
  AnalyticsService._internal();

  late FirebaseAnalytics _analytics;
  late BackendService _backendService;
  bool _initialized = false;
  String? _userId;
  String? _sessionId;

  /// Initialize the analytics service
  Future<void> initialize() async {
    if (_initialized) return;
    
    _analytics = FirebaseAnalytics.instance;
    _backendService = BackendService();
    await _backendService.initialize();
    
    // Generate session ID
    _sessionId = DateTime.now().millisecondsSinceEpoch.toString();
    
    _initialized = true;
    
    if (kDebugMode) {
      print('[Analytics] Initialized for Batch-20260107-110734-puzzle-01');
    }
  }

  /// Set user ID for analytics
  void setUserId(String userId) {
    _userId = userId;
    _analytics.setUserId(id: userId);
  }

  /// Log a custom event with parameters
  Future<void> logEvent(String name, Map<String, dynamic>? params) async {
    if (!_initialized) return;

    final enrichedParams = _enrichParams(params ?? {});
    
    // Log to Firebase
    await _analytics.logEvent(
      name: name,
      parameters: enrichedParams.map((k, v) => MapEntry(k, v.toString())),
    );

    // Forward to backend if enabled
    if (AnalyticsConfig.forwardToBackend) {
      await _backendService.sendEvent(name, enrichedParams);
    }

    if (kDebugMode) {
      print('[Analytics] $name: $enrichedParams');
    }
  }

  Map<String, dynamic> _enrichParams(Map<String, dynamic> params) {
    return {
      ...params,
      'session_id': _sessionId,
      'user_id': _userId ?? 'anonymous',
      'timestamp': DateTime.now().toIso8601String(),
      'app_version': AnalyticsConfig.appVersion,
    };
  }

  // ============ Standard Events ============

  Future<void> logGameStart() async {
    await logEvent('game_start', {});
  }

  Future<void> logLevelStart(int level, {int attemptNumber = 1}) async {
    await logEvent('level_start', {
      'level': level,
      'attempt_number': attemptNumber,
    });
  }

  Future<void> logLevelComplete(int level, int score, int timeSeconds, {int stars = 0}) async {
    await logEvent('level_complete', {
      'level': level,
      'score': score,
      'time_seconds': timeSeconds,
      'stars_earned': stars,
    });
  }

  Future<void> logLevelFail(int level, int score, String reason, int timeSeconds) async {
    await logEvent('level_fail', {
      'level': level,
      'score': score,
      'fail_reason': reason,
      'time_seconds': timeSeconds,
    });
  }

  Future<void> logUnlockPromptShown(int level) async {
    await logEvent('unlock_prompt_shown', {
      'level': level,
      'prompt_type': 'rewarded_ad',
    });
  }

  Future<void> logRewardedAdStarted(int level) async {
    await logEvent('rewarded_ad_started', {
      'level': level,
      'ad_placement': 'level_unlock',
    });
  }

  Future<void> logRewardedAdCompleted(int level) async {
    await logEvent('rewarded_ad_completed', {
      'level': level,
      'reward_type': 'level_unlock',
      'reward_value': 1,
    });
  }

  Future<void> logRewardedAdFailed(int level, String reason) async {
    await logEvent('rewarded_ad_failed', {
      'level': level,
      'failure_reason': reason,
    });
  }

  Future<void> logLevelUnlocked(int level) async {
    await logEvent('level_unlocked', {
      'level': level,
      'unlock_method': 'rewarded_ad',
    });
  }
}
