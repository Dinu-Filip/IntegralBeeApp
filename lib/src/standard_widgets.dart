import 'package:flutter/material.dart';

class StageTitle1 extends StatelessWidget {
  final String text;

  const StageTitle1({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(20),
        child: Text(text,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 60, fontWeight: FontWeight.bold)));
  }
}

class StageTitle2 extends StatelessWidget {
  final String text;

  const StageTitle2({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(20),
        child: Text(text,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 50, fontWeight: FontWeight.bold)));
  }
}

class StageHeader extends StatelessWidget {
  final String text;

  const StageHeader({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(5),
        child: Text(text,
            textAlign: TextAlign.center, style: const TextStyle(fontSize: 40)));
  }
}
