import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Obstacle component that blocks tile swaps and creates puzzle challenges
class Obstacle extends PositionComponent with HasGameRef, CollisionCallbacks {
  /// Type of obstacle determining behavior and appearance
  final ObstacleType obstacleType;
  
  /// Whether this obstacle can be destroyed by player actions
  final bool isDestructible;
  
  /// Number of hits required to destroy (if destructible)
  int _hitPoints;
  
  /// Maximum hit points for this obstacle
  final int maxHitPoints;
  
  /// Visual sprite component
  late SpriteComponent _spriteComponent;
  
  /// Collision hitbox
  late RectangleHitbox _hitbox;
  
  /// Animation controller for visual effects
  late AnimationController _animationController;
  
  /// Whether obstacle is currently active
  bool _isActive = true;
  
  /// Damage dealt to player on collision
  final int damage;
  
  /// Movement speed for moving obstacles
  final double movementSpeed;
  
  /// Movement direction vector
  Vector2 _movementDirection = Vector2.zero();
  
  /// Spawn animation duration
  static const double _spawnDuration = 0.5;
  
  /// Destruction animation duration
  static const double _destructionDuration = 0.3;

  Obstacle({
    required this.obstacleType,
    required Vector2 position,
    required Vector2 size,
    this.isDestructible = false,
    this.maxHitPoints = 1,
    this.damage = 1,
    this.movementSpeed = 0.0,
    Vector2? movementDirection,
  }) : _hitPoints = maxHitPoints {
    this.position = position;
    this.size = size;
    _movementDirection = movementDirection ?? Vector2.zero();
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    try {
      await _setupVisuals();
      _setupCollision();
      _setupAnimations();
      await _playSpawnAnimation();
    } catch (e) {
      print('Error loading obstacle: $e');
      removeFromParent();
    }
  }

  /// Sets up visual representation based on obstacle type
  Future<void> _setupVisuals() async {
    switch (obstacleType) {
      case ObstacleType.crystal:
        _spriteComponent = SpriteComponent(
          sprite: await Sprite.load('obstacles/crystal_obstacle.png'),
          size: size,
        );
        break;
      case ObstacleType.rock:
        _spriteComponent = SpriteComponent(
          sprite: await Sprite.load('obstacles/rock_obstacle.png'),
          size: size,
        );
        break;
      case ObstacleType.ice:
        _spriteComponent = SpriteComponent(
          sprite: await Sprite.load('obstacles/ice_obstacle.png'),
          size: size,
        );
        break;
      case ObstacleType.spikes:
        _spriteComponent = SpriteComponent(
          sprite: await Sprite.load('obstacles/spikes_obstacle.png'),
          size: size,
        );
        break;
    }
    
    add(_spriteComponent);
  }

  /// Sets up collision detection
  void _setupCollision() {
    _hitbox = RectangleHitbox(
      size: size * 0.8, // Slightly smaller than visual for better gameplay
      position: size * 0.1, // Center the smaller hitbox
    );
    add(_hitbox);
  }

  /// Sets up animation effects
  void _setupAnimations() {
    // Add idle animation based on obstacle type
    switch (obstacleType) {
      case ObstacleType.crystal:
        _addCrystalGlowEffect();
        break;
      case ObstacleType.ice:
        _addIceShimmerEffect();
        break;
      case ObstacleType.spikes:
        _addSpikePulseEffect();
        break;
      default:
        break;
    }
  }

  /// Adds glowing effect for crystal obstacles
  void _addCrystalGlowEffect() {
    final glowEffect = ColorEffect(
      const Color(0x4DECDC4),
      const Offset(0.0, 0.3),
      EffectController(
        duration: 2.0,
        alternate: true,
        infinite: true,
      ),
    );
    _spriteComponent.add(glowEffect);
  }

  /// Adds shimmer effect for ice obstacles
  void _addIceShimmerEffect() {
    final shimmerEffect = OpacityEffect.to(
      0.7,
      EffectController(
        duration: 1.5,
        alternate: true,
        infinite: true,
      ),
    );
    _spriteComponent.add(shimmerEffect);
  }

  /// Adds pulsing effect for spike obstacles
  void _addSpikePulseEffect() {
    final pulseEffect = ScaleEffect.to(
      Vector2.all(1.1),
      EffectController(
        duration: 0.8,
        alternate: true,
        infinite: true,
      ),
    );
    _spriteComponent.add(pulseEffect);
  }

  /// Plays spawn animation when obstacle is created
  Future<void> _playSpawnAnimation() async {
    scale = Vector2.zero();
    
    final spawnEffect = ScaleEffect.to(
      Vector2.all(1.0),
      EffectController(
        duration: _spawnDuration,
        curve: Curves.elasticOut,
      ),
    );
    
    add(spawnEffect);
    await spawnEffect.completed;
  }

