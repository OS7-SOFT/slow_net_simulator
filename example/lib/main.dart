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
  NetworkSpeed speed = NetworkSpeed.EDGE_2G;
  Post? _data;
  String? errorResponse;
  bool _isLoading = false;
  bool _isSuccess = false;
  final Dio dio = Dio();

  @override
  void initState() {
    super.initState();
    _configureSimulator(NetworkSpeed.EDGE_2G, 0.0);
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
