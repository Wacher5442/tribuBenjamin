import 'package:flutter/material.dart';

class FadeAnimation extends StatefulWidget {
  const FadeAnimation({Key? key, required this.child, required this.delay})
      : super(key: key);

  final Widget child;
  final double delay;

  @override
  State<FadeAnimation> createState() => _FadeAnimationState();
}

class _FadeAnimationState extends State<FadeAnimation>
    with TickerProviderStateMixin {
  late Animation<double> animation;
  late Animation<Offset> _transition;
  late AnimationController _controller;

  Widget get child => widget.child;
  double get delay => widget.delay;

  @override
  void initState() {
    _controller = AnimationController(
        vsync: this, duration: Duration(milliseconds: (1000 * delay).round()));
    animation = Tween(begin: 0.0, end: 1.0).animate(_controller);

    _transition = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
        .animate(_controller);
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _controller.forward();
    return SlideTransition(
      position: _transition,
      child: FadeTransition(
        opacity: animation,
        child: child,
      ),
    );
  }
}
