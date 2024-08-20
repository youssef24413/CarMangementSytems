import 'package:flutter/material.dart';
import 'package:untitled/CarManagementApp/login_page.dart';


class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToLogin();
  }

  _navigateToLogin() async {
    await Future.delayed(Duration(seconds: 3), () {});
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff17212A),
      body: Center(
        child: SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: Image.asset(
            'assets/img/CAR.jpg',
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
