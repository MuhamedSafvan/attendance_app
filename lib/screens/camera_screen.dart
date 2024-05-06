import 'dart:async';
import 'package:face_camera/face_camera.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

import '../main.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _controller;
  bool _isDetecting = false;
  FaceDetector _faceDetector = FaceDetector(options: FaceDetectorOptions());
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  void _initializeCamera() {
    _controller = CameraController(
        cameras.firstWhere(
            (camera) => camera.lensDirection == CameraLensDirection.front),
        ResolutionPreset.high);
    _controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
      _startFaceDetection();
    });
  }

  void _startFaceDetection() {
    _timer = Timer.periodic(Duration(milliseconds: 500), (timer) async {
      if (_controller.value.isInitialized && !_isDetecting) {
        try {
          if (mounted) {
            setState(() {
              _isDetecting = true;
            });
          }
          final image = await _controller.takePicture();
          InputImage inputImage = InputImage.fromFilePath(image.path);
          List<Face> faces = await _faceDetector.processImage(inputImage);
          // Calculate brightness from detected face region
          double brightness = _calculateBrightness(faces);
          // Show appropriate message based on brightness
          _showMessage(brightness);
        } catch (e) {
          print(e);
        } finally {
          if (mounted) {
            setState(() {
              _isDetecting = false;
            });
          }
        }
      }
    });
  }

  double _calculateBrightness(List<Face> faces) {
    // Dummy brightness calculation (average pixel value)
    double brightness = 0;
    if (faces.isNotEmpty) {
      // Assuming only one face is detected
      Rect faceRect = faces.first.boundingBox;
      // Dummy calculation, you might need to refine this
      brightness = faceRect.width * faceRect.height;
    }
    return brightness;
  }

  void _showMessage(double brightness) {
    String message;
    // Adjust threshold according to your requirement
    if (brightness > 1000) {
      message = "Well-lit environment";
    } else {
      message = "Low light detected!";
    }
    // Show message using Snackbar or similar widget
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
    ));
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
    _timer.cancel();
    ScaffoldMessenger.of(context).clearSnackBars();
  }

  @override
  Widget build(BuildContext context) {
    if (!_controller.value.isInitialized) {
      return Container();
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('Face App'),
      ),
      body: Stack(
        children: [
          CameraPreview(_controller),
        ],
      ),
    );
  }
}
