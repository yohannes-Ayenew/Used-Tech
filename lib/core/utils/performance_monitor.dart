// lib/core/utils/performance_monitor.dart

import 'dart:developer';

class PerformanceMonitor {
  static final Map<String, Stopwatch> _watches = {};
  static final Map<String, List<int>> _metrics = {};

  static void start(String operation) {
    _watches[operation] = Stopwatch()..start();
  }

  static void end(String operation) {
    final watch = _watches[operation];
    if (watch != null) {
      watch.stop();
      final duration = watch.elapsedMilliseconds;

      // Store metrics
      _metrics.putIfAbsent(operation, () => []).add(duration);

      // Log if slow (> 300ms)
      if (duration > 300) {
        log('⚠️ SLOW OPERATION: $operation took ${duration}ms');
      } else {
        log('✅ $operation took ${duration}ms');
      }

      _watches.remove(operation);
    }
  }

  static Future<T> measure<T>(
    String operation,
    Future<T> Function() task,
  ) async {
    start(operation);
    try {
      return await task();
    } finally {
      end(operation);
    }
  }

  static Map<String, double> getAverageMetrics() {
    return _metrics.map((key, values) {
      final avg = values.reduce((a, b) => a + b) / values.length;
      return MapEntry(key, avg);
    });
  }

  static void printMetricsReport() {
    log('\n=== PERFORMANCE METRICS ===');
    _metrics.forEach((key, values) {
      final avg = values.reduce((a, b) => a + b) / values.length;
      final min = values.reduce((a, b) => a < b ? a : b);
      final max = values.reduce((a, b) => a > b ? a : b);
      log(
        '$key: avg=${avg.toStringAsFixed(0)}ms, min=${min}ms, max=${max}ms, count=${values.length}',
      );
    });
    log('===========================\n');
  }
}
