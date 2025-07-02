import 'package:celebrating/utils/route.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _navigateToAuth();
  }
  @override
  Widget build(BuildContext context) {
    return const SplashScreenWidget();
  }

  _navigateToAuth() async{
    await Future.delayed(const Duration(seconds: 2), (){
      Navigator.pushReplacementNamed(context, authScreen);
    });
  }
}

class SplashScreenWidget extends StatelessWidget {
  const SplashScreenWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Use gray for light mode and dark gray for dark mode for best contrast with white text logo
    final bgColor = isDark ? const Color(0xFF222222) : const Color(0xFF686666);
    return Scaffold(
      backgroundColor: bgColor,
      body: Center(
        child: Image.asset(
          'assets/images/celebratinglogo.png',
          width: MediaQuery.of(context).size.width * 0.8
        ),
      ),
    );
  }
}