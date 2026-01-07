import 'dart:async';
import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Main game class for the tile-swapping puzzle game
class Batch20260107110734Puzzle01Game extends FlameGame
    with HasDragEvents, HasTapEvents, HasCollisionDetection {
  
  /// Current game state
  GameState _gameState = GameState.menu;
  GameState get gameState => _gameState;
  
  /// Current level being played
  int _currentLevel = 1;
  int get currentLevel => _currentLevel;
  
  /// Player's current score
  int _score = 0;
  int get score => _score;
  
  /// Player's gems (currency)
  int _gems = 0;
  int get gems => _gems;
  
  /// Time remaining in current level
  double _timeRemaining = 90.0;
  double get timeRemaining => _timeRemaining;
  
  /// Grid dimensions for current level
  int _gridWidth = 3;
  int _gridHeight = 3;
  
  /// Game components
  late GameGrid _gameGrid;
  late Timer _gameTimer;
  late ScoreManager _scoreManager;
  late LevelManager _levelManager;
  late PatternManager _patternManager;
  
  /// Analytics and services hooks
  Function(String event, Map<String, dynamic> parameters)? onAnalyticsEvent;
  Function()? onShowRewardedAd;
  Function(String key, dynamic value)? onSaveData;
  Function(String key)? onLoadData;
  
  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    // Initialize managers
    _scoreManager = ScoreManager();
    _levelManager = LevelManager();
    _patternManager = PatternManager();
    
    // Load saved data
    await _loadGameData();
    
    // Initialize game timer
    _gameTimer = Timer(
      1.0,
      repeat: true,
      onTick: _updateTimer,
    );
    
    // Set up initial state
    _changeGameState(GameState.menu);
    
    // Track game start
    _trackEvent('game_start', {
      'level': _currentLevel,
      'gems': _gems,
    });
  }
  
  @override
  void update(double dt) {
    super.update(dt);
    
    if (_gameState == GameState.playing) {
      _gameTimer.update(dt);
      _gameGrid.update(dt);
      _checkWinCondition();
      _checkFailCondition();
    }
  }
  
  /// Start a new level
  void startLevel(int level) {
    try {
      _currentLevel = level;
      final levelConfig = _levelManager.getLevelConfig(level);
      
      _gridWidth = levelConfig.gridWidth;
      _gridHeight = levelConfig.gridHeight;
      _timeRemaining = levelConfig.timeLimit;
      
      // Create new game grid
      _gameGrid = GameGrid(
        width: _gridWidth,
        height: _gridHeight,
        tileSize: 60.0,
        position: Vector2(size.x / 2, size.y / 2),
      );
      
      // Set target patterns
      _patternManager.setTargetPatterns(levelConfig.targetPatterns);
      
      // Add grid to world
      world.removeAll(world.children.whereType<GameGrid>());
      world.add(_gameGrid);
      
      _changeGameState(GameState.playing);
      
      _trackEvent('level_start', {
        'level': level,
        'grid_size': '${_gridWidth}x$_gridHeight',
        'time_limit': _timeRemaining,
      });
    } catch (e) {
      debugPrint('Error starting level $level: $e');
      _changeGameState(GameState.menu);
    }
  }
  
  /// Handle tile swap
  void swapTiles(Vector2 pos1, Vector2 pos2) {
    if (_gameState != GameState.playing) return;
    
    try {
      if (_gameGrid.canSwapTiles(pos1, pos2)) {
        _gameGrid.swapTiles(pos1, pos2);
        
        // Check for matches after swap
        final matches = _patternManager.checkMatches(_gameGrid.getTileGrid());
        if (matches.isNotEmpty) {
          _processMatches(matches);
        }
        
        HapticFeedback.lightImpact();
      }
    } catch (e) {
      debugPrint('Error swapping tiles: $e');
    }
  }
  
  /// Process pattern matches
  void _processMatches(List<PatternMatch> matches) {
    int pointsEarned = 0;
    
    for (final match in matches) {
      pointsEarned += match.points;
      
      // Add bonus time for chain matches
      if (match.isChain) {
        _timeRemaining += 5.0;
      }
    }
    
    _addScore(pointsEarned);
    _gameGrid.highlightMatches(matches);
  }
  
  /// Add score and update gems
  void _addScore(int points) {
    _score += points;
    
    // Convert score to gems (every 100 points = 1 gem)
    final newGems = (_score ~/ 100) - (_gems);
    if (newGems > 0) {
      _gems += newGems;
    }
  }
  
  /// Check if level is complete
  void _checkWinCondition() {
    if (_patternManager.areAllPatternsComplete(_gameGrid.getTileGrid())) {
      _completeLevel();
    }
  }
  
  /// Check if level has failed
  void _checkFailCondition() {
    if (_timeRemaining <= 0) {
      _failLevel('timer_expires');
    } else if (!_gameGrid.hasValidMoves()) {
      _failLevel('no_valid_moves_remaining');
    }
  }
  
  /// Complete current level
  void _completeLevel() {
    _changeGameState(GameState.levelComplete);
    
    // Calculate bonus gems
    final timeBonus = (_timeRemaining / 10).floor();
    final levelBonus = 10; // Base gems per level
    final totalBonus = timeBonus + levelBonus;
    
    _gems += totalBonus;
    
    _trackEvent('level_complete', {
      'level': _currentLevel,
      'score': _score,
      'time_remaining': _timeRemaining,
      'gems_earned': totalBonus,
    });
    
    _saveGameData();
  }
  
  /// Fail current level
  void _failLevel(String reason) {
    _changeGameState(GameState.gameOver);
    
    _trackEvent('level_fail', {
      'level': _currentLevel,
      'reason': reason,
      'score': _score,
      'time_remaining': _timeRemaining,
    });
  }
  
  /// Update game timer
  void _updateTimer() {
    if (_gameState == GameState.playing && _timeRemaining > 0) {
      _timeRemaining -= 1.0;
    }
  }
  
  /// Change game state and update overlays
  void _changeGameState(GameState newState) {
    _gameState = newState;
    
    // Remove all overlays
    overlays.clear();
    
    // Add appropriate overlay for new state
    switch (newState) {
      case GameState.menu:
        overlays.add('MainMenu');
        break;
      case GameState.playing:
        overlays.add('GameHUD');
        break;
      case GameState.paused:
        overlays.add('PauseMenu');
        break;
      case GameState.gameOver:
        overlays.add('GameOver');
        break;
      case GameState.levelComplete:
        overlays.add('LevelComplete');
        break;
    }
  }
  
  /// Pause the game
  void pauseGame() {
    if (_gameState == GameState.playing) {
      _changeGameState(GameState.paused);
      _gameTimer.stop();
    }
  }
  
  /// Resume the game
  void resumeGame() {
    if (_gameState == GameState.paused) {
      _changeGameState(GameState.playing);
      _gameTimer.start();
    }
  }
  
  /// Restart current level
  void restartLevel() {
    startLevel(_currentLevel);
  }
  
  /// Use hint (costs gems)
  void useHint() {
    if (_gems >= 5 && _gameState == GameState.playing) {
      _gems -= 5;
      final hint = _gameGrid.getHint();
      if (hint != null) {
        _gameGrid.showHint(hint);
      }
      _saveGameData();
    }
  }
  
  /// Extend time (costs gems)
  void extendTime() {
    if (_gems >= 10 && _gameState == GameState.playing) {
      _gems -= 10;
      _timeRemaining += 30.0;
      _saveGameData();
    }
  }
  
  /// Reveal pattern (costs gems)
  void revealPattern() {
    if (_gems >= 15 && _gameState == GameState.playing) {
      _gems -= 15;
      _patternManager.revealNextPattern();
      _saveGameData();
    }
  }
  
  /// Check if level is unlocked
  bool isLevelUnlocked(int level) {
    return _levelManager.isLevelUnlocked(level);
  }
  
  /// Unlock level with rewarded ad
  void unlockLevelWithAd(int level) {
    _trackEvent('unlock_prompt_shown', {'level': level});
    
    if (onShowRewardedAd != null) {
      onShowRewardedAd!();
    }
  }
  
  /// Handle rewarded ad completion
  void onRewardedAdCompleted(int level) {
    _levelManager.unlockLevel(level);
    _trackEvent('rewarded_ad_completed', {'level': level});
    _trackEvent('level_unlocked', {'level': level});
    _saveGameData();
  }
  
  /// Handle rewarded ad failure
  void onRewardedAdFailed() {
    _trackEvent('rewarded_ad_failed', {});
  }
  
  /// Save game data
  void _saveGameData() {
    if (onSaveData != null) {
      onSaveData!('current_level', _currentLevel);
      onSaveData!('gems', _gems);
      onSaveData!('unlocked_levels', _levelManager.getUnlockedLevels());
    }
  }
  
  /// Load game data
  Future<void> _loadGameData() async {
    try {
      if (onLoadData != null) {
        _currentLevel = await onLoadData!('current_level') ?? 1;
        _gems = await onLoadData!('gems') ?? 0;
        final unlockedLevels = await onLoadData!('unlocked_levels') ?? [1, 2, 3];
        _levelManager.setUnlockedLevels(List<int>.from(unlockedLevels));
      }
    } catch (e) {
      debugPrint('Error loading game data: $e');
    }
  }
  
  /// Track analytics event
  void _trackEvent(String event, Map<String, dynamic> parameters) {
    if (onAnalyticsEvent != null) {
      onAnalyticsEvent!(event, parameters);
    }
  }
  
  @override
  bool onDragStart(DragStartEvent event) {
    if (_gameState == GameState.playing) {
      _gameGrid.onDragStart(event.localPosition);
    }
    return true;
  }
  
  @override
  bool onDragUpdate(DragUpdateEvent event) {
    if (_gameState == GameState.playing) {
      _gameGrid.onDragUpdate(event.localPosition);
    }
    return true;
  }
  
  @override
  bool onDragEnd(DragEndEvent event) {
    if (_gameState == GameState.playing) {
      _gameGrid.onDragEnd(event.localPosition);
    }
    return true;
  }
}

