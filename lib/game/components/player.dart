import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/effects.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;

/// Player component for tile-swapping puzzle game
/// Handles input detection, tile selection, and visual feedback
class Player extends Component with HasGameRef, HasKeyboardHandlerComponents {
  /// Current selected tile position
  Vector2? selectedTilePosition;
  
  /// Previous selected tile for swap operations
  Vector2? previousSelectedTilePosition;
  
  /// Player's current gem count
  int gems = 0;
  
  /// Current level score
  int score = 0;
  
  /// Combo multiplier for consecutive matches
  int comboMultiplier = 1;
  
  /// Maximum combo multiplier
  static const int maxComboMultiplier = 5;
  
  /// Base points per tile match
  static const int basePointsPerTile = 10;
  
  /// Invulnerability duration after taking damage (in seconds)
  static const double invulnerabilityDuration = 1.0;
  
  /// Current invulnerability timer
  double invulnerabilityTimer = 0.0;
  
  /// Whether player is currently invulnerable
  bool get isInvulnerable => invulnerabilityTimer > 0.0;
  
  /// Player health (used for time pressure mechanics)
  int health = 3;
  
  /// Maximum player health
  static const int maxHealth = 3;
  
  /// Animation state for visual feedback
  PlayerAnimationState animationState = PlayerAnimationState.idle;
  
  /// Selection highlight effect component
  late RectangleComponent selectionHighlight;
  
  /// Particle effect for successful swaps
  late ParticleSystemComponent swapEffect;
  
  @override
  Future<void> onLoad() async {
    super.onLoad();
    
    // Initialize selection highlight
    selectionHighlight = RectangleComponent(
      size: Vector2.all(64),
      paint: Paint()
        ..color = const Color(0xFF45B7D1)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0,
    );
    selectionHighlight.opacity = 0.0;
    add(selectionHighlight);
    
    // Initialize particle effects
    swapEffect = ParticleSystemComponent(
      particle: Particle.generate(
        count: 20,
        lifespan: 0.5,
        generator: (i) => AcceleratedParticle(
          acceleration: Vector2(0, 100),
          speed: Vector2.random() * 50,
          position: Vector2.zero(),
          child: CircleParticle(
            radius: 2.0,
            paint: Paint()..color = const Color(0xFF4ECDC4),
          ),
        ),
      ),
    );
    add(swapEffect);
  }
  
  @override
  void update(double dt) {
    super.update(dt);
    
    // Update invulnerability timer
    if (invulnerabilityTimer > 0.0) {
      invulnerabilityTimer -= dt;
      if (invulnerabilityTimer <= 0.0) {
        invulnerabilityTimer = 0.0;
        _onInvulnerabilityEnd();
      }
    }
    
    // Update selection highlight position
    if (selectedTilePosition != null) {
      selectionHighlight.position = selectedTilePosition!;
      if (selectionHighlight.opacity < 1.0) {
        selectionHighlight.opacity = math.min(1.0, selectionHighlight.opacity + dt * 3.0);
      }
    } else {
      if (selectionHighlight.opacity > 0.0) {
        selectionHighlight.opacity = math.max(0.0, selectionHighlight.opacity - dt * 5.0);
      }
    }
  }
  
  /// Handles tile selection at the given position
  void selectTile(Vector2 tilePosition) {
    try {
      if (selectedTilePosition == null) {
        // First tile selection
        selectedTilePosition = tilePosition.clone();
        _playSelectionFeedback();
        animationState = PlayerAnimationState.selecting;
      } else if (selectedTilePosition == tilePosition) {
        // Deselect current tile
        deselectTile();
      } else {
        // Second tile selection - attempt swap
        previousSelectedTilePosition = selectedTilePosition!.clone();
        _attemptTileSwap(selectedTilePosition!, tilePosition);
        selectedTilePosition = null;
      }
    } catch (e) {
      // Handle selection errors gracefully
      deselectTile();
    }
  }
  
  /// Deselects the currently selected tile
  void deselectTile() {
    selectedTilePosition = null;
    previousSelectedTilePosition = null;
    animationState = PlayerAnimationState.idle;
  }
  
  /// Attempts to swap two tiles if they are adjacent
  void _attemptTileSwap(Vector2 tile1, Vector2 tile2) {
    if (_areAdjacent(tile1, tile2)) {
      _performTileSwap(tile1, tile2);
    } else {
      // Invalid swap - provide feedback
      _playInvalidSwapFeedback();
      selectedTilePosition = tile2.clone();
    }
  }
  
  /// Checks if two tile positions are adjacent
  bool _areAdjacent(Vector2 tile1, Vector2 tile2) {
    final dx = (tile1.x - tile2.x).abs();
    final dy = (tile1.y - tile2.y).abs();
    return (dx == 1 && dy == 0) || (dx == 0 && dy == 1);
  }
  
  /// Performs the actual tile swap operation
  void _performTileSwap(Vector2 tile1, Vector2 tile2) {
    animationState = PlayerAnimationState.swapping;
    
    // Trigger swap effect
    swapEffect.position = (tile1 + tile2) / 2;
    swapEffect.reset();
    
    // Play swap feedback
    _playSwapFeedback();
    
    // Reset animation state after effect
    Future.delayed(const Duration(milliseconds: 300), () {
      animationState = PlayerAnimationState.idle;
    });
  }
  
