import 'package:flutter/material.dart';
import 'package:integral_bee_app/player.dart';

class TournamentSummary extends StatelessWidget {
  final Player winner;
  final Player runnerUp;
  final String winningSchool;
  final int winSchoolPoints;

  const TournamentSummary(
      {super.key,
      required this.winner,
      required this.runnerUp,
      required this.winningSchool,
      required this.winSchoolPoints});

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
        widthFactor: 0.6,
        child: ListView(children: [
          const Padding(
              padding: EdgeInsets.only(top: 20, bottom: 20),
              child: Text(
                  textAlign: TextAlign.center,
                  "Results of the Integral Bee 2024",
                  style: TextStyle(fontSize: 50, fontWeight: FontWeight.w500))),
          const SizedBox(height: 30),
          const Text(
              textAlign: TextAlign.center,
              "The overall winner is",
              style: TextStyle(fontSize: 40)),
          Text(
              textAlign: TextAlign.center,
              winner.name,
              style:
                  const TextStyle(fontSize: 60, fontWeight: FontWeight.bold)),
          const SizedBox(height: 30),
          const Text(
              textAlign: TextAlign.center,
              "The runner-up is",
              style: TextStyle(fontSize: 35)),
          Text(
              textAlign: TextAlign.center,
              runnerUp.name,
              style:
                  const TextStyle(fontSize: 50, fontWeight: FontWeight.w600)),
          const SizedBox(height: 20),
          const Divider(color: Colors.black),
          const SizedBox(height: 20),
          const Text(
              textAlign: TextAlign.center,
              "The winning school is",
              style: TextStyle(fontSize: 40)),
          Text(
              textAlign: TextAlign.center,
              winningSchool,
              style:
                  const TextStyle(fontSize: 55, fontWeight: FontWeight.w600)),
          Text(
              textAlign: TextAlign.center,
              "with $winSchoolPoints points",
              style: const TextStyle(fontSize: 40)),
          const SizedBox(height: 20),
          const Divider(color: Colors.black),
          const SizedBox(height: 40),
          const Text(
              textAlign: TextAlign.center,
              "Thank you all for taking part! We hope you enjoyed it!",
              style: TextStyle(fontSize: 40)),
          const SizedBox(height: 40)
        ]));
  }
}