/// Game state enumeration
enum GameState {
  menu,
  playing,
  paused,
  gameOver,
  levelComplete,
}

/// Game grid component for managing tiles
class GameGrid extends Component {
  final int width;
  final int height;
  final double tileSize;
  final Vector2 position;
  
  late List<List<GameTile>> _tiles;
  Vector2? _dragStart;
  Vector2? _dragCurrent;
  
  GameGrid({
    required this.width,
    required this.height,
    required this.tileSize,
    required this.position,
  });
  
  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _initializeTiles();
  }
  
  void _initializeTiles() {
    _tiles = List.generate(height, (y) =>
        List.generate(width, (x) => GameTile(
          gridX: x,
          gridY: y,
          color: TileColor.values[Random().nextInt(TileColor.values.length)],
          size: tileSize,
        ))
    );
    
    // Add tiles to component tree
    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final tile = _tiles[y][x];
        tile.position = Vector2(
          position.x + (x - width / 2) * tileSize,
          position.y + (y - height / 2) * tileSize,
        );
        add(tile);
      }
    }
  }
  
  bool canSwapTiles(Vector2 pos1, Vector2 pos2) {
    final tile1 = _getTileAtPosition(pos1);
    final tile2 = _getTileAtPosition(pos2);
    
    if (tile1 == null || tile2 == null) return false;
    
    // Check if tiles are adjacent
    final dx = (tile1.gridX - tile2.gridX).abs();
    final dy = (tile1.gridY - tile2.gridY).abs();
    
    return (dx == 1 && dy == 0) || (dx == 0 && dy == 1);
  }
  
  void swapTiles(Vector2 pos1, Vector2 pos2) {
    final tile1 = _getTileAtPosition(pos1);
    final tile2 = _getTileAtPosition(pos2);
    
    if (tile1 != null && tile2 != null) {
      // Swap colors
      final tempColor = tile1.color;
      tile1.color = tile2.color;
      tile2.color = tempColor;
      
      // Animate swap
      tile1.animateSwap();
      tile2.animateSwap();
    }
  }
  
  GameTile? _getTileAtPosition(Vector2 pos) {
    final gridX = ((pos.x - position.x) / tileSize + width / 2).floor();
    final gridY = ((pos.y - position.y) / tileSize + height / 2).floor();
    
    if (gridX >= 0 && gridX < width && gridY >= 0 && gridY < height) {
      return _tiles[gridY][gridX];
    }
    return null;
  }
  
  List<List<TileColor>> getTileGrid() {
    return _tiles.map((row) => row.map((tile) => tile.color).toList()).toList();
  }
  
  bool hasVali