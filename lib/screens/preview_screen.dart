import 'dart:io';

import 'package:attendance_app/main.dart';
import 'package:attendance_app/screens/verify_screen.dart';
import 'package:camera/camera.dart';
import 'package:face_camera/face_camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image/image.dart' as img;

import '../utils/constants.dart';
import 'camera_screen.dart';

class PreviewScreen extends StatefulWidget {
  final XFile image;
  const PreviewScreen({super.key, required this.image});

  @override
  State<PreviewScreen> createState() => _PreviewScreenState();
}

class _PreviewScreenState extends State<PreviewScreen> {
  bool hasEnoughLight = false;
  bool isAnalyzing = false;
  bool _faceDetected = false;
  late FaceDetector _faceDetector;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _faceDetector = FaceDetector(options: FaceDetectorOptions());
    final hasLight = checkEnoughLight(widget.image);
    setState(() {
      hasEnoughLight = hasLight;
    });
    analyzePhoto();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _faceDetector.close();
  }

  Future<bool> checkFace(XFile imageFile) async {
    final inputImage = InputImage.fromFile(File(imageFile.path));

    final faces = await _faceDetector.processImage(inputImage);
    print("faces ${faces.length}");
    print(faces.length);
    if (faces.isNotEmpty) return true;
    return false;
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

  void analyzePhoto() async {
    setState(() {
      isAnalyzing = true;
    });
    final faceDetected = await checkFace(widget.image);
    setState(() {
      _faceDetected = faceDetected;
      isAnalyzing = false;
    });
    print("_faceDetected $_faceDetected");
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => const VerifyScreen(),
          ),
          (route) => false,
        );
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CameraScreen(),
            ));
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () async {
              await Navigator.pushAndRemoveUntil(
                navigatorKey.currentState!.context,
                MaterialPageRoute(
                  builder: (context) => const VerifyScreen(),
                ),
                (route) => false,
              );

              // whenComplete(() => Navigator.push(
              //     navigatorKey.currentState!.context,
              //     MaterialPageRoute(
              //       builder: (context) => CameraScreen(),
              //     )));
              await Future.delayed(
                Duration(milliseconds: 200),
                () => Navigator.push(
                    navigatorKey.currentState!.context,
                    MaterialPageRoute(
                      builder: (context) => CameraScreen(),
                    )),
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
        body: isAnalyzing
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : hasEnoughLight
                ? _faceDetected
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Center(
                            child: Container(
                              // alignment: Alignment.center,
                              margin: const EdgeInsets.symmetric(vertical: 50),
                              height: size.height * .45,
                              width: size.width * .75,
                              child: Transform.flip(
                                  flipX: true,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(15),
                                    child: Image.file(
                                      File(widget.image.path),
                                      fit: BoxFit.cover,
                                    ),
                                  )),
                            ),
                          ),
                          const SizedBox(
                            height: 24,
                          ),
                          Text(
                            'Face Verified Successfully',
                            style: GoogleFonts.encodeSansExpanded(
                                fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                          const Spacer(),
                          const Divider(),
                          Container(
                            height: 44,
                            margin: const EdgeInsets.symmetric(horizontal: 10)
                                .copyWith(bottom: 10, top: 5),
                            // padding: const EdgeInsets.symmetric(horizontal: 10),
                            width: double.infinity,
                            child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    backgroundColor: primaryColor,
                                    foregroundColor: Colors.white),
                                onPressed: () {
                                  Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const VerifyScreen(),
                                    ),
                                    (route) => false,
                                  );
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => CameraScreen(),
                                      ));
                                },
                                child: Text(
                                  'Submit',
                                  style: GoogleFonts.montserrat(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500),
                                )),
                          )
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Center(
                            child: Container(
                              // alignment: Alignment.center,
                              margin: const EdgeInsets.symmetric(vertical: 50),
                              height: size.height * .45,
                              width: size.width * .75,
                              child: Transform.flip(
                                  flipX: true,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(15),
                                    child: Image.file(
                                      File(widget.image.path),
                                      fit: BoxFit.cover,
                                    ),
                                  )),
                            ),
                          ),
                          const SizedBox(
                            height: 24,
                          ),
                          Text(
                            "We couldn't recognize your face",
                            style: GoogleFonts.encodeSansExpanded(
                                fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Container(
                            height: 50,
                            margin: const EdgeInsets.symmetric(horizontal: 10)
                                .copyWith(bottom: 10, top: 5),
                            // padding: const EdgeInsets.symmetric(horizontal: 10),
                            width: size.width * .4,
                            child: ElevatedButton.icon(
                                icon: Image.asset(
                                  'assets/images/refresh_icon.png',
                                  height: 18,
                                  width: 16,
                                  color: primaryColor,
                                ),
                                style: ElevatedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      side:
                                          const BorderSide(color: primaryColor),
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    backgroundColor: Colors.white,
                                    foregroundColor: primaryColor),
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const CameraScreen(),
                                      ));
                                },
                                label: Text(
                                  'Re-Take',
                                  style: GoogleFonts.montserrat(
                                      color: primaryColor,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500),
                                )),
                          ),
                          const Spacer(),
                          const Divider(),
                          Container(
                            height: 44,
                            margin: const EdgeInsets.symmetric(horizontal: 10)
                                .copyWith(bottom: 10, top: 5),
                            // padding: const EdgeInsets.symmetric(horizontal: 10),
                            width: double.infinity,
                            child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    backgroundColor: Colors.transparent,
                                    foregroundColor: Colors.white),
                                onPressed: () {},
                                child: Text(
                                  'Submit',
                                  style: GoogleFonts.montserrat(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500),
                                )),
                          )
                        ],
                      )
                : Stack(
                    children: [
                      SizedBox(
                        height: double.infinity,
                        child: Transform.flip(
                            flipX: true,
                            child: Image.file(
                              File(widget.image.path),
                              fit: BoxFit.cover,
                            )),
                      ),
                      Container(
                        decoration: const BoxDecoration(
                            color: Color.fromRGBO(0, 0, 0, 0.6)),
                        height: double.infinity,
                        width: double.infinity,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          const SizedBox(
                            height: 35,
                          ),
                          Text(
                            'Please try again with better lighting',
                            style: GoogleFonts.montserrat(
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: Colors.white),
                          ),
                          const Spacer(),
                          Image.asset(
                            'assets/images/light_icon.png',
                            height: 50,
                            width: 50,
                          ),
                          const SizedBox(
                            height: 50,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            // crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Image.asset(
                                'assets/images/refresh_icon.png',
                                height: 18,
                                width: 16,
                              ),
                              const SizedBox(
                                width: 20,
                              ),
                              Text(
                                'Lighting is less, Try Again',
                                style: GoogleFonts.encodeSansExpanded(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white),
                              ),
                            ],
                          ),
                          const Spacer(),
                          SizedBox(
                            width: 150,
                            height: 50,
                            child: ElevatedButton.icon(
                                icon: Image.asset(
                                  'assets/images/refresh_icon.png',
                                  height: 18,
                                  width: 16,
                                ),
                                style: ElevatedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    backgroundColor: primaryColor,
                                    foregroundColor: Colors.white),
                                onPressed: () {
                                  Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const VerifyScreen(),
                                    ),
                                    (route) => false,
                                  );
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => CameraScreen(),
                                      ));
                                },
                                label: Text(
                                  'Re-Take',
                                  style: GoogleFonts.montserrat(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500),
                                )),
                          ),
                          const SizedBox(
                            height: 50,
                          )
                        ],
                      )
                    ],
                  ),
      ),
    );
  }
}
