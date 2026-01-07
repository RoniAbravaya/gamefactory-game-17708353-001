import 'dart:async';
import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

/// Main game scene component that manages the puzzle game logic
class GameScene extends Component with HasGameRef, HasKeyboardHandlerComponents {
  /// Current level being played
  late int currentLevel;
  
  /// Game timer countdown
  late Timer gameTimer;
  
  /// Remaining time in seconds
  late double timeRemaining;
  
  /// Current score
  int score = 0;
  
  /// Gems earned this level
  int gemsEarned = 0;
  
  /// Game grid size based on level
  late int gridSize;
  
  /// 2D array representing the tile grid
  late List<List<TileComponent>> gameGrid;
  
  /// Target patterns to match
  late List<PatternComponent> targetPatterns;
  
  /// Currently selected tile for swapping
  TileComponent? selectedTile;
  
  /// Game state management
  bool isGameActive = false;
  bool isGamePaused = false;
  bool isGameComplete = false;
  
  /// UI Components
  late TextComponent scoreText;
  late TextComponent timerText;
  late TextComponent gemsText;
  late RectangleComponent gameBoard;
  late Component patternDisplay;
  
  /// Background and visual effects
  late SpriteComponent background;
  late ParticleSystemComponent sparkleEffect;
  
  /// Random number generator
  final Random _random = Random();
  
