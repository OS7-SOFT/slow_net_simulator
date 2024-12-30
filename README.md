# SlowNetSimulator

**SlowNetSimulator** is a powerful Flutter package designed to help developers simulate different network speeds and conditions directly within their Flutter apps. This is especially useful for testing how your app behaves under various network conditions, such as 2G, 3G, 4G, or when there is a chance of network failures.

## Features

- Simulate different network speeds: GPRS (2G), EDGE (2G), HSPA (3G), and LTE (4G).
- Introduce artificial latency to mimic real-world conditions.
- Configure network failure probabilities to test error handling.
- Real-time adjustment of network settings via an overlay button.

## Getting Started

To use this package, add `slow_net_simulator` as a dependency in your `pubspec.yaml` file:

```yaml
dependencies:
  slow_net_simulator: ^1.0.0
```

## Usage

### 1. Initialize the Simulator

Configure the network simulator with the desired speed and failure probability during app initialization or dynamically:

```dart
SlowNetSimulator.configure(
  speed: NetworkSpeed.EDGE_2G,
  failureProbability: 0.1, // 10% failure chance
);
```

### 2. Show the Overlay Button

To enable the real-time adjustment of network conditions, you must ensure the overlay button is displayed on the screen. **Place the following code at the top of your \*\***`build`\***\* method in your main widget or any widget where you want the overlay to appear:**

```dart
@override
Widget build(BuildContext context) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    SlowNetOverlay.showOverlay(context);
  });

  return MaterialApp(
    home: ExamplePage(),
  );
}
```

### 3. Simulate Network Conditions

Wrap your network calls using the `simulate` method to introduce the configured network delay and failure probability:

```dart
try {
  final response = await SlowNetSimulator.simulate(() async {
    return await dio.get('https://jsonplaceholder.typicode.com/posts/1');
  });

  // Handle successful response
  print(response.data);
} catch (e) {
  // Handle network failure
  print('Network failure: $e');
}
```

### 4. Example UI Integration

Below is an example of how to integrate the SlowNetSimulator with a Flutter app:

```dart
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:slow_net_simulator/slow_net_simulator.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      SlowNetOverlay.showOverlay(context);
    });

    return MaterialApp(
      home: ExamplePage(),
    );
  }
}

class ExamplePage extends StatelessWidget {
  final Dio dio = Dio();

  Future<void> fetchData() async {
    try {
      final response = await SlowNetSimulator.simulate(() async {
        return await dio.get('https://jsonplaceholder.typicode.com/posts/1');
      });

      print(response.data);
    } catch (e) {
      print('Network failure: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('SlowNet Example')),
      body: Center(
        child: ElevatedButton(
          onPressed: fetchData,
          child: Text('Fetch Data'),
        ),
      ),
    );
  }
}
```

## Notes

- **The overlay button must be displayed at the top of the widget tree to ensure global visibility across all routes.**
- This package is ideal for developers who work on both the backend and mobile side and want to test app behavior under simulated network conditions.

## Contributing

Contributions are welcome! If you encounter issues or have feature requests, please open an issue or submit a pull request on the [GitHub repository](https://github.com/OS7-SOFT/slow_net_simulator).

## License

This project is licensed under the MIT License. See the LICENSE file for details.
