import 'game.dart';

class GameController {
  final dynamic game;
  double _elapsedTime = 0;

  GameController(this.game);

  void update(double dt) {
    _elapsedTime += dt;
    
    // Add game-specific logic here
    // e.g., difficulty scaling, special events, etc.
  }

  double get elapsedTime => _elapsedTime;

  void reset() {
    _elapsedTime = 0;
  }
}
