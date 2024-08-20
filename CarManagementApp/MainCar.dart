import 'package:flutter/material.dart';
import 'SplashScreen.dart';

void main() {
  runApp(CarManagementApp());
}

class CarManagementApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Car Management App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SplashScreen(),
    );
  }
}
