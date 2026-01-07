import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/services.dart';

/// Player component for the tile-swapping puzzle game
/// Manages player interactions, score tracking, and visual feedback
class Player extends SpriteAnimationComponent with HasKeyboardHandlerComponents, HasCollisionDetection {
  /// Current player score
  int score = 0;
  
  /// Player gems (currency)
  int gems = 0;
  
  /// Current level being played
  int currentLevel = 1;
  
  /// Time remaining in current level
  double timeRemaining = 90.0;
  
  /// Whether the player is currently making a move
  bool isMoving = false;
  
  /// Current animation state
  PlayerState _currentState = PlayerState.idle;
  
  /// Animation components for different states
  late SpriteAnimation _idleAnimation;
  late SpriteAnimation _celebrateAnimation;
  late SpriteAnimation _thinkingAnimation;
  
  /// Callback for when player completes a pattern
  Function(int points)? onPatternComplete;
  
  /// Callback for when player runs out of time
  Function()? onTimeExpired;
  
  /// Callback for when score changes
  Function(int newScore)? onScoreChanged;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    // Load sprite animations
    await _loadAnimations();
    
    // Set initial animation
    animation = _idleAnimation;
    _currentState = PlayerState.idle;
    
    // Set up collision detection
    add(RectangleHitbox());
    
    // Initialize position and size
    size = Vector2(64, 64);
    anchor = Anchor.center;
  }

  /// Load all player animations
  Future<void> _loadAnimations() async {
    try {
      _idleAnimation = await game.loadSpriteAnimation(
        'player_idle.png',
        SpriteAnimationData.sequenced(
          amount: 4,
          stepTime: 0.5,
          textureSize: Vector2(64, 64),
        ),
      );
      
      _celebrateAnimation = await game.loadSpriteAnimation(
        'player_celebrate.png',
        SpriteAnimationData.sequenced(
          amount: 6,
          stepTime: 0.2,
          textureSize: Vector2(64, 64),
        ),
      );
      
      _thinkingAnimation = await game.loadSpriteAnimation(
        'player_thinking.png',
        SpriteAnimationData.sequenced(
          amount: 3,
          stepTime: 0.8,
          textureSize: Vector2(64, 64),
        ),
      );
    } catch (e) {
      // Fallback to solid color rectangles if sprites fail to load
      _createFallbackAnimations();
    }
  }

  /// Create fallback animations using solid colors
  void _createFallbackAnimations() {
    // This would create simple colored rectangle animations as fallback
    // Implementation depends on your specific sprite loading setup
  }

  @override
  void update(double dt) {
    super.update(dt);
    
    // Update timer
    if (timeRemaining > 0) {
      timeRemaining -= dt;
      if (timeRemaining <= 0) {
        timeRemaining = 0;
        onTimeExpired?.call();
      }
    }
  }

  /// Add points to player score
  void addScore(int points) {
    score += points;
    onScoreChanged?.call(score);
    
    // Trigger celebration animation for significant scores
    if (points >= 100) {
      setState(PlayerState.celebrate);
    }
  }

  /// Add gems to player currency
  void addGems(int amount) {
    gems += amount;
  }

  /// Spend gems if player has enough
  bool spendGems(int amount) {
    if (gems >= amount) {
      gems -= amount;
      return true;
    }
    return false;
  }

  /// Set player animation state
  void setState(PlayerState newState) {
    if (_currentState == newState) return;
    
    _currentState = newState;
    
    switch (newState) {
      case PlayerState.idle:
        animation = _idleAnimation;
        break;
      case PlayerState.thinking:
        animation = _thinkingAnimation;
        break;
      case PlayerState.celebrate:
        animation = _celebrateAnimation;
        // Auto-return to idle after celebration
        Future.delayed(const Duration(seconds: 1), () {
          if (_currentState == PlayerState.celebrate) {
            setState(PlayerState.idle);
          }
        });
        break;
    }
  }

  /// Handle pattern completion
  void onPatternMatched(int patternValue, bool isChain) {
    int basePoints = patternValue * 10;
    int bonusPoints = isChain ? basePoints ~/ 2 : 0;
    int totalPoints = basePoints + bonusPoints;
    
    addScore(totalPoints);
    
    // Award bonus time for chain matches
    if (isChain) {
      timeRemaining += 5.0;
      timeRemaining = timeRemaining.clamp(0.0, 120.0);
    }
    
    onPatternComplete?.call(totalPoints);
    setState(PlayerState.celebrate);
  }

  /// Start thinking animation when player is considering moves
  void startThinking() {
    setState(PlayerState.thinking);
  }

  /// Stop thinking and return to idle
  void stopThinking() {
    setState(PlayerState.idle);
  }

  /// Reset player state for new level
  void resetForLevel(int level) {
    currentLevel = level;
    isMoving = false;
    setState(PlayerState.idle);
    
    // Set time based on level difficulty
    switch (level) {
      case 1:
      case 2:
      case 3:
        timeRemaining = 90.0;
        break;
      case 4:
      case 5:
      case 6:
        timeRemaining = 75.0;
        break;
      case 7:
      case 8:
        timeRemaining = 60.0;
        break;
      default:
        timeRemaining = 45.0;
        break;
    }
  }

  /// Get current time remaining as percentage
  double getTimePercentage() {
    double maxTime = switch (currentLevel) {
      1 || 2 || 3 => 90.0,
      4 || 5 || 6 => 75.0,
      7 || 8 => 60.0,
      _ => 45.0,
    };
    return (timeRemaining / maxTime).clamp(0.0, 1.0);
  }

  /// Check if player can afford a purchase
  bool canAfford(int cost) {
    return gems >= cost;
  }

  /// Use hint system (costs gems)
  bool useHint() {
    const int hintCost = 10;
    if (spendGems(hintCost)) {
      setState(PlayerState.thinking);
      return true;
    }
    return false;
  }

  /// Extend time (costs gems)
  bool extendTime() {
    const int extensionCost = 15;
    if (spendGems(extensionCost)) {
      timeRemaining += 30.0;
      timeRemaining = timeRemaining.clamp(0.0, 120.0);
      return true;
    }
    return false;
  }

  /// Reveal pattern (costs gems)
  bool revealPattern() {
    const int revealCost = 20;
    if (spendGems(revealCost)) {
      setState(PlayerState.celebrate);
      return true;
    }
    return false;
  }
}

/// Enum for player animation states
enum PlayerState {
  idle,
  thinking,
  celebrate,
}