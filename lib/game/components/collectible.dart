import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/material.dart';

class Collectible extends PositionComponent with CollisionCallbacks {
  final int value;
  double _floatOffset = 0;

  Collectible({
    required Vector2 position,
    this.value = 10,
  }) : super(
          position: position,
          size: Vector2(30, 30),
          anchor: Anchor.center,
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(CircleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);
    
    position.y += 80 * dt;
    
    _floatOffset += dt * 5;
    position.x += (0.5 * ((_floatOffset % 2) < 1 ? 1 : -1));
    
    if (position.y > 900) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    canvas.drawCircle(
      Offset(size.x / 2, size.y / 2),
      size.x / 2,
      Paint()..color = Colors.amber,
    );
  }

  void collect() {
    removeFromParent();
  }
}
