import 'package:celebrating/widgets/flick_screen.dart';
import 'package:flutter/material.dart';

import '../models/flick.dart';
import '../services/search_service.dart';

class FlicksPage extends StatefulWidget {
  const FlicksPage({super.key});
  @override
  State<FlicksPage> createState() => _FlicksPageState();
}

class _FlicksPageState extends State<FlicksPage> {
  late List<Flick> _flickResults = [];

  @override
  void initState() {
    super.initState();
    _loadFlicks();
  }

  Future<void> _loadFlicks() async {
    final results = await SearchService.searchFlicks('all');
    setState(() {
      _flickResults = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FlickScreen(flicks: _flickResults)
    );
  }
}
