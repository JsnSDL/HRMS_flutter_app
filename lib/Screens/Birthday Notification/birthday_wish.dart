import 'dart:math';
import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

class AnimatedBirthdayPage extends StatefulWidget {
  final String name;
  final String wish;

  const AnimatedBirthdayPage({Key? key, required this.name, required this.wish})
      : super(key: key);

  @override
  _AnimatedBirthdayPageState createState() => _AnimatedBirthdayPageState();
}

class _AnimatedBirthdayPageState extends State<AnimatedBirthdayPage>
    with TickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade800,
      appBar: AppBar(
        backgroundColor: Colors.blue.shade800,
        elevation: 0.0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: const Icon(
              Icons.close,
              color: Colors.white,
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          _buildFloatingBalls(context),
          _buildGreetingContent(),
        ],
      ),
    );
  }

  Widget _buildFloatingBalls(BuildContext context) {
    return Stack(
      children: List.generate(20, (index) {
        return Positioned(
          left: Random().nextDouble() * MediaQuery.of(context).size.width,
          top: Random().nextDouble() * MediaQuery.of(context).size.height,
          child: _buildBall(
              Colors.primaries[Random().nextInt(Colors.primaries.length)]),
        );
      }),
    );
  }

  Widget _buildBall(Color color) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(seconds: Random().nextInt(15) + 23),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, -value * MediaQuery.of(context).size.height),
          child: Container(
            width: 20.0,
            height: 20.0,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }

  Widget _buildGreetingContent() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildAnimatedText(),
          const SizedBox(height: 20.0),
          _buildBirthdayCakeIcon(),
        ],
      ),
    );
  }

  Widget _buildAnimatedText() {
    return Container(
      width: MediaQuery.of(context).size.width *
          0.8, // Limit text width for readability
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      decoration: BoxDecoration(
        color: Colors.blue.shade900
            .withOpacity(0.8), // Adjust background color and opacity
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: AnimatedTextKit(
        animatedTexts: [
          TypewriterAnimatedText(
            'Happy Birthday ${widget.name}! ${widget.wish}',
            textStyle: const TextStyle(
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            speed: const Duration(milliseconds: 100),
          ),
        ],
        totalRepeatCount: 1,
        pause: const Duration(milliseconds: 1000),
        displayFullTextOnTap: true,
        stopPauseOnTap: true,
      ),
    );
  }

  Widget _buildBirthdayCakeIcon() {
    return ScaleTransition(
      scale: Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Curves.bounceOut,
        ),
      ),
      child: const Icon(
        Icons.cake,
        color: Colors.white,
        size: 100.0,
      ),
    );
  }
}
