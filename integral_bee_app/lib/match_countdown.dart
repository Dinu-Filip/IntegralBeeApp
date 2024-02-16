import 'dart:async';
import 'package:flutter/material.dart';

class MatchCountdown extends StatefulWidget {
  final Function loadMatch;

  const MatchCountdown({super.key, required this.loadMatch});

  @override
  State<MatchCountdown> createState() => MatchCountdownState();
}

class MatchCountdownState extends State<MatchCountdown> {
  int _counter = 3;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _startMatchCountdown();
  }

  void _startMatchCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_counter > 0) {
          _counter--;
        } else {
          _timer.cancel();
          widget.loadMatch();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    String timerText = "";
    if (_counter == 0) {
      timerText = "Integrate!";
    } else {
      timerText = _counter.toString();
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(opacity: animation, child: child);
      },
      child: Text(
        timerText,
        key: ValueKey<int>(_counter),
        style: const TextStyle(fontSize: 100),
      ),
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }
}
