import 'package:attendance_app/screens/camera_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../utils/constants.dart';

class VerifyScreen extends StatelessWidget {
  const VerifyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {},
          icon: Icon(Icons.arrow_back_ios_new),
        ),
        title: Text(
          'Face Verification',
          style: GoogleFonts.encodeSansExpanded(
              fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Spacer(),
                  Image.asset(
                    'assets/images/no_image.png',
                    height: 200,
                    width: 200,
                  ),
                  Text(
                    'Initiate face verification for quick attendance Process.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.encodeSansExpanded(
                        fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  Spacer(),
                  TextButton(
                      onPressed: () {},
                      child: Text(
                        'Privacy Notice',
                        style: GoogleFonts.montserrat(
                            color: primaryColor,
                            decoration: TextDecoration.underline,
                            fontSize: 12,
                            fontWeight: FontWeight.w500),
                      )),
                ],
              ),
            ),
          ),
          Divider(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            width: double.infinity,
            child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CameraScreen(),
                      ));
                },
                child: Text(
                  'Verify',
                  style: GoogleFonts.montserrat(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500),
                )),
          )
        ],
      ),
    );
  }
}
