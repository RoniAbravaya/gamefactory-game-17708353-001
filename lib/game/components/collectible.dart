import 'dart:math';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flame_audio/flame_audio.dart';

/// Collectible item component that can be picked up by the player
/// Provides score value, animations, and sound effects
class Collectible extends SpriteComponent with HasCollisionDetection, CollisionCallbacks {
  /// Score value awarded when collected
  final int scoreValue;
  
  /// Whether this collectible has been collected
  bool _isCollected = false;
  
  /// Callback function triggered when collected
  final void Function(Collectible collectible)? onCollected;
  
  /// Sound effect to play when collected
  final String collectSoundPath;
  
  /// Animation speed multiplier
  final double animationSpeed;
  
  /// Floating animation amplitude
  final double floatAmplitude;
  
  /// Rotation speed for spinning animation
  final double rotationSpeed;

  Collectible({
    required Sprite sprite,
    required Vector2 position,
    required Vector2 size,
    this.scoreValue = 10,
    this.onCollected,
    this.collectSoundPath = 'collect_gem.wav',
    this.animationSpeed = 1.0,
    this.floatAmplitude = 5.0,
    this.rotationSpeed = 2.0,
  }) : super(
          sprite: sprite,
          position: position,
          size: size,
          anchor: Anchor.center,
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    // Add collision detection
    add(RectangleHitbox());
    
    // Start floating animation
    _startFloatingAnimation();
    
    // Start spinning animation
    _startSpinningAnimation();
    
    // Add sparkle effect
    _addSparkleEffect();
  }

  /// Starts the floating up and down animation
  void _startFloatingAnimation() {
    final originalY = position.y;
    
    add(
      MoveEffect.by(
        Vector2(0, -floatAmplitude),
        EffectController(
          duration: 1.5 / animationSpeed,
          alternate: true,
          infinite: true,
          curve: Curves.easeInOut,
        ),
      ),
    );
  }

  /// Starts the spinning rotation animation
  void _startSpinningAnimation() {
    add(
      RotateEffect.by(
        2 * pi,
        EffectController(
          duration: 3.0 / animationSpeed,
          infinite: true,
        ),
      ),
    );
  }

  /// Adds sparkle particle effect around the collectible
  void _addSparkleEffect() {
    final sparkleTimer = TimerComponent(
      period: 0.5,
      repeat: true,
      onTick: () {
        if (!_isCollected) {
          _createSparkleParticle();
        }
      },
    );
    add(sparkleTimer);
  }

  /// Creates a single sparkle particle
  void _createSparkleParticle() {
    final random = Random();
    final sparkle = CircleComponent(
      radius: 2.0,
      paint: Paint()..color = const Color(0xFFFFFFFF),
      position: Vector2(
        position.x + (random.nextDouble() - 0.5) * size.x,
        position.y + (random.nextDouble() - 0.5) * size.y,
      ),
    );
    
    parent?.add(sparkle);
    
    // Fade out and remove sparkle
    sparkle.add(
      OpacityEffect.fadeOut(
        EffectController(duration: 1.0),
        onComplete: () => sparkle.removeFromParent(),
      ),
    );
    
    // Move sparkle upward
    sparkle.add(
      MoveEffect.by(
        Vector2(0, -20),
        EffectController(duration: 1.0),
      ),
    );
  }

  @override
  bool onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (!_isCollected) {
      collect();
    }
    return true;
  }

  /// Handles the collection of this item
  void collect() {
    if (_isCollected) return;
    
    _isCollected = true;
    
    try {
      // Play collection sound effect
      FlameAudio.play(collectSoundPath);
    } catch (e) {
      // Silently handle audio loading errors
      print('Warning: Could not play collect sound: $e');
    }
    
    // Trigger collection callback
    onCollected?.call(this);
    
    // Start collection animation
    _playCollectionAnimation();
  }

  /// Plays the collection animation and removes the collectible
  void _playCollectionAnimation() {
    // Stop existing animations
    removeAll(children.whereType<Effect>());
    
    // Scale up and fade out
    add(
      ScaleEffect.to(
        Vector2.all(1.5),
        EffectController(duration: 0.3, curve: Curves.easeOut),
      ),
    );
    
    add(
      OpacityEffect.fadeOut(
        EffectController(duration: 0.3),
        onComplete: () {
          removeFromParent();
        },
      ),
    );
    
    // Add upward movement
    add(
      MoveEffect.by(
        Vector2(0, -30),
        EffectController(duration: 0.3, curve: Curves.easeOut),
      ),
    );
    
    // Create collection burst effect
    _createCollectionBurst();
  }

  /// Creates a burst effect when collected
  void _createCollectionBurst() {
    final random = Random();
    
    for (int i = 0; i < 8; i++) {
      final angle = (i / 8) * 2 * pi;
      final particle = CircleComponent(
        radius: 3.0,
        paint: Paint()..color = const Color(0xFFFFD700),
        position: position.clone(),
      );
      
      parent?.add(particle);
      
      // Move particles outward
      particle.add(
        MoveEffect.by(
          Vector2(cos(angle) * 40, sin(angle) * 40),
          EffectController(duration: 0.5, curve: Curves.easeOut),
        ),
      );
      
      // Fade out particles
      particle.add(
        OpacityEffect.fadeOut(
          EffectController(duration: 0.5),
          onComplete: () => particle.removeFromParent(),
        ),
      );
      
      // Scale down particles
      particle.add(
        ScaleEffect.to(
          Vector2.zero(),
          EffectController(duration: 0.5, curve: Curves.easeIn),
        ),
      );
    }
  }

  /// Returns whether this collectible has been collected
  bool get isCollected => _isCollected;

  /// Returns the score value of this collectible
  int get value => scoreValue;
}