  @override
  void update(double dt) {
    super.update(dt);
    
    if (!_isActive) return;
    
    // Handle movement for moving obstacles
    if (movementSpeed > 0 && !_movementDirection.isZero()) {
      position += _movementDirection * movementSpeed * dt;
      _checkBounds();
    }
  }

  /// Checks if obstacle is within game bounds and handles boundary collision
  void _checkBounds() {
    final gameSize = gameRef.size;
    
    // Bounce off edges for moving obstacles
    if (position.x <= 0 || position.x + size.x >= gameSize.x) {
      _movementDirection.x *= -1;
      position.x = math.max(0, math.min(position.x, gameSize.x - size.x));
    }
    
    if (position.y <= 0 || position.y + size.y >= gameSize.y) {
      _movementDirection.y *= -1;
      position.y = math.max(0, math.min(position.y, gameSize.y - size.y));
    }
  }

  @override
  bool onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (!_isActive) return false;
    
    // Handle collision with player or tiles
    if (other.hasGameRef) {
      _handleCollision(other);
    }
    
    return true;
  }

  /// Handles collision with other game objects
  void _handleCollision(PositionComponent other) {
    // Deal damage or block movement based on obstacle type
    switch (obstacleType) {
      case ObstacleType.spikes:
        _dealDamage(other);
        break;
      case ObstacleType.crystal:
      case ObstacleType.rock:
      case ObstacleType.ice:
        _blockMovement(other);
        break;
    }
  }

  /// Deals damage to colliding object
  void _dealDamage(PositionComponent target) {
    // Trigger damage effect on target
    _playDamageEffect();
  }

  /// Blocks movement of colliding object
  void _blockMovement(PositionComponent target) {
    // Visual feedback for blocked movement
    _playBlockEffect();
  }

  /// Plays visual effect when dealing damage
  void _playDamageEffect() {
    final flashEffect = ColorEffect(
      Colors.red,
      const Offset(0.0, 0.5),
      EffectController(duration: 0.2),
    );
    _spriteComponent.add(flashEffect);
  }

  /// Plays visual effect when blocking movement
  void _playBlockEffect() {
    final shakeEffect = MoveEffect.by(
      Vector2(5, 0),
      EffectController(
        duration: 0.1,
        alternate: true,
        repeatCount: 3,
      ),
    );
    add(shakeEffect);
  }

  /// Attempts to damage the obstacle (for destructible obstacles)
  bool takeDamage(int damageAmount) {
    if (!isDestructible || !_isActive) return false;
    
    _hitPoints -= damageAmount;
    _playHitEffect();
    
    if (_hitPoints <= 0) {
      _destroy();
      return true;
    }
    
    return false;
  }

  /// Plays visual effect when obstacle takes damage
  void _playHitEffect() {
    final hitEffect = ColorEffect(
      Colors.white,
      const Offset(0.0, 0.3),
      EffectController(duration: 0.15),
    );
    _spriteComponent.add(hitEffect);
    
    // Shake effect
    final shakeEffect = MoveEffect.by(
      Vector2(3, 3),
      EffectController(
        duration: 0.1,
        alternate: true,
        repeatCount: 2,
      ),
    );
    add(shakeEffect);
  }

  /// Destroys the obstacle with animation
  Future<void> _destroy() async {
    _isActive = false;
    
    // Play destruction animation
    final destructionEffect = ScaleEffect.to(
      Vector2.zero(),
      EffectController(
        duration: _destructionDuration,
        curve: Curves.easeIn,
      ),
    );
    
    final fadeEffect = OpacityEffect.to(
      0.0,
      EffectController(duration: _destructionDuration),
    );
    
    add(destructionEffect);
    add(fadeEffect);
    
    await destructionEffect.completed;
    removeFromParent();
  }

  /// Gets current hit points
  int get hitPoints => _hitPoints;
  
  /// Gets hit points as percentage of max
  double get hitPointsPercentage => _hitPoints / maxHitPoints;
  
  /// Whether obstacle is currently active
  bool get isActive => _isActive;
  
  /// Deactivates the obstacle temporarily
  void deactivate() {
    _isActive = false;
    _spriteComponent.opacity = 0.5;
  }
  
  /// Reactivates the obstacle
  void activate() {
    _isActive = true;
    _spriteComponent.opacity = 1.0;
  }
}

/// Types of obstacles with different behaviors
enum ObstacleType {
  /// Crystal obstacles that can be destroyed by matching adjacent tiles
  crystal,
  
  /// Rock obstacles that permanently block tile swaps
  rock,
  
  /// Ice obstacles that melt after a certain number of moves
  ice,
  
  /// Spike obstacles that damage the player on contact
  spikes,
}