import 'dart:math';
import 'package:flame/components.dart';
import 'obstacle.dart';
import 'collectible.dart';

class Spawner extends Component with HasGameRef {
  final double spawnRate;
  final Vector2 gameSize;
  double _timer = 0;
  final Random _random = Random();

  Spawner({
    required this.spawnRate,
    required this.gameSize,
  });

  @override
  void update(double dt) {
    super.update(dt);
    
    _timer += dt;
    
    if (_timer >= (1.0 / spawnRate)) {
      _timer = 0;
      _spawn();
    }
  }

  void _spawn() {
    final x = 50 + _random.nextDouble() * (gameSize.x - 100);
    
    if (_random.nextDouble() > 0.3) {
      final obstacle = Obstacle(
        position: Vector2(x, -50),
        size: Vector2(40 + _random.nextDouble() * 30, 40 + _random.nextDouble() * 30),
        moveSpeed: 100 + _random.nextDouble() * 100,
      );
      gameRef.add(obstacle);
    } else {
      final collectible = Collectible(
        position: Vector2(x, -30),
        value: 10 + _random.nextInt(20),
      );
      gameRef.add(collectible);
    }
  }
}
