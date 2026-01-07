import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Main menu scene component for the puzzle game
class MenuScene extends Component with HasGameRef, TapCallbacks {
  late TextComponent titleComponent;
  late RectangleComponent playButton;
  late TextComponent playButtonText;
  late RectangleComponent levelSelectButton;
  late TextComponent levelSelectButtonText;
  late RectangleComponent settingsButton;
  late TextComponent settingsButtonText;
  late List<CircleComponent> backgroundParticles;
  
  double animationTime = 0.0;
  final int particleCount = 20;
  
  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    final gameSize = gameRef.size;
    
    // Initialize background particles for animation
    _createBackgroundParticles(gameSize);
    
    // Create title
    titleComponent = TextComponent(
      text: 'Tile Swap Puzzle',
      textRenderer: TextPaint(
        style: const TextStyle(
          fontSize: 48,
          fontWeight: FontWeight.bold,
          color: Color(0xFF4ECDC4),
          shadows: [
            Shadow(
              offset: Offset(2, 2),
              blurRadius: 4,
              color: Colors.black26,
            ),
          ],
        ),
      ),
      anchor: Anchor.center,
      position: Vector2(gameSize.x / 2, gameSize.y * 0.25),
    );
    add(titleComponent);
    
    // Create play button
    playButton = RectangleComponent(
      size: Vector2(200, 60),
      position: Vector2(gameSize.x / 2 - 100, gameSize.y * 0.45),
      paint: Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFF45B7D1), Color(0xFF4ECDC4)],
        ).createShader(Rect.fromLTWH(0, 0, 200, 60)),
    );
    playButton.add(RectangleComponent(
      size: Vector2(196, 56),
      position: Vector2(2, 2),
      paint: Paint()..color = Colors.white.withOpacity(0.1),
    ));
    add(playButton);
    
    playButtonText = TextComponent(
      text: 'PLAY',
      textRenderer: TextPaint(
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      anchor: Anchor.center,
      position: Vector2(gameSize.x / 2, gameSize.y * 0.45 + 30),
    );
    add(playButtonText);
    
    // Create level select button
    levelSelectButton = RectangleComponent(
      size: Vector2(200, 50),
      position: Vector2(gameSize.x / 2 - 100, gameSize.y * 0.6),
      paint: Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFF96CEB4), Color(0xFFFFEAA7)],
        ).createShader(Rect.fromLTWH(0, 0, 200, 50)),
    );
    levelSelectButton.add(RectangleComponent(
      size: Vector2(196, 46),
      position: Vector2(2, 2),
      paint: Paint()..color = Colors.white.withOpacity(0.1),
    ));
    add(levelSelectButton);
    
    levelSelectButtonText = TextComponent(
      text: 'LEVEL SELECT',
      textRenderer: TextPaint(
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      anchor: Anchor.center,
      position: Vector2(gameSize.x / 2, gameSize.y * 0.6 + 25),
    );
    add(levelSelectButtonText);
    
    // Create settings button
    settingsButton = RectangleComponent(
      size: Vector2(200, 50),
      position: Vector2(gameSize.x / 2 - 100, gameSize.y * 0.72),
      paint: Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFFFF6B6B), Color(0xFFFFEAA7)],
        ).createShader(Rect.fromLTWH(0, 0, 200, 50)),
    );
    settingsButton.add(RectangleComponent(
      size: Vector2(196, 46),
      position: Vector2(2, 2),
      paint: Paint()..color = Colors.white.withOpacity(0.1),
    ));
    add(settingsButton);
    
    settingsButtonText = TextComponent(
      text: 'SETTINGS',
      textRenderer: TextPaint(
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      anchor: Anchor.center,
      position: Vector2(gameSize.x / 2, gameSize.y * 0.72 + 25),
    );
    add(settingsButtonText);
  }
  
  /// Creates animated background particles
  void _createBackgroundParticles(Vector2 gameSize) {
    backgroundParticles = [];
    final random = math.Random();
    
    for (int i = 0; i < particleCount; i++) {
      final particle = CircleComponent(
        radius: random.nextDouble() * 8 + 4,
        position: Vector2(
          random.nextDouble() * gameSize.x,
          random.nextDouble() * gameSize.y,
        ),
        paint: Paint()
          ..color = [
            const Color(0xFF4ECDC4),
            const Color(0xFF45B7D1),
            const Color(0xFF96CEB4),
            const Color(0xFFFFEAA7),
          ][random.nextInt(4)].withOpacity(0.3),
      );
      
      backgroundParticles.add(particle);
      add(particle);
    }
  }
  
  @override
  void update(double dt) {
    super.update(dt);
    
    animationTime += dt;
    
    // Animate title with gentle floating effect
    titleComponent.position.y = gameRef.size.y * 0.25 + 
        math.sin(animationTime * 2) * 5;
    
    // Animate background particles
    for (int i = 0; i < backgroundParticles.length; i++) {
      final particle = backgroundParticles[i];
      
      // Gentle floating motion
      particle.position.y += math.sin(animationTime + i) * 0.5;
      particle.position.x += math.cos(animationTime * 0.5 + i) * 0.3;
      
      // Wrap around screen edges
      if (particle.position.x < -particle.radius) {
        particle.position.x = gameRef.size.x + particle.radius;
      } else if (particle.position.x > gameRef.size.x + particle.radius) {
        particle.position.x = -particle.radius;
      }
      
      if (particle.position.y < -particle.radius) {
        particle.position.y = gameRef.size.y + particle.radius;
      } else if (particle.position.y > gameRef.size.y + particle.radius) {
        particle.position.y = -particle.radius;
      }
      
      // Pulsing opacity effect
      final opacity = 0.2 + (math.sin(animationTime * 3 + i) + 1) * 0.15;
      particle.paint.color = particle.paint.color.withOpacity(opacity);
    }
    
    // Button hover effects
    final playScale = 1.0 + math.sin(animationTime * 4) * 0.02;
    playButton.scale = Vector2.all(playScale);
    playButtonText.scale = Vector2.all(playScale);
  }
  
  @override
  bool onTapDown(TapDownEvent event) {
    final tapPosition = event.localPosition;
    
    // Check play button tap
    if (_isPointInButton(tapPosition, playButton)) {
      _onPlayButtonPressed();
      return true;
    }
    
    // Check level select button tap
    if (_isPointInButton(tapPosition, levelSelectButton)) {
      _onLevelSelectButtonPressed();
      return true;
    }
    
    // Check settings button tap
    if (_isPointInButton(tapPosition, settingsButton)) {
      _onSettingsButtonPressed();
      return true;
    }
    
    return false;
  }
  
  /// Checks if a point is within a button's bounds
  bool _isPointInButton(Vector2 point, RectangleComponent button) {
    return point.x >= button.position.x &&
           point.x <= button.position.x + button.size.x &&
           point.y >= button.position.y &&
           point.y <= button.position.y + button.size.y;
  }
  
  /// Handles play button press
  void _onPlayButtonPressed() {
    try {
      // Add button press animation
      playButton.scale = Vector2.all(0.95);
      playButtonText.scale = Vector2.all(0.95);
      
      // TODO: Navigate to game scene
      print('Play button pressed - starting game');
    } catch (e) {
      print('Error handling play button press: $e');
    }
  }
  
  /// Handles level select button press
  void _onLevelSelectButtonPressed() {
    try {
      // Add button press animation
      levelSelectButton.scale = Vector2.all(0.95);
      levelSelectButtonText.scale = Vector2.all(0.95);
      
      // TODO: Navigate to level select scene
      print('Level select button pressed');
    } catch (e) {
      print('Error handling level select button press: $e');
    }
  }
  
  /// Handles settings button press
  void _onSettingsButtonPressed() {
    try {
      // Add button press animation
      settingsButton.scale = Vector2.all(0.95);
      settingsButtonText.scale = Vector2.all(0.95);
      
      // TODO: Navigate to settings scene
      print('Settings button pressed');
    } catch (e) {
      print('Error handling settings button press: $e');
    }
  }
}