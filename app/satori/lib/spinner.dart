import 'dart:async';

import 'package:flutter/material.dart';

@immutable
class Spinner extends StatefulWidget {
  final Duration wait;
  final Color color;
  final double size;
  const Spinner({
    required this.size,
    required this.wait,
    required this.color,
    Key? key,
  }) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _SpinnerState createState() => _SpinnerState();
}

class _SpinnerState extends State<Spinner> with TickerProviderStateMixin {
  final int durationV = 1236067;
  final int durationH = 2000000;

  late AnimationController _controllerH;
  late AnimationController _controllerV;
  late Animation<Offset> _offsetAnimationH;
  late Animation<Offset> _offsetAnimationV;

  void createAnimations() {
    _controllerH = AnimationController(
      duration: Duration(microseconds: durationH),
      vsync: this,
    );
    _controllerH.value = .5;
    _controllerH.repeat(reverse: true);
    _controllerV = AnimationController(
      duration: Duration(microseconds: durationV),
      vsync: this,
    );
    _controllerV.value = .5;
    _controllerV.repeat(reverse: true);
    _offsetAnimationH = Tween<Offset>(
      begin: const Offset(-20, 0),
      end: const Offset(0, 0),
    ).animate(CurvedAnimation(
      parent: _controllerH,
      curve: Curves.easeInOut,
    ));
    _offsetAnimationV = Tween<Offset>(
      begin: const Offset(0, 0),
      end: const Offset(0, 12.36067),
    ).animate(CurvedAnimation(
      parent: _controllerV,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void initState() {
    super.initState();
    createAnimations();
    _controllerH.value = .5;
    _controllerV.value = .5;
    _controllerH.repeat(reverse: true);
    _controllerV.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controllerH.dispose();
    _controllerV.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final icon = Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(
          color: widget.color,
          borderRadius: BorderRadius.circular(100),
        ),
        child: Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.color,
          ),
        ));
    return SlideTransition(
        position: _offsetAnimationH,
        child: SlideTransition(
          position: _offsetAnimationV,
          child: icon,
        ));
  }
}
