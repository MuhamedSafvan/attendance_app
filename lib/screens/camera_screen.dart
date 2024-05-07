import 'dart:async';
import 'dart:io';
import 'package:attendance_app/screens/preview_screen.dart';
import 'package:attendance_app/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image/image.dart' as img;

import '../main.dart';
import 'verify_screen.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController controller;
  bool _isImageCaptured = false;
  XFile? _image;
  double scanProgress = 0;
  StreamSubscription? _timerSubscription;
  bool hasEnoughLight = false;

  @override
  void initState() {
    super.initState();
    controller = CameraController(
        cameras.firstWhere(
            (camera) => camera.lensDirection == CameraLensDirection.front),
        ResolutionPreset.max);
    controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      if (!_isImageCaptured) {
        _timerSubscription =
            Stream.periodic(const Duration(milliseconds: 1), (count) {
          setState(() {
            // if (!_isImageCaptured) {
            scanProgress = count / 3000; // 3000 milliseconds = 3 seconds
            if (count >= 2999) {
              // Stop the progress at 99%
              _timerSubscription?.cancel(); // Cancel the timer subscription
            }
            // }
          });
        }).take(3000).listen(null);
      }
      setState(() {});
      // Start monitoring focus
      controller.startImageStream((CameraImage image) {
        // You can implement focus detection logic here
        detectFocus(image);
      });
    });
  }

  @override
  void dispose() {
    controller.dispose();
    _timerSubscription?.cancel();

    super.dispose();
  }

  bool checkEnoughLight(XFile imageFile) {
    // Load the image using the image package
    img.Image? image = img.decodeImage(File(imageFile.path).readAsBytesSync());

    if (image == null) {
      // Error loading the image
      return false;
    }

    // Calculate the average intensity of all pixels
    num sum = 0;
    for (int y = 0; y < image.height; y++) {
      for (int x = 0; x < image.width; x++) {
        sum += img.getLuminance(image.getPixel(x, y));
      }
    }

    double averageIntensity = sum / (image.width * image.height);

    // Define your threshold for enough light
    double lightThreshold = 100.0;

    // Check if the average intensity is above the threshold
    return averageIntensity > lightThreshold;
  }

  void detectFocus(CameraImage image) {
    // Example: calculate average pixel intensity to determine focus
    double sum = 0;
    for (int planeIndex = 0; planeIndex < image.planes.length; planeIndex++) {
      sum += _calculateIntensity(image.planes[planeIndex]);
    }
    double averageIntensity = sum / image.planes.length;
    // If intensity is above a certain threshold, consider it focused
    print("averageIntensity $averageIntensity");
    if (averageIntensity > 100) {
      if (!_isImageCaptured) {
        Future.delayed(
          const Duration(
            seconds: 3,
          ),
          () => captureImage(),
        );
      }
    }
  }

  double _calculateIntensity(Plane plane) {
    double sum = 0;
    for (int i = 0; i < plane.bytes.length; i++) {
      sum += plane.bytes[i];
    }
    return sum / plane.bytes.length;
  }

  void captureImage() async {
    if (!controller.value.isInitialized) {
      return;
    }
    try {
      await Future.delayed(const Duration(seconds: 1));
      final image = await controller.takePicture();
      await controller.stopImageStream();
      setState(() {
        _isImageCaptured = true;
        _image = image;
      });
      // final hasLight = checkEnoughLight(image);
      // setState(() {
      //   hasEnoughLight = hasLight;
      // });
      if (_image != null) {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => PreviewScreen(image: _image!),
            ));
      }
      // Handle captured image
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    if (!controller.value.isInitialized) {
      return Container();
    }
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const VerifyScreen(),
          ),
        );
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const VerifyScreen(),
                ),
              );
            },
            icon: const Icon(Icons.arrow_back_ios_new),
          ),
          title: Text(
            'Face Verification',
            style: GoogleFonts.encodeSansExpanded(
                fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
        body: SizedBox(
          height: double.infinity,
          child:
              // _image != null
              //     ? Stack(
              //         children: [
              //           SizedBox(
              //             height: double.infinity,
              //             child: Transform.flip(
              //                 flipX: true,
              //                 child: Image.file(
              //                   File(_image!.path),
              //                   fit: BoxFit.cover,
              //                 )),
              //           ),
              //           Container(
              //             decoration: const BoxDecoration(
              //                 color: Color.fromRGBO(0, 0, 0, 0.6)),
              //             height: double.infinity,
              //             width: double.infinity,
              //           ),
              //           Column(
              //             crossAxisAlignment: CrossAxisAlignment.center,
              //             // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              //             children: [
              //               const SizedBox(
              //                 height: 35,
              //               ),
              //               Text(
              //                 'Please try again with better lighting',
              //                 style: GoogleFonts.montserrat(
              //                     fontSize: 12,
              //                     fontWeight: FontWeight.w400,
              //                     color: Colors.white),
              //               ),
              //               const Spacer(),
              //               Image.asset(
              //                 'assets/images/light_icon.png',
              //                 height: 50,
              //                 width: 50,
              //               ),
              //               const SizedBox(
              //                 height: 50,
              //               ),
              //               Row(
              //                 mainAxisAlignment: MainAxisAlignment.center,
              //                 // crossAxisAlignment: CrossAxisAlignment.center,
              //                 children: [
              //                   Image.asset(
              //                     'assets/images/refresh_icon.png',
              //                     height: 18,
              //                     width: 16,
              //                   ),
              //                   const SizedBox(
              //                     width: 20,
              //                   ),
              //                   Text(
              //                     'Lighting is less, Try Again',
              //                     style: GoogleFonts.encodeSansExpanded(
              //                         fontSize: 12,
              //                         fontWeight: FontWeight.w600,
              //                         color: Colors.white),
              //                   ),
              //                 ],
              //               ),
              //               const Spacer(),
              //               SizedBox(
              //                 width: 150,
              //                 height: 50,
              //                 child: ElevatedButton.icon(
              //                     icon: Image.asset(
              //                       'assets/images/refresh_icon.png',
              //                       height: 18,
              //                       width: 16,
              //                     ),
              //                     style: ElevatedButton.styleFrom(
              //                         shape: RoundedRectangleBorder(
              //                           borderRadius: BorderRadius.circular(15),
              //                         ),
              //                         backgroundColor: primaryColor,
              //                         foregroundColor: Colors.white),
              //                     onPressed: () {
              //                       Navigator.pushReplacement(
              //                               context,
              //                               MaterialPageRoute(
              //                                 builder: (context) => CameraScreen(),
              //                               ))
              //                           .whenComplete(() => CameraScreen()
              //                               .createState()
              //                               .build(context));
              //                     },
              //                     label: Text(
              //                       'Re-Take',
              //                       style: GoogleFonts.montserrat(
              //                           color: Colors.white,
              //                           fontSize: 16,
              //                           fontWeight: FontWeight.w500),
              //                     )),
              //               ),
              //               const SizedBox(
              //                 height: 50,
              //               )
              //             ],
              //           )
              //         ],
              //       )
              //     :
              Stack(
            // fit: StackFit.expand,
            children: [
              SizedBox(height: double.infinity, child: CameraPreview(controller)),
              Positioned(
                  top: 30,
                  left: 100,
                  right: 100,
                  child: Text('Please look into the camera and hold still',
                      style: GoogleFonts.montserrat(
                          fontSize: 12, fontWeight: FontWeight.w400))),
              Positioned(
                top: 80,
                left: 30,
                right: 30,
                child: SizedBox(
                  // height: size.height * .4,
                  width: size.width * .85,
                  child: Image.asset(
                    'assets/images/cam_border.png',
                  ),
                ),
              ),
              Positioned(
                bottom: 30,
                left: 30,
                right: 30,
                child: LinearProgressIndicator(
                  borderRadius: BorderRadius.circular(20),
                  value: scanProgress,
                  minHeight: 10,
                  backgroundColor: const Color.fromRGBO(255, 236, 226, 1),
                  valueColor: const AlwaysStoppedAnimation<Color>(primaryColor),
                ),
              ),
              Positioned(
                bottom: 60,
                left: 0,
                right: 0,
                child: Center(
                  child: Text(
                    '${(scanProgress * 100).toStringAsFixed(0)}% Scanning',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
