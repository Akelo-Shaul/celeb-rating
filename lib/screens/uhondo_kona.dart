import 'dart:ui'; // Keep this import for ImageFilter.blur

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/uhondo.dart'; // Assuming this exists
import '../services/uhondo_service.dart'; // Assuming this exists
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../widgets/uhondo_list.dart';

import '../utils/route.dart'; // Ensure this is the correct import for the new version

class UhondoKona extends StatefulWidget {
  const UhondoKona({super.key});

  @override
  State<UhondoKona> createState() => _UhondoKonaState();
}

class _UhondoKonaState extends State<UhondoKona> {
  List<Uhondo>? _posts;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  Future<void> _loadPosts() async {
    final posts = await UhondoService.fetchUhondoPosts();
    if (!mounted) return;
    setState(() {
      _posts = posts;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Uhondo Kona'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : UhondoList(
              uhondos: _posts ?? [],
              onTap: (post) {
                context.pushWebView(url: post.blogLink);
              },
            ),
    );
  }
}

