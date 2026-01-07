import 'dart:async';
import 'dart:math';
import 'package:flame/cache.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../components/game_grid.dart';
import '../components/tile_component.dart';
import '../components/pattern_display.dart';
import '../components/timer_component.dart';
import '../components/score_display.dart';
import '../components/gems_display.dart';
import '../controllers/game_controller.dart';
import '../models/level_config.dart';
import '../models/game_state.dart';
import '../services/analytics_service.dart';
import '../services/audio_service.dart';
import '../utils/constants.dart';

/// Main game class for the tile-swapping puzzle game
class Batch20260107110734Puzzle01Game extends FlameGame
    with HasTapDetector, HasDragDetector, HasCollisionDetection {
  
  /// Current game state
  GameState gameState = GameState.playing;
  
  /// Game controller for managing game logic
  late GameController gameController;
  
  /// Analytics service for tracking events
  late AnalyticsService analyticsService;
  
  /// Audio service for sound effects
  late AudioService audioService;
  
  /// Current level configuration
  LevelConfig? currentLevel;
  
  /// Game grid component
  GameGrid? gameGrid;
  
  /// Pattern display component
  PatternDisplay? patternDisplay;
  
  /// Timer component
  TimerComponent? timerComponent;
  
  /// Score display component
  ScoreDisplay? scoreDisplay;
  
  /// Gems display component
  GemsDisplay? gemsDisplay;
  
  /// Current score
  int score = 0;
  
  /// Current gems count
  int gems = 0;
  
  /// Current level number
  int currentLevelNumber = 1;
  
  /// Time remaining in seconds
  double timeRemaining = 0;
  
  /// Whether the game is paused
  bool isPaused = false;
  
  /// Selected tile for swapping
  TileComponent? selectedTile;
  
  /// Background component
  SpriteComponent? background;
  
  /// Particle effects
  final List<Component> particles = [];
  
  @override
  Future<void> onLoad() async {
    super.onLoad();
    
    // Initialize services
    gameController = GameController();
    analyticsService = AnalyticsService();
    audioService = AudioService();
    
    // Set up camera
    camera.viewfinder.visibleGameSize = size;
    
    // Load background
    await _loadBackground();
    
    // Initialize UI components
    await _initializeUI();
    
    // Load first level
    await loadLevel(1);
    
    // Log game start
    analyticsService.logEvent('game_start', {
      'level': currentLevelNumber,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }
  
  /// Load background sprite
  Future<void> _loadBackground() async {
    try {
      final backgroundSprite = await Sprite.load('backgrounds/crystal_cave.png');
      background = SpriteComponent(
        sprite: backgroundSprite,
        size: size,
        position: Vector2.zero(),
      );
      add(background!);
    } catch (e) {
      // Fallback to colored background
      final coloredBackground = RectangleComponent(
        size: size,
        paint: Paint()..color = const Color(0xFF2C3E50),
      );
      add(coloredBackground);
    }
  }
  
  /// Initialize UI components
  Future<void> _initializeUI() async {
    // Score display
    scoreDisplay = ScoreDisplay(
      position: Vector2(20, 60),
      score: score,
    );
    add(scoreDisplay!);
    
    // Gems display
    gemsDisplay = GemsDisplay(
      position: Vector2(size.x - 120, 60),
      gems: gems,
    );
    add(gemsDisplay!);
    
    // Timer component
    timerComponent = TimerComponent(
      position: Vector2(size.x / 2 - 50, 60),
      timeRemaining: timeRemaining,
    );
    add(timerComponent!);
  }
  
  /// Load a specific level
  Future<void> loadLevel(int levelNumber) async {
    try {
      // Clear existing components
      await _clearLevel();
      
      // Load level configuration
      currentLevel = await gameController.loadLevel(levelNumber);
      currentLevelNumber = levelNumber;
      
      if (currentLevel == null) {
        throw Exception('Failed to load level $levelNumber');
      }
      
      // Set initial time
      timeRemaining = currentLevel!.timeLimit.toDouble();
      timerComponent?.updateTime(timeRemaining);
      
      // Create game grid
      gameGrid = GameGrid(
        gridSize: currentLevel!.gridSize,
        position: Vector2(
          size.x / 2 - (currentLevel!.gridSize * GameConstants.tileSize) / 2,
          size.y / 2 - (currentLevel!.gridSize * GameConstants.tileSize) / 2,
        ),
        tileColors: currentLevel!.availableColors,
      );
      add(gameGrid!);
      
      // Create pattern display
      patternDisplay = PatternDisplay(
        patterns: currentLevel!.targetPatterns,
        position: Vector2(20, 120),
      );
      add(patternDisplay!);
      
      // Generate initial grid
      await gameGrid!.generateGrid();
      
      // Set game state
      gameState = GameState.playing;
      isPaused = false;
      
      // Log level start
      analyticsService.logEvent('level_start', {
        'level': levelNumber,
        'grid_size': currentLevel!.gridSize,
        'time_limit': currentLevel!.timeLimit,
        'pattern_count': currentLevel!.targetPatterns.length,
      });
      
    } catch (e) {
      print('Error loading level $levelNumber: $e');
      gameState = GameState.gameOver;
    }
  }
  
  /// Clear current level components
  Future<void> _clearLevel() async {
    gameGrid?.removeFromParent();
    patternDisplay?.removeFromParent();
    selectedTile = null;
    
    // Clear particles
    for (final particle in particles) {
      particle.removeFromParent();
    }
    particles.clear();
  }
  
  @override
  void update(double dt) {
    super.update(dt);
    
    if (gameState != GameState.playing || isPaused) {
      return;
    }
    
    // Update timer
    timeRemaining -= dt;
    timerComponent?.updateTime(timeRemaining);
    
    // Check for time up
    if (timeRemaining <= 0) {
      _handleTimeUp();
      return;
    }
    
    // Check for level completion
    if (_checkLevelComplete()) {
      _handleLevelComplete();
      return;
    }
    
    // Check for no valid moves
    if (_checkNoValidMoves()) {
      _handleNoValidMoves();
      return;
    }
  }
  
  /// Handle tap events
  @override
  bool onTapDown(TapDownInfo info) {
    if (gameState != GameState.playing || isPaused) {
      return false;
    }
    
    final tappedTile = gameGrid?.getTileAtPosition(info.eventPosition.global);
    if (tappedTile != null) {
      _handleTileSelection(tappedTile);
    }
    
    return true;
  }
  
  /// Handle drag events for tile swapping
  @override
  bool onDragUpdate(DragUpdateInfo info) {
    if (gameState != GameState.playing || isPaused || selectedTile == null) {
      return false;
    }
    
    final draggedTile = gameGrid?.getTileAtPosition(info.eventPosition.global);
    if (draggedTile != null && draggedTile != selectedTile) {
      _attemptTileSwap(selectedTile!, draggedTile);
    }
    
    return true;
  }
  
  /// Handle tile selection
  void _handleTileSelection(TileComponent tile) {
    if (selectedTile == tile) {
      // Deselect if same tile
      selectedTile?.setSelected(false);
      selectedTile = null;
    } else if (selectedTile == null) {
      // Select new tile
      selectedTile = tile;
      tile.setSelected(true);
      audioService.playSound('tile_select');
    } else {
      // Attempt swap with previously selected tile
      _attemptTileSwap(selectedTile!, tile);
    }
  }
  
  /// Attempt to swap two tiles
  void _attemptTileSwap(TileComponent tile1, TileComponent tile2) {
    if (!gameGrid!.areAdjacent(tile1, tile2)) {
      // Not adjacent, just select the new tile
      selectedTile?.setSelected(false);
      selectedTile = tile2;
      tile2.setSelected(true);
      return;
    }
    
    // Perform swap
    gameGrid!.swapTiles(tile1, tile2);
    
    // Clear selection
    selectedTile?.setSelected(false);
    selectedTile = null;
    
    // Play swap sound
    audioService.playSound('tile_swap');
    
    // Check for matches
    final matches = gameGrid!.findMatches();
    if (matches.isNotEmpty) {
      _handleMatches(matches);
    }
    
    // Add particle effect
    _addSwapParticles(tile1.position, tile2.position);
  }
  
  /// Handle found matches
  void _handleMatches(List<List<TileComponent>> matches) {
    int matchScore = 0;
    
    for (final match in matches) {
      matchScore += match.length * GameConstants.pointsPerTile;
      
      // Add particle effects for matched tiles
      for (final tile in match) {
        _addMatchParticles(tile.position);
      }
    }
    
    // Update score
    score += matchScore;
    scoreDisplay?.updateScore(score);
    
    // Play match sound
    audioService.playSound('match_found');
    
    // Check for chain bonus
    if (matches.length > 1) {
      final chainBonus = matches.length * GameConstants.chainBonusMultiplier;
      score += chainBonus;
      timeRemaining += GameConstants.chainTimeBonus;
      
      audioService.playSound('chain_bonus');
      _showFloatingText('+${chainBonus}', Vector2(size.x / 2, size.y / 2));
    }
    
    // Log match event
    analyticsService.logEvent('match_found', {
      'level': currentLevelNumber,
      'match_count': matches.length,
      'score_gained': matchScore,
      'total_score': score,
    });
  }
  
  /// Check if level is complete
  bool _checkLevelComplete() {
    if (currentLevel == null || gameGrid == null) return false;
    
    return gameGrid!.checkPatternsComplete(currentLevel!.targetPatterns);
  }
  
  /// Check if there are no valid moves remaining
  bool _checkNoValidMoves() {
    if (gameGrid == null) return false;
    
    return !gameGrid!.hasValidMoves();
  }
  
  /// Handle level completion
  void _handleLevelComplete() {
    gameState = GameState.levelComplete;
    
    // Calculate final score with time bonus
    final timeBonus = (timeRemaining * GameConstants.timeBonusMultiplier).round();
    score += timeBonus;
    scoreDisplay?.updateScore(score);
    
    // Award gems
    gems += currentLevel!.gemReward;
    gemsDisplay?.updateGems(gems);
    
    // Play completion sound
    audioService.playSound('level_complete');
    
    // Add celebration particles
    _addCelebrationParticles();
    
    // Log level completion
    analyticsService.logEvent('level_complete', {
      'level': currentLevelNumber,
      'final_score': score,
      'time_remaining': timeRemaining,
      'time_bonus': timeBonus,
      'gems_earned': currentLevel!.gemReward,
    });
    
    // Show completion overlay
    overlays.add('LevelCompleteOverlay');
  }
  
  /// Handle time running out
  void _handleTimeUp() {
    gameState = GameState.gameOver;
    
    // Play game over sound
    audioService.playSound('time_up');
    
    // Log level failure
    analyticsService.logEvent('level_fail', {
      'level': currentLevelNumber,
      'reason': 'timer_expires',
      'final_score': score,
      'time_remaining': 0,
    });
    
    // Show game over overlay
    overlays.add('GameOverOverlay');
  }
  
  /// Handle no valid moves remaining
  void _handleNoValidMoves() {
    gameState = GameState.gameOver;
    
    // Play game over sound
    audioService.playSound('no_moves');
    
    // Log level failure
    analyticsService.logEvent('level_fail', {
      'level': currentLevelNumber,
      'reason': 'no_valid_moves_remaining',
      'final_score': score,
      'time_remaining': timeRemaining,
    });
    
    // Show game over overlay
    overlays.add('GameOverOverlay');
  }
  
  /// Pause the game
  void pauseGame() {
    isPaused = true;
    overlays.add('PauseOverlay');
  }
  
  /// Resume the game
  void resumeGame() {
    isPaused = false;
    overlays.remove('PauseOverlay');
  }
  
  /// Restart current level
  Future<void> restartLevel() async {
    score = 0;
    scoreDisplay?.updateScore(score);
    
    await loadLevel(currentLevelNumber);
    
    overlays.remove('GameOverOverlay');
    overlays.remove('LevelCompleteOverlay');
  }
  
  /// Load next level
  Future<void> loadNextLevel() async {
    if (currentLevelNumber < GameConstants.maxLevels) {
      await loadLevel(currentLevelNumber + 1);
    }
    
    overlays.remove('LevelCompleteOverlay');
  }
  
  /// Use hint power-up
  void useHint() {
    if (gems >= GameConstants.hintCost && gameGrid != null) {
      gems -= GameConstants.hintCost;
      gemsDisplay?.updateGems(gems);
      
      final hint = gameGrid!.getHint();
      if (hint != null) {
        hint.showHint();
        audioService.playSound('hint_used');
        
        analyticsService.logEvent('hint_used', {
          'level': currentLevelNumber,
          'gems_spent': GameConstants.hintCost,
          'remaining_gems': gems,
        });
      }
    }
  }
  
  /// Use time extension power-up
  void useTimeExtension() {
    if (gems >= GameConstants.timeExtensionCost) {
      gems -= GameConstants.timeExtensionCost;
      gemsDisplay?.updateGems(gems);
      
      timeRemaining += GameConstants.timeExtensionAmount;
      timerComponent?.updateTime(timeRemaining);
      
      audioService.playSound('time_extension');
      _showFloatingText('+${GameConstants.timeExtensionAmount}s', 
                       Vector2(size.x / 2, size.y / 3));
      
      analyticsService.logEvent('time_extension_used', {