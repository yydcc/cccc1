library flutter_animate;

import 'package:flutter/widgets.dart';

class FlutterAnimate {
  static Widget fadeIn({
    required Widget child,
    Duration duration = const Duration(milliseconds: 500),
  }) {
    return _FadeIn(child: child, duration: duration);
  }
}

class _FadeIn extends StatefulWidget {
  final Widget child;
  final Duration duration;

  _FadeIn({required this.child, required this.duration});

  @override
  __FadeInState createState() => __FadeInState();
}

class __FadeInState extends State<_FadeIn> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _animation = Tween(begin: 0.0, end: 1.0).animate(_controller);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: widget.child,
    );
  }
}