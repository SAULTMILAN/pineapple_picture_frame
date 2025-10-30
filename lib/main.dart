import 'dart:async';
import 'package:flutter/material.dart';

void main() {
  runApp(const PineappleFrameApp());
}

class PineappleFrameApp extends StatelessWidget {
  const PineappleFrameApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pineapple Picture Frame',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF8BC34A)),
        useMaterial3: true,
      ),
      home: const PictureFrameScreen(),
    );
  }
}

class PictureFrameScreen extends StatefulWidget {
  const PictureFrameScreen({super.key});

  @override
  State<PictureFrameScreen> createState() => _PictureFrameScreenState();
}

class _PictureFrameScreenState extends State<PictureFrameScreen> {
  // ✅ Your S3 JPG URLs
  final List<String> imageUrls = const [
    "https://pineapple0786.s3.us-east-2.amazonaws.com/IMG_3215.jpeg",
    "https://pineapple0786.s3.us-east-2.amazonaws.com/IMG_2752.jpeg",
    "https://pineapple0786.s3.us-east-2.amazonaws.com/IMG_0817.jpeg",
    "https://pineapple0786.s3.us-east-2.amazonaws.com/2A3B9780-056C-4E35-9AA5-870AB401A5FC.jpeg",
  ];

  int _index = 0;
  bool _paused = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startRotationTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startRotationTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 10), (_) {
      if (!_paused && mounted) {
        setState(() {
          _index = (_index + 1) % imageUrls.length;
        });
      }
    });
  }

  void _togglePause() {
    setState(() {
      _paused = !_paused;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Picture Frame'),
        centerTitle: true,
      ),
      backgroundColor: const Color(0xFFF4F1EA),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
            final targetW =
                (constraints.maxWidth * devicePixelRatio).clamp(480, 4096).toInt();
            final targetH =
                (constraints.maxHeight * devicePixelRatio).clamp(480, 4096).toInt();

            return Center(
              child: AspectRatio(
                aspectRatio: 4 / 3,
                child: _PineappleFrame(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: Container(
                      color: Colors.black,
                      child: Image.network(
                        imageUrls[_index],
                        fit: BoxFit.contain,
                        filterQuality: FilterQuality.high,
                        cacheWidth: targetW,
                        cacheHeight: targetH,
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return const Center(child: CircularProgressIndicator());
                        },
                        errorBuilder: (context, err, stack) {
                          return const Center(
                            child: Text(
                              'Could not load image',
                              style: TextStyle(color: Colors.white),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _togglePause,
        icon: Icon(_paused ? Icons.play_arrow_rounded : Icons.pause_rounded),
        label: Text(_paused ? 'Resume' : 'Pause'),
      ),
    );
  }
}

class _PineappleFrame extends StatelessWidget {
  final Widget child;
  const _PineappleFrame({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF8D6E63), Color(0xFF5D4037)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(26),
        boxShadow: const [
          BoxShadow(blurRadius: 20, spreadRadius: 2, offset: Offset(0, 10), color: Colors.black26),
        ],
      ),
      padding: const EdgeInsets.all(10),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFFFFDF7),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE0C9A6), width: 6),
        ),
        padding: const EdgeInsets.all(12),
        child: Stack(
          fit: StackFit.expand,
          children: [
            child,
            Positioned(top: 6, left: 10, child: _PineappleBadge()),
            Positioned(top: 6, right: 10, child: _PineappleBadge()),
            Positioned(bottom: 6, left: 10, child: _PineappleBadge()),
            Positioned(bottom: 6, right: 10, child: _PineappleBadge()),
          ],
        ),
      ),
    );
  }
}

class _PineappleBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF3C7),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFF59E0B), width: 1.5),
      ),
      child: const Text('', style: TextStyle(fontSize: 16)),
    );
  }
}
