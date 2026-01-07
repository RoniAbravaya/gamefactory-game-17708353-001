/// Timer Countdown Mechanic
/// 
/// Countdown timer for levels

import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
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