  /// Awards points for successful pattern matches
  void awardPoints(int tilesMatched, {bool isChainMatch = false}) {
    try {
      int points = tilesMatched * basePointsPerTile * comboMultiplier;
      
      if (isChainMatch) {
        points = (points * 1.5).round();
        _incrementCombo();
      } else {
        _resetCombo();
      }
      
      score += points;
      animationState = PlayerAnimationState.celebrating;
      
      // Reset animation after celebration
      Future.delayed(const Duration(milliseconds: 500), () {
        if (animationState == PlayerAnimationState.celebrating) {
          animationState = PlayerAnimationState.idle;
        }
      });
    } catch (e) {
      // Handle scoring errors gracefully
      _resetCombo();
    }
  }
  
  /// Awards gems to the player
  void awardGems(int amount) {
    gems += amount;
    gems = math.max(0, gems); // Ensure gems never go negative
  }
  
  /// Spends gems if player has enough
  bool spendGems(int amount) {
    if (gems >= amount) {
      gems -= amount;
      return true;
    }
    return false;
  }
  
  /// Takes damage and triggers invulnerability
  void takeDamage(int damage) {
    if (isInvulnerable) return;
    
    health -= damage;
    health = math.max(0, health);
    
    if (health > 0) {
      _startInvulnerability();
    }
    
    animationState = PlayerAnimationState.damaged;
    _playDamageFeedback();
    
    // Reset animation after damage effect
    Future.delayed(const Duration(milliseconds: 400), () {
      if (animationState == PlayerAnimationState.damaged) {
        animationState = PlayerAnimationState.idle;
      }
    });
  }
  
  /// Heals the player
  void heal(int amount) {
    health += amount;
    health = math.min(maxHealth, health);
    
    animationState = PlayerAnimationState.healing;
    _playHealFeedback();
    
    // Reset animation after heal effect
    Future.delayed(const Duration(milliseconds: 300), () {
      if (animationState == PlayerAnimationState.healing) {
        animationState = PlayerAnimationState.idle;
      }
    });
  }
  
  /// Starts invulnerability period
  void _startInvulnerability() {
    invulnerabilityTimer = invulnerabilityDuration;
    
    // Add flashing effect during invulnerability
    add(OpacityEffect.fadeOut(
      EffectController(
        duration: 0.1,
        alternate: true,
        infinite: true,
      ),
    ));
  }
  
  /// Called when invulnerability period ends
  void _onInvulnerabilityEnd() {
    // Remove flashing effect
    removeWhere((component) => component is OpacityEffect);
    opacity = 1.0;
  }
  
  /// Increments combo multiplier
  void _incrementCombo() {
    comboMultiplier = math.min(maxComboMultiplier, comboMultiplier + 1);
  }
  
  /// Resets combo multiplier
  void _resetCombo() {
    comboMultiplier = 1;
  }
  
  /// Resets player state for new level
  void resetForNewLevel() {
    deselectTile();
    score = 0;
    _resetCombo();
    health = maxHealth;
    invulnerabilityTimer = 0.0;
    animationState = PlayerAnimationState.idle;
    opacity = 1.0;
    removeWhere((component) => component is OpacityEffect);
  }
  
  /// Plays selection feedback
  void _playSelectionFeedback() {
    // Add scale effect for selection
    add(ScaleEffect.to(
      Vector2.all(1.1),
      EffectController(duration: 0.1, alternate: true),
    ));
  }
  
  /// Plays invalid swap feedback
  void _playInvalidSwapFeedback() {
    // Add shake effect for invalid moves
    add(MoveEffect.by(
      Vector2(5, 0),
      EffectController(duration: 0.05, alternate: true, repeatCount: 3),
    ));
  }
  
  /// Plays successful swap feedback
  void _playSwapFeedback() {
    // Add rotation effect for successful swaps
    add(RotateEffect.by(
      math.pi * 0.1,
      EffectController(duration: 0.2, alternate: true),
    ));
  }
  
  /// Plays damage feedback
  void _playDamageFeedback() {
    // Add red tint and shake for damage
    add(ColorEffect(
      const Color(0xFFFF6B6B),
      EffectController(duration: 0.3, alternate: true),
    ));
  }
  
  /// Plays heal feedback
  void _playHealFeedback() {
    // Add green tint and gentle pulse for healing
    add(ColorEffect(
      const Color(0xFF96CEB4),
      EffectController(duration: 0.3, alternate: true),
    ));
  }
  
  /// Gets current health percentage
  double get healthPercentage => health / maxHealth;
  
  /// Checks if player is at low health
  bool get isLowHealth => health <= 1;
  
  /// Checks if player is dead
  bool get isDead => health <= 0;
}

/// Animation states for the player component
enum PlayerAnimationState {
  idle,
  selecting,
  swapping,
  celebrating,
  damaged,
  healing,
}