import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../game/game.dart';
import '../../services/analytics_service.dart';
import '../overlays/game_overlay.dart';
import '../overlays/pause_overlay.dart';
import '../overlays/level_complete_overlay.dart';
import '../overlays/game_over_overlay.dart';

/// Main game screen containing the Flame game widget
class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late Batch-20260107-110734-puzzle-01Game game;

  @override
  void initState() {
    super.initState();
    game = Batch-20260107-110734-puzzle-01Game();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    game.analyticsService = Provider.of<AnalyticsService>(context, listen: false);
    game.analyticsService.logGameStart();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GameWidget(
        game: game,
        overlayBuilderMap: {
          'GameOverlay': (context, game) => GameOverlay(game: game),
          'PauseOverlay': (context, game) => PauseOverlay(game: game),
          'LevelCompleteOverlay': (context, game) => LevelCompleteOverlay(game: game),
          'GameOverOverlay': (context, game) => GameOverOverlay(game: game),
        },
        initialActiveOverlays: const ['GameOverlay'],
      ),
    );
  }
}
