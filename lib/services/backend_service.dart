import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'analytics_config.dart';

/// Backend service for forwarding events to GameFactory
class BackendService {
  static final BackendService _instance = BackendService._internal();
  factory BackendService() => _instance;
  BackendService._internal();

  bool _initialized = false;
  final List<Map<String, dynamic>> _eventQueue = [];
  bool _isSending = false;

  Future<void> initialize() async {
    _initialized = true;
    // Start periodic flush
    _startPeriodicFlush();
  }

  void _startPeriodicFlush() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 30));
      await _flushEvents();
      return _initialized;
    });
  }

  /// Send a single event to the backend
  Future<void> sendEvent(String name, Map<String, dynamic> params) async {
    if (!_initialized || !AnalyticsConfig.forwardToBackend) return;

    _eventQueue.add({
      'game_id': AnalyticsConfig.gameId,
      'event_name': name,
      'event_params': params,
      'timestamp': DateTime.now().toIso8601String(),
    });

    // Flush if queue is large
    if (_eventQueue.length >= 10) {
      await _flushEvents();
    }
  }

  Future<void> _flushEvents() async {
    if (_eventQueue.isEmpty || _isSending) return;

    _isSending = true;
    final events = List<Map<String, dynamic>>.from(_eventQueue);
    _eventQueue.clear();

    try {
      final response = await http.post(
        Uri.parse('${AnalyticsConfig.backendUrl}/api/v1/events/batch'),
        headers: {
          'Content-Type': 'application/json',
          'X-API-Key': AnalyticsConfig.apiKey,
        },
        body: jsonEncode({'events': events}),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        // Re-queue failed events
        _eventQueue.addAll(events);
        if (kDebugMode) {
          print('[Backend] Failed to send events: ${response.statusCode}');
        }
      }
    } catch (e) {
      // Re-queue on error
      _eventQueue.addAll(events);
      if (kDebugMode) {
        print('[Backend] Error sending events: $e');
      }
    } finally {
      _isSending = false;
    }
  }
}
