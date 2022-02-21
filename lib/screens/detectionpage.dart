import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:manage_entry/ui/camera.dart';

_setPageSettings() {
  SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft]);
  SystemChrome.setEnabledSystemUIOverlays([]);
}

class DetectionPage extends StatefulWidget {
  const DetectionPage({Key? key}) : super(key: key);

  @override
  _DetectionPageState createState() => _DetectionPageState();
}

class _DetectionPageState extends State<DetectionPage> {
  bool _isManual = true;

  @override
  void initState() {
    super.initState();
    _setPageSettings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: BackButton(
          color: Colors.black,
        ),
        elevation: 0,
        actions: [
          Switch(
            value: _isManual,
            onChanged: (value) {
              setState(() {
                _isManual = value;
              });
            },
          ),
        ],
        title: Text(
          _isManual ? "Manual" : "Auto",
          style: TextStyle(
            color: Colors.black,
          ),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: Camera(
        _isManual,
      ),
    );
  }
}
