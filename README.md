# SlowNetSimulator

**SlowNetSimulator** is a powerful Flutter package designed to help developers simulate different network speeds and conditions directly within their Flutter apps. This is especially useful for testing how your app behaves under various network conditions, such as 2G, 3G, 4G, or when there is a chance of network failures.

## Features

- Simulate different network speeds: GPRS (2G), EDGE (2G), HSPA (3G), and LTE (4G).
- Introduce artificial latency to mimic real-world conditions.
- Configure network failure probabilities to test error handling.
- Easily integrate with any asynchronous request.
- Real-time adjustment of network settings via an overlay button.
- Useful for debugging and testing app resilience.

## Getting Started

To use this package, add `slow_net_simulator` as a dependency in your `pubspec.yaml` file:

```yaml
dependencies:
  slow_net_simulator: ^1.0.0
```

Then run:

```bash
flutter pub get
```

## Usage

### 1. Configuration in `main.dart`

In your `main` function, configure the simulator with a predefined network speed and failure probability:

```dart
void main() {
  SlowNetSimulator.configure(
    speed: NetworkSpeed.EDGE_2G, // Choose a predefined speed or custom speed
    failureProbability: 0.2,    // 20% chance of failure
  );

  runApp(MyApp());
}
```

### 2. Wrapping Requests with `simulate`

To simulate network behavior for any asynchronous request, wrap your request inside `SlowNetSimulator.simulate`. This works not only with `Dio` but also with any async operation:

```dart
final response = await SlowNetSimulator.simulate(() async {
  return await dio.get('https://jsonplaceholder.typicode.com/posts/1');
});
```

You can replace the `dio.get` call with any other request or async operation:

```dart
final result = await SlowNetSimulator.simulate(() async {
  // Perform any async task here
  return await someAsyncFunction();
});
```

### 3. Adjusting Failure Probability

The failure probability parameter allows you to define the likelihood of a request failing. This is useful for testing how your app handles sudden request failures. For example:

```dart
SlowNetSimulator.configure(
  speed: NetworkSpeed.HSPA_3G, // Simulating 3G speed
  failureProbability: 0.5,    // 50% chance of failure
);
```

With this setup, you can test your app's error handling capabilities and ensure it behaves gracefully under adverse conditions.

### 4. Show the Overlay Button

To enable the real-time adjustment of network conditions, you must ensure the overlay button is displayed on the screen. **Place the following code at the top of your \*\***`build`\***\* method in your main widget or any widget where you want the overlay to appear:**

```dart
@override
Widget build(BuildContext context) {

  //-----to show overlay button---------------------
  WidgetsBinding.instance.addPostFrameCallback((_) {
    SlowNetOverlay.showOverlay(context);
  });

  return MaterialApp(
    home: ExamplePage(),
  );
}
```

### 5. Example UI Integration

Below is an example of how to integrate the SlowNetSimulator with a Flutter app:

```dart
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:slow_net_simulator/slow_net_simulator.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const ExamplePage(),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
    );
  }
}

class ExamplePage extends StatefulWidget {
  const ExamplePage({super.key});

  @override
  _ExamplePageState createState() => _ExamplePageState();
}

class _ExamplePageState extends State<ExamplePage> {
  double failureProbability = 0.0;
  NetworkSpeed speed = NetworkSpeed.HSPA_3G;
  Post? _data;
  String? errorResponse;
  bool _isLoading = false;
  bool _isSuccess = false;
  final Dio dio = Dio();

  @override
  void initState() {
    super.initState();
    _configureSimulator(NetworkSpeed.HSPA_3G, 0.0);
  }

  void _configureSimulator(NetworkSpeed speed, double failureProbability) {
    SlowNetSimulator.configure(
        speed: speed, failureProbability: failureProbability);
    setState(() {});
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);

    try {
      final response = await SlowNetSimulator.simulate(() async {
        return await dio.get('https://jsonplaceholder.typicode.com/posts/1');
      });

      setState(() {
        _data = Post.fromJson(response.data);
        _isSuccess = true;
        errorResponse = null;
      });
    } catch (e) {
      setState(() {
        errorResponse = e.toString();
        _isSuccess = false;
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      SlowNetOverlay.showOverlay(context);
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('SlowNetSimulator Example'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(child: _buildResponseDisplay()),
              _buildFetchButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResponseDisplay() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    } else if (!_isSuccess && errorResponse != null) {
      return Center(
        child: Container(
          height: 100,
          width: 300,
          padding: EdgeInsets.all(10),
          color: Colors.red[100],
          child: Column(
            children: [
              Icon(
                Icons.error_rounded,
                color: Colors.red[500],
                size: 45,
              ),
              Text(
                errorResponse!,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.red[500]),
              ),
            ],
          ),
        ),
      );
    } else if (_data != null) {
      return SizedBox(
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Post Detail",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              _data!.title,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
            Text(
              _data!.body,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  Widget _buildFetchButton() {
    return ElevatedButton(
      autofocus: false,
      style: ButtonStyle(
          backgroundColor: WidgetStatePropertyAll(Colors.red),
          foregroundColor: WidgetStatePropertyAll(Colors.white)),
      onPressed: _isLoading ? null : _fetchData,
      child: const Text('Fetch Data'),
    );
  }
}

class Post {
  final int id;
  final String title;
  final String body;

  Post({required this.id, required this.title, required this.body});

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json["id"],
      title: json["title"],
      body: json["body"],
    );
  }
}

```

- This package is ideal for developers who work on both the backend and mobile side and want to test app behavior under simulated network conditions.

## Contributing

Contributions are welcome! If you encounter issues or have feature requests, please open an issue or submit a pull request on the [slow_net_simulator repository](https://github.com/OS7-SOFT/slow_net_simulator).

## License

This project is licensed under the MIT License. See the LICENSE file for details.

## Package on Pub.dev

Find this package on Pub.dev: [slow_net_simulator](https://pub.dev/packages/slow_net_simulator)
