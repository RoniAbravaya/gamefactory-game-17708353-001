import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/material.dart';

class Obstacle extends PositionComponent with CollisionCallbacks {
  final double moveSpeed;
  final Vector2 direction;

  Obstacle({
    required Vector2 position,
    required Vector2 size,
    this.moveSpeed = 150,
    this.direction = const Vector2(0, 1),
  }) : super(
          position: position,
          size: size,
          anchor: Anchor.center,
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(RectangleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);
    position += direction * moveSpeed * dt;
    
    if (position.y > 900 || position.y < -100 ||
        position.x > 500 || position.x < -100) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    canvas.drawRect(
      size.toRect(),
      Paint()..color = Colors.red,
    );
  }
}
