/// Score System Mechanic
/// 
/// Score tracking and display

import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/material.dart';


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

