import 'package:flutter_test/flutter_test.dart';
import 'package:slow_net_simulator/slow_net_simulator.dart';

void main() {
  group('SlowNetSimulator Tests', () {
    setUp(() {
      SlowNetSimulator.configure(
        speed: NetworkSpeed.EDGE_2G,
        failureProbability: 0.0,
      );
    });

    test('Simulates delay for GPRS (2G)', () async {
      SlowNetSimulator.configure(speed: NetworkSpeed.GPRS_2G);

      final stopwatch = Stopwatch()..start();

      await SlowNetSimulator.simulate(() async => 'Success');

      stopwatch.stop();

      expect(
        stopwatch.elapsedMilliseconds,
        greaterThanOrEqualTo(SlowNetSimulator.simulatedDelay.inMilliseconds),
      );
    });

    test('Simulates delay for EDGE (2G)', () async {
      SlowNetSimulator.configure(speed: NetworkSpeed.EDGE_2G);

      final stopwatch = Stopwatch()..start();

      await SlowNetSimulator.simulate(() async => 'Success');

      stopwatch.stop();

      expect(
        stopwatch.elapsedMilliseconds,
        greaterThanOrEqualTo(SlowNetSimulator.simulatedDelay.inMilliseconds),
      );
    });

    test('Simulates delay for HSPA (3G)', () async {
      SlowNetSimulator.configure(speed: NetworkSpeed.HSPA_3G);

      final stopwatch = Stopwatch()..start();

      await SlowNetSimulator.simulate(() async => 'Success');

      stopwatch.stop();

      expect(
        stopwatch.elapsedMilliseconds,
        greaterThanOrEqualTo(SlowNetSimulator.simulatedDelay.inMilliseconds),
      );
    });

    test('Simulates delay for LTE (4G)', () async {
      SlowNetSimulator.configure(speed: NetworkSpeed.LTE_4G);

      final stopwatch = Stopwatch()..start();

      await SlowNetSimulator.simulate(() async => 'Success');

      stopwatch.stop();

      expect(
        stopwatch.elapsedMilliseconds,
        greaterThanOrEqualTo(SlowNetSimulator.simulatedDelay.inMilliseconds),
      );
    });

    test('Simulates network failure (100% probability)', () async {
      SlowNetSimulator.configure(
        speed: NetworkSpeed.EDGE_2G,
        failureProbability: 1.0,
      );

      try {
        await SlowNetSimulator.simulate(() async => 'This should fail');
        fail('The request should have failed but did not.');
      } catch (e) {
        expect(e, isA<Exception>());
      }
    });

    test('Handles mixed failure probability (50%)', () async {
      SlowNetSimulator.configure(
        speed: NetworkSpeed.HSPA_3G,
        failureProbability: 0.5,
      );

      int successCount = 0;
      int failureCount = 0;

      for (int i = 0; i < 100; i++) {
        try {
          await SlowNetSimulator.simulate(() async => 'Success');
          successCount++;
        } catch (_) {
          failureCount++;
        }
      }

      expect(successCount + failureCount, 100);
      expect(successCount, inInclusiveRange(40, 60)); // ~50%
      expect(failureCount, inInclusiveRange(40, 60)); // ~50%
    }, timeout: Timeout(Duration(minutes: 2))); // زيادة المهلة

    test('Simulates success with no failure probability', () async {
      SlowNetSimulator.configure(
        speed: NetworkSpeed.HSPA_3G,
        failureProbability: 0.0,
      );

      for (int i = 0; i < 10; i++) {
        final result = await SlowNetSimulator.simulate(() async => 'Success');
        expect(result, equals('Success'));
      }
    });

    test('Supports accurate current speed description', () {
      SlowNetSimulator.configure(speed: NetworkSpeed.GPRS_2G);
      expect(SlowNetSimulator.currentSpeedDescription, contains('GPRS (2G)'));

      SlowNetSimulator.configure(speed: NetworkSpeed.EDGE_2G);
      expect(SlowNetSimulator.currentSpeedDescription, contains('2G'));

      SlowNetSimulator.configure(speed: NetworkSpeed.HSPA_3G);
      expect(SlowNetSimulator.currentSpeedDescription, contains('3G'));

      SlowNetSimulator.configure(speed: NetworkSpeed.LTE_4G);
      expect(SlowNetSimulator.currentSpeedDescription, contains('4G'));
    });
  });
}
