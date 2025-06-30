import 'package:flutter/material.dart';

class StreamPage extends StatefulWidget {
  const StreamPage({super.key});
  @override
  State<StreamPage> createState() => _StreamPageState();
}

class _StreamPageState extends State<StreamPage> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Stream Page')),
    );
  }
}