  /// Available tile colors based on game context
  final List<Color> tileColors = [
    const Color(0xFFFF6B6B), // Red
    const Color(0xFF4ECDC4), // Teal
    const Color(0xFF45B7D1), // Blue
    const Color(0xFF96CEB4), // Green
    const Color(0xFFFFFEAA7), // Yellow
  ];

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    await _initializeGameScene();
  }

  /// Initialize the game scene with level-specific settings
  Future<void> _initializeGameScene() async {
    try {
      _setupLevelParameters();
      await _createBackground();
      await _createUI();
      await _createGameBoard();
      await _createTargetPatterns();
      _setupTimer();
      _startLevel();
    } catch (e) {
      print('Error initializing game scene: $e');
    }
  }

  /// Setup level-specific parameters based on current level
  void _setupLevelParameters() {
    // Determine grid size and time based on level
    if (currentLevel <= 3) {
      gridSize = 3;
      timeRemaining = 90.0;
    } else if (currentLevel <= 7) {
      gridSize = 4;
      timeRemaining = 60.0;
    } else {
      gridSize = 5;
      timeRemaining = 45.0;
    }
    
    score = 0;
    gemsEarned = 0;
    isGameActive = false;
    isGamePaused = false;
    isGameComplete = false;
  }

  /// Create background with magical crystal cave theme
  Future<void> _createBackground() async {
    background = SpriteComponent()
      ..sprite = await Sprite.load('crystal_cave_background.png')
      ..size = game.size
      ..position = Vector2.zero();
    add(background);

    // Add floating particle effects
    sparkleEffect = ParticleSystemComponent(
      particle: Particle.generate(
        count: 20,
        lifespan: 3.0,
        generator: (i) => AcceleratedParticle(
          acceleration: Vector2(0, -50),
          speed: Vector2(_random.nextDouble() * 100 - 50, _random.nextDouble() * 100 - 50),
          position: Vector2(
            _random.nextDouble() * game.size.x,
            game.size.y + 10,
          ),
          child: CircleParticle(
            radius: 2.0,
            paint: Paint()..color = Colors.white.withOpacity(0.8),
          ),
        ),
      ),
    );
    add(sparkleEffect);
  }

  /// Create UI elements for score, timer, and gems
  Future<void> _createUI() async {
    // Score display
    scoreText = TextComponent(
      text: 'Score: $score',
      textRenderer: TextPaint(
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      position: Vector2(20, 50),
    );
    add(scoreText);

    // Timer display
    timerText = TextComponent(
      text: 'Time: ${timeRemaining.toInt()}',
      textRenderer: TextPaint(
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      position: Vector2(game.size.x - 150, 50),
    );
    add(timerText);

    // Gems display
    gemsText = TextComponent(
      text: 'Gems: $gemsEarned',
      textRenderer: TextPaint(
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.yellow,
        ),
      ),
      position: Vector2(20, 90),
    );
    add(gemsText);
  }

  /// Create the game board and tile grid
  Future<void> _createGameBoard() async {
    final boardSize = game.size.x * 0.8;
    final boardPosition = Vector2(
      (game.size.x - boardSize) / 2,
      game.size.y * 0.3,
    );

    gameBoard = RectangleComponent(
      size: Vector2(boardSize, boardSize),
      position: boardPosition,
      paint: Paint()
        ..color = Colors.black.withOpacity(0.3)
        ..style = PaintingStyle.fill,
    );
    add(gameBoard);

    await _generateTileGrid(boardPosition, boardSize);
  }

  /// Generate the tile grid with random colors
  Future<void> _generateTileGrid(Vector2 boardPosition, double boardSize) async {
    gameGrid = List.generate(
      gridSize,
      (row) => List.generate(gridSize, (col) => TileComponent()),
    );

    final tileSize = boardSize / gridSize;
    final padding = tileSize * 0.1;
    final actualTileSize = tileSize - padding;

    for (int row = 0; row < gridSize; row++) {
      for (int col = 0; col < gridSize; col++) {
        final tilePosition = Vector2(
          boardPosition.x + col * tileSize + padding / 2,
          boardPosition.y + row * tileSize + padding / 2,
        );

        final tile = TileComponent(
          color: tileColors[_random.nextInt(tileColors.length)],
          gridPosition: Vector2(col.toDouble(), row.toDouble()),
          size: Vector2(actualTileSize, actualTileSize),
          position: tilePosition,
          onTap: _onTileTapped,
        );

        gameGrid[row][col] = tile;
        add(tile);
      }
    }
  }

  /// Create target patterns to match
  Future<void> _createTargetPatterns() async {
    targetPatterns = [];
    final patternCount = currentLevel <= 3 ? 1 : currentLevel <= 7 ? 2 : 3;

    patternDisplay = Component();
    add(patternDisplay);

    for (int i = 0; i < patternCount; i++) {
      final pattern = PatternComponent(
        patternId: i,
        targetColors: _generateRandomPattern(),
        position: Vector2(20 + i * 120, game.size.y * 0.15),
      );
      targetPatterns.add(pattern);
      patternDisplay.add(pattern);
    }
  }

  /// Generate a random pattern for the target
  List<List<Color>> _generateRandomPattern() {
    final patternSize = min(3, gridSize);
    return List.generate(
      patternSize,
      (row) => List.generate(
        patternSize,
        (col) => tileColors[_random.nextInt(min(3, tileColors.length))],
      ),
    );
  }

  /// Setup and start the game timer
  void _setupTimer() {
    gameTimer = Timer(
      1.0,
      repeat: true,
      onTick: _updateTimer,
    );
  }

  /// Update timer and check for time expiration
  void _updateTimer() {
    if (!isGameActive || isGamePaused) return;

    timeRemaining -= 1.0;
    timerText.text = 'Time: ${timeRemaining.toInt()}';

    if (timeRemaining <= 0) {
      _handleGameOver(false);
    }
  }

  /// Start the level
  void _startLevel() {
    isGameActive = true;
    gameTimer.start();
  }

  /// Handle tile tap events
  void _onTileTapped(TileComponent tappedTile) {
    if (!isGameActive || isGamePaused) return;

    if (selectedTile == null) {
      _selectTile(tappedTile);
    } else if (selectedTile == tappedTile) {
      _deselectTile();
    } else if (_areAdjacent(selectedTile!, tappedTile)) {
      _swapTiles(selectedTile!, tappedTile);
    } else {
      _selectTile(tappedTile);
    }
  }

  /// Select a tile for swapping
  void _selectTile(TileComponent tile) {
    selectedTile?.setSelected(false);
    selectedTile = tile;
    tile.setSelected(true);
  }

  /// Deselect the currently selected tile
  void _deselectTile() {
    selectedTile?.setSelected(false);
    selectedTile = null;
  }

  /// Check if two tiles are adjacent
  bool _areAdjacent(TileComponent tile1, TileComponent tile2) {
    final pos1 = tile1.gridPosition;
    final pos2 = tile2.gridPosition;
    final dx = (pos1.x - pos2.x).abs();
    final dy = (pos1.y - pos2.y).abs();
    return (dx == 1 && dy == 0) || (dx == 0 && dy == 1);
  }

  /// Swap two tiles and check for pattern matches
  void _swapTiles(TileComponent tile1, TileComponent tile2) {
    // Swap colors
    final tempColor = tile1.color;
    tile1.color = tile2.color;
    tile2.color = tempColor;

    // Update visual representation
    tile1.updateVisual();
    tile2.updateVisual();

    _deselectTile();
    _checkForMatches();
  }

  /// Check for pattern matches and update score
  void _checkForMatches() {
    bool foundMatch = false;
    int matchCount = 0;

    for (final pattern in targetPatterns) {
      if (!pattern.isCompleted && _checkPatternMatch(pattern)) {
        pattern.markCompleted();
        foundMatch = true;
        matchCount++;
        
        // Award points and gems
        final basePoints = 100 * currentLevel;
        score += basePoints;
        gemsEarned += 10;
        
        // Bonus time for matches
        timeRemaining += 5.0;
      }
    }

    if (foundMatch) {
      _updateUI();
      _playMatchEffect();
      
      // Check if all patterns are completed
      if (targetPatterns.every((pattern) => pattern.isCompleted)) {
        _handleGameOver(true);
      }
    }
  }

  /// Check if a specific pattern is matched on the grid
  bool _checkPatternMatch(PatternComponent pattern) {
    final targetPattern = pattern.targetColors;
    final patternSize = targetPattern.length;

    // Check all possible positions on the grid
    for (int startRow = 0; startRow <= gridSize - patternSize; startRow++) {
      for (int startCol = 0; startCol <= gridSize - patternSize; startCol++) {
        bool matches = true;
        
        for (int row = 0; row < patternSize && matches; row++) {
          for (int col = 0; col < patternSize && matches; col++) {
            final gridTile = gameGrid[startRow + row][startCol + col];
            final targetColor = targetPattern[row][col];
            if (gridTile.color != targetColor) {
              matches = false;
            }
          }
        }
        
        if (matches) return true;
      }
    }
    
    return false;
  }

  /// Update UI elements
  void _updateUI() {
    scoreText.text = 'Score: $score';
    timerText.text = 'Time: ${timeRemaining.toInt()}';
    gemsText.text = 'Gems: $gemsEarned';
  }

  /// Play visual effect for successful matches
  void _playMatchEffect() {
    // Add sparkle particles at matched locations
    final matchEffect = ParticleSystemComponent(
      particle: Particle.generate(
        count: 10,
        lifespan: 1.0,
        generator: (i) => AcceleratedParticle(
          acceleration: Vector2(0, -100),
          speed: Vector2(_random.nextDouble() * 200 - 100, _random.nextDouble() * 200 - 100),
          position: Vector2(game.size.x / 2, game.size.y / 2),
          child: CircleParticle(
            radius: 3.0,
            paint: Paint()..color = Colors.yellow.withOpacity(0.9),
          ),
        ),
      ),
    );
    add(matchEffect);
  }

  /// Handle game over (win or lose)
  void _handleGameOver(bool isWin) {
    isGameActive = false;
    isGameComplete = true;
    gameTimer.stop();

    if (isWin) {
      _handleLevelComplete();
    } else {
      _handleLevelFailed();
    }
  }

  /// Handle successful level completion
  void _handleLevelComplete() {
    // Bonus points for remaining time
    final timeBonus = (timeRemaining * 10).toInt();
    score += timeBonus;
    gemsEarned += timeBonus ~/ 50;

    // Show completion effect
    _showCompletionEffect();
    
    // Trigger analytics event
    _logLevelComplete();
  }

  /// Handle level failure
  void _handleLevelFailed() {
    // Show failure effect
    _showFailureEffect();
    
    // Trigger analytics event
    _logLevelFailed();
  }

  /// Show visual effect for level completion
  void _showCompletionEffect() {
    final celebrationEffect = ParticleSystemComponent(
      particle: Particle.generate(
        count: 50,
        lifespan: 2.0,
        generator: (i) => AcceleratedParticle(
          acceleration: Vector2(0, 200),
          speed: Vector2(_random.nextDouble() * 400 - 200, _random.nextDouble() * 300 - 150),
          position: Vector2(game.size.x / 2, game.size.y / 3),
          child: CircleParticle(
            radius: 4.0,
            paint: Paint()..color = tileColors[_random.nextInt(tileColors.length)],
          ),
        ),
      ),
    );
    add(celebrationEffect