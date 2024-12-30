import 'package:flutter/material.dart';
import 'package:slow_net_simulator/slow_net_simulator.dart';

class SlowNetOverlay {
  static OverlayEntry? _overlayEntry;
  static bool _isSettingsOpen = false;
  static Alignment _buttonAlignment = Alignment.bottomLeft;

  static NetworkSpeed _currentSpeed = NetworkSpeed.HSPA_3G;
  static double _currentFailureProbability = 0.0;

  static void showOverlay(BuildContext context) {
    if (_overlayEntry != null) return;

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned.fill(
        child: Stack(
          children: [
            Container(
              padding: EdgeInsets.all(20),
              alignment: _buttonAlignment,
              child: FloatingActionButton(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                onPressed: () {
                  if (_isSettingsOpen) {
                    Navigator.of(context).pop();
                    _isSettingsOpen = false;
                  } else {
                    _showSettings(context);
                    _isSettingsOpen = true;
                  }
                  _overlayEntry!.markNeedsBuild();
                },
                child: Icon(_isSettingsOpen ? Icons.close : Icons.speed),
              ),
            ),
          ],
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  static void _showSettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return _SettingsPanel(
          initialAlignment: _buttonAlignment,
          initialSpeed: _currentSpeed,
          initialFailureProbability: _currentFailureProbability,
          onSettingsApplied: (speed, failureProbability, alignment) {
            _currentSpeed = speed;
            _currentFailureProbability = failureProbability;
            _buttonAlignment = alignment;
            _overlayEntry!.markNeedsBuild();
          },
        );
      },
    ).whenComplete(() {
      _isSettingsOpen = false;
      _overlayEntry!.markNeedsBuild();
    });
  }

  static void hideOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    _isSettingsOpen = false;
  }
}

class _SettingsPanel extends StatefulWidget {
  final NetworkSpeed initialSpeed;
  final double initialFailureProbability;
  final Alignment initialAlignment;
  final Function(NetworkSpeed, double, Alignment) onSettingsApplied;

  const _SettingsPanel({
    required this.initialSpeed,
    required this.initialFailureProbability,
    required this.onSettingsApplied,
    required this.initialAlignment,
  });

  @override
  State<_SettingsPanel> createState() => _SettingsPanelState();
}

class _SettingsPanelState extends State<_SettingsPanel> {
  late NetworkSpeed _selectedSpeed;
  late double _failureProbability;
  late Alignment _selectedAlignment;

  @override
  void initState() {
    super.initState();
    _selectedAlignment = widget.initialAlignment;
    _selectedSpeed = widget.initialSpeed;
    _failureProbability = widget.initialFailureProbability;
  }

  void _applySettings() {
    SlowNetSimulator.configure(
      speed: _selectedSpeed,
      failureProbability: _failureProbability,
    );
    widget.onSettingsApplied(
        _selectedSpeed, _failureProbability, _selectedAlignment);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Configure SlowNet',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              DropdownButton<NetworkSpeed>(
                value: _selectedSpeed,
                items: NetworkSpeed.values.map((speed) {
                  return DropdownMenuItem(
                    value: speed,
                    child: Text(speed.name),
                  );
                }).toList(),
                onChanged: (newSpeed) {
                  setState(() {
                    _selectedSpeed = newSpeed!;
                  });
                },
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                "Select failure probability",
                style: TextStyle(fontSize: 16),
              ),
              Slider(
                activeColor: Colors.red,
                value: _failureProbability,
                onChanged: (value) {
                  setState(() {
                    _failureProbability = value;
                  });
                },
                min: 0,
                max: 1,
                divisions: 10,
                label: '${(_failureProbability * 100).round()}%',
              ),
              SizedBox(height: 16),
              Text(
                'Choose Button Position',
                style: TextStyle(fontSize: 16),
              ),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildPositionButton('Top Left', Alignment.topLeft),
                  _buildPositionButton('Top Right', Alignment.topRight),
                  _buildPositionButton('Bottom Left', Alignment.bottomLeft),
                  _buildPositionButton('Bottom Right', Alignment.bottomRight),
                  _buildPositionButton('Center', Alignment.center),
                ],
              ),
              SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red, foregroundColor: Colors.white),
                onPressed: _applySettings,
                child: Text('Apply Settings'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPositionButton(String label, Alignment alignment) {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          _selectedAlignment = alignment;
        });
      },
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor:
            _selectedAlignment == alignment ? Colors.blue : Colors.grey,
      ),
      child: Text(label),
    );
  }
}
