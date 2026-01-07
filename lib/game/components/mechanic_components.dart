/// Mechanic Components
/// 
/// Auto-generated components for game mechanics.

import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';


class CountdownTimer extends Component with HasGameRef {
  final double initialTime;
  double remainingTime;
  final VoidCallback onTimeUp;
  bool isPaused = false;
  
  CountdownTimer({
    required this.initialTime,
    required this.onTimeUp,
  }) : remainingTime = initialTime;
  
  @override
  void update(double dt) {
    if (isPaused) return;
    
    remainingTime -= dt;
    if (remainingTime <= 0) {
      remainingTime = 0;
      onTimeUp();
    }
  }
  
  String get formattedTime {
    final minutes = (remainingTime / 60).floor();
    final seconds = (remainingTime % 60).floor();
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
  
  void reset() {
    remainingTime = initialTime;
    isPaused = false;
  }
  
  void pause() => isPaused = true;
  void resume() => isPaused = false;
}


class ScoreComponent extends PositionComponent with HasGameRef {
  int _score = 0;
  int _highScore = 0;
  int _multiplier = 1;
  double _multiplierTimer = 0;
  
  int get score => _score;
  int get highScore => _highScore;
  int get multiplier => _multiplier;
  
  void addScore(int points) {
    _score += points * _multiplier;
    if (_score > _highScore) {
      _highScore = _score;
    }
  }
  
  void setMultiplier(int value, double duration) {
    _multiplier = value;
    _multiplierTimer = duration;
  }
  
  @override
  void update(double dt) {
    if (_multiplierTimer > 0) {
      _multiplierTimer -= dt;
      if (_multiplierTimer <= 0) {
        _multiplier = 1;
      }
    }
  }
  
  void reset() {
    _score = 0;
    _multiplier = 1;
    _multiplierTimer = 0;
  }
}

