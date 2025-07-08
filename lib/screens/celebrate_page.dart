import 'package:flutter/material.dart';

class CelebratePage extends StatefulWidget {
  const CelebratePage({super.key});
  @override
  State<CelebratePage> createState() => _CelebratePageState();
}

class _CelebratePageState extends State<CelebratePage> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Post Page')),
    );
  }
}
