/// Analytics event constants
/// 
/// Auto-generated from analytics specification.
/// Do not modify manually.

class AnalyticsEvents {
  AnalyticsEvents._();

  // Required Events
  static const String GAME_START = 'game_start';
  static const String LEVEL_START = 'level_start';
  static const String LEVEL_COMPLETE = 'level_complete';
  static const String LEVEL_FAIL = 'level_fail';
  static const String UNLOCK_PROMPT_SHOWN = 'unlock_prompt_shown';
  static const String REWARDED_AD_STARTED = 'rewarded_ad_started';
  static const String REWARDED_AD_COMPLETED = 'rewarded_ad_completed';
  static const String REWARDED_AD_FAILED = 'rewarded_ad_failed';
  static const String LEVEL_UNLOCKED = 'level_unlocked';

  // Custom Events
  static const String MOVE_MADE = 'move_made';
  static const String HINT_USED = 'hint_used';
  static const String COMBO_ACHIEVED = 'combo_achieved';
}

class AnalyticsParams {
  AnalyticsParams._();

  // Common parameters
  static const String USER_ID = 'user_id';
  static const String SESSION_ID = 'session_id';
  static const String LEVEL = 'level';
  static const String SCORE = 'score';
  static const String TIME_SECONDS = 'time_seconds';
}
