import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

class AttendancePage extends StatefulWidget {
  @override
  _AttendancePageState createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  bool _cameraInitializied = false;

  @override
  void initState() {
    super.initState();

    // Initialize the camera controller
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    final firstCamera = cameras.first;

    _controller = CameraController(
      firstCamera,
      ResolutionPreset.medium,
    );

    _initializeControllerFuture = _controller.initialize();
    if (!mounted) return;

    setState(() {
      _cameraInitializied = true;
    });
  }

  Future<void> _takePicture() async {
    try {
      // Ensure that the camera is initialized
      await _initializeControllerFuture;

      // Take the picture
      final XFile picture = await _controller.takePicture();

      // Compress the image
      Uint8List? compressedImage = await FlutterImageCompress.compressWithFile(
        picture.path,
        minHeight: 640,
        minWidth: 480,
      );

      // Handle the compressed image (e.g., send it to server)
      // You can handle the compressedImage data as per your requirement
    } catch (e) {
      print("Error taking picture: $e");
    }
  }

  @override
  void dispose() {
    // Dispose of the camera controller when not in use
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Face Verification'),
      ),
      body: !_cameraInitializied
          ? Center(
              child: Text('Initializing camera...'),
            )
          : FutureBuilder<void>(
              future: _initializeControllerFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  // If the Future is complete, display the camera preview
                  return CameraPreview(_controller);
                } else {
                  // Otherwise, display a loading indicator
                  return Center(child: CircularProgressIndicator());
                }
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _takePicture,
        child: Icon(Icons.camera),
      ),
    );
  }
}
