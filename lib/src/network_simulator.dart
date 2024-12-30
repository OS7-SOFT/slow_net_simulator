import 'dart:async';
import 'dart:math';

/// Enumeration for different network speeds.
enum NetworkSpeed {
  GPRS_2G,
  EDGE_2G,
  HSPA_3G,
  LTE_4G,
}

/// A class to configure and simulate slow network behavior.
class SlowNetSimulator {
  static Duration _latency = Duration(milliseconds: 2000); // Default latency
  static NetworkSpeed _currentSpeed = NetworkSpeed.HSPA_3G;
  static double _failureProbability = 0.0;

  /// Configure the simulator with a specific speed and optional custom latency.
  static void configure(
      {required NetworkSpeed speed,
      int latency = 0,
      double failureProbability = 0.0}) {
    _failureProbability = failureProbability;
    _currentSpeed = speed;
    switch (speed) {
      case NetworkSpeed.GPRS_2G:
        _latency = Duration(milliseconds: 10000);
        break;
      case NetworkSpeed.EDGE_2G:
        _latency = Duration(milliseconds: 4000);
        break;
      case NetworkSpeed.HSPA_3G:
        _latency = Duration(milliseconds: 1000);
        break;

      case NetworkSpeed.LTE_4G:
        _latency = Duration(milliseconds: 500);
        break;
    }
  }

  /// Simulates network delay for a given callback.
  static Future<T> simulate<T>(Future<T> Function() callback) async {
    await Future.delayed(_latency);
    if (_shouldFail()) {
      throw Exception('Simulated network failure');
    }
    return callback();
  }

  /// Returns the current latency for debugging or testing purposes.
  static Duration get simulatedDelay => _latency;

  static String get currentSpeedDescription {
    switch (_currentSpeed) {
      case NetworkSpeed.GPRS_2G:
        return "GPRS (2G): ~50 Kbps";
      case NetworkSpeed.EDGE_2G:
        return "2G: ~250 Kbps";
      case NetworkSpeed.HSPA_3G:
        return "3G: ~3 Mbps";
      case NetworkSpeed.LTE_4G:
        return "4G: ~20 Mbps";
    }
  }

  static bool _shouldFail() {
    final random = Random();
    return random.nextDouble() < _failureProbability;
  }
}
