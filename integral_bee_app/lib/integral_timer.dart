import 'package:flutter/material.dart';
import 'package:timer_count_down/timer_controller.dart';
import 'package:timer_count_down/timer_count_down.dart';

class IntegralTimer extends StatefulWidget {
  final int time;
  final Function showIntegralSummary;

  const IntegralTimer(
      {super.key, required this.time, required this.showIntegralSummary});

  @override
  State<IntegralTimer> createState() => IntegralTimerState();
}

class IntegralTimerState extends State<IntegralTimer> {
  bool toPause = true;
  final CountdownController _controller = CountdownController(autoStart: true);
  double currentTime = 0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: MediaQuery.of(context).size.height * 0.25,
        child: Column(children: [
          Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                    padding: const EdgeInsets.only(top: 15, right: 15),
                    child: SizedBox(
                        width: 55,
                        height: 55,
                        child: IconButton(
                            onPressed: () {
                              if (toPause) {
                                _controller.pause();
                              } else {
                                _controller.resume();
                              }
                              setState(() {
                                toPause = !toPause;
                              });
                            },
                            icon: Icon(toPause ? Icons.pause : Icons.play_arrow,
                                size: 40)))),
                Countdown(
                  controller: _controller,
                  seconds: widget.time,
                  build: (_, double time) {
                    String t = "";
                    int mins = time ~/ 60;
                    int seconds = (time % 60).round();
                    if (mins < 10) {
                      t += "0";
                    }
                    t += mins.toString();

                    t += ":";
                    if (seconds < 10) {
                      t += "0";
                    }
                    t += seconds.toString();

                    return Text(
                      t,
                      style: const TextStyle(
                        fontSize: 100,
                      ),
                    );
                  },
                  interval: const Duration(milliseconds: 1000),
                  onFinished: () {
                    widget.showIntegralSummary();
                  },
                ),
                Padding(
                    padding: const EdgeInsets.only(top: 15, left: 15),
                    child: SizedBox(
                        width: 55,
                        height: 55,
                        child: IconButton(
                            onPressed: () => {widget.showIntegralSummary()},
                            icon: const Icon(Icons.done, size: 40))))
              ]),
        ]));
  }
}
