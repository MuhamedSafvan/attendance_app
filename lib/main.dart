import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import 'screens/verify_screen.dart';

List<CameraDescription> cameras = [];

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

int totalTries = 0;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      navigatorKey: navigatorKey,
      home: VerifyScreen(),
    );
  }
}
