import 'package:flame/components.dart';
import 'game.dart';

class InputHandler {
  final dynamic game;

  InputHandler(this.game);

  void onTapDown(Vector2 position) {
    // Primary action: swipe
    final player = game.player;
    
    // Move player towards tap position
    if (position.x < game.size.x / 2) {
      player.moveLeft();
    } else {
      player.moveRight();
    }
  }

  void onDrag(Vector2 delta) {
    final player = game.player;
    
    if (delta.x.abs() > delta.y.abs()) {
      if (delta.x < 0) {
        player.moveLeft();
      } else {
        player.moveRight();
      }
    } else {
      if (delta.y < 0) {
        player.moveUp();
      } else {
        player.moveDown();
      }
    }
  }
}
