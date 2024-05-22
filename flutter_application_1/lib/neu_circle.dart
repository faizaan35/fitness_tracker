import 'package:flutter/material.dart';

class NeuCircle extends StatelessWidget {
  final Widget child;
  const NeuCircle({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      alignment: Alignment.center,
      margin: const EdgeInsets.all(40),
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xFF253D5B), // Persian blue
        boxShadow: [
          BoxShadow(
              color: Color(0xFF1C2F45),
              offset: Offset(4.0, 4.0),
              blurRadius: 15.0,
              spreadRadius: 1.0),
          BoxShadow(
              color: Color(0xFF2E4A70),
              offset: Offset(-4.0, -4.0),
              blurRadius: 15.0,
              spreadRadius: 1.0),
        ],
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF2E4A70),
            Color(0xFF253D5B),
            Color(0xFF1C2F45),
            Color(0xFF142536),
          ],
          stops: [0.1, 0.3, 0.8, 1],
        ),
      ),
      child: child,
    );
  }
}
