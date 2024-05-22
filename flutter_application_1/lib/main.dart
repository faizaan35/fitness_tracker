import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_application_1/neu_circle.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _hasPermissions = false;

  @override
  void initState() {
    super.initState();
    _fetchPermissionStatus();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Color(0xFF121F2B), // Set the status bar color
      systemNavigationBarColor:
          Color(0xFF121F2B), // Set the navigation bar color
      systemNavigationBarIconBrightness:
          Brightness.light, // Set brightness for navigation bar icons
    ));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        resizeToAvoidBottomInset: false,
        extendBodyBehindAppBar: true,
        backgroundColor: const Color(0xFF121F2B),
        body: Builder(
          builder: (context) {
            if (_hasPermissions) {
              return _buildCompass();
            } else {
              return _buildPermissionSheet();
            }
          },
        ),
        bottomNavigationBar: Container(
          height: 0,
          color: const Color(0xFF121F2B),
        ),
      ),
    );
  }

  // Build a compass widget with smooth transitions
  Widget _buildCompass() {
    return StreamBuilder<CompassEvent>(
      stream: FlutterCompass.events,
      builder: (context, snapshot) {
        // Error message
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }
        // Loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        double? direction = snapshot.data?.heading;

        // If direction is null, device doesn't support the sensors
        if (direction == null) {
          return const Center(
            child: Text('Device does not have sensors'),
          );
        }

        // Return the compass with smooth rotation
        return NeuCircle(
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(25),
              child: TweenAnimationBuilder<double>(
                tween: Tween<double>(
                  begin: 0,
                  end: direction,
                ),
                duration: const Duration(milliseconds: 900),
                builder: (context, value, child) {
                  return Transform.rotate(
                    angle: value * (math.pi / 180) * -1,
                    child: Image.asset(
                      'assets/compass.png',
                      color: Colors.white,
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  // Build a permission sheet
  Widget _buildPermissionSheet() {
    return Center(
      child: ElevatedButton(
        child: const Text('Request permission'),
        onPressed: () {
          Permission.locationWhenInUse.request().then((value) {
            _fetchPermissionStatus();
          });
        },
      ),
    );
  }

  void _fetchPermissionStatus() {
    Permission.locationWhenInUse.status.then((status) {
      if (mounted) {
        setState(() {
          _hasPermissions = (status == PermissionStatus.granted);
        });
      }
    });
  }
}
