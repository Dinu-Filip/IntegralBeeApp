import 'package:flutter/material.dart';
import 'package:integral_bee_app/src/player.dart';

class MatchSummary extends StatelessWidget {
  final String round;
  final List<Player> winners;
  final Map<Player, int> scores;
  final List<List<Player>> pairings;
  final List<Widget> results = [];
  final List<String> winnerNames = [];
  final List<String> loserNames = [];
  final Function continueRound;
  final TextStyle textFieldStyle = const TextStyle(fontSize: 35);
  final Function calculatePoints;

  MatchSummary(
      {super.key,
      required this.round,
      required this.winners,
      required this.scores,
      required this.pairings,
      required this.continueRound,
      required this.calculatePoints});

  void generateResults() {
    for (List<Player> pair in pairings) {
      Player winner = winners.contains(pair[0]) ? pair[0] : pair[1];
      Player loser = pair[0] == winner ? pair[1] : pair[0];
      winnerNames.add(winner.name);
      loserNames.add(loser.name);
      String winnerSchool = winner.school;
      String schoolCode = "";
      for (String word in winnerSchool.split(" ")) {
        schoolCode += word[0].toUpperCase();
      }
      results.add(Padding(
          padding: const EdgeInsets.only(top: 10, bottom: 10),
          child:
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(
                "${winner.name} beats ${loser.name} ${scores[winner]} - ${scores[loser]}",
                style: textFieldStyle),
            Text("+${calculatePoints(winner.school)} $schoolCode",
                style: const TextStyle(
                    fontSize: 30,
                    color: Colors.green,
                    fontWeight: FontWeight.w600))
          ])));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (results.isEmpty) {
      generateResults();
    }

    return ListView(children: [
      Padding(
          padding: const EdgeInsets.only(top: 30, bottom: 30),
          child: Text("$round Match Summary",
              textAlign: TextAlign.center,
              style:
                  const TextStyle(fontSize: 45, fontWeight: FontWeight.bold))),
      FractionallySizedBox(
          widthFactor: 0.6,
          child: Column(children: [
            const Divider(color: Colors.black),
            const SizedBox(height: 10),
            Column(children: results),
            const SizedBox(height: 10),
            const Divider(color: Colors.black),
            const SizedBox(height: 10),
            Padding(
                padding: const EdgeInsets.only(top: 10, bottom: 10),
                child: Text(
                    textAlign: TextAlign.center,
                    style: textFieldStyle,
                    winnerNames.length == 1
                        ? "Well done to ${winnerNames[0]} who moves on to the next round!"
                        : "Well done to ${winnerNames.sublist(0, winnerNames.length - 1).join(", ")} and ${winnerNames[winnerNames.length - 1]} who move on to the next round!")),
            Padding(
                padding: const EdgeInsets.only(top: 10, bottom: 10),
                child: Text(
                    textAlign: TextAlign.center,
                    style: textFieldStyle,
                    loserNames.length == 1
                        ? "Thank you ${loserNames[0]} for taking part!"
                        : "Thank you ${loserNames.sublist(0, loserNames.length - 1).join(", ")} and ${loserNames[loserNames.length - 1]} for taking part!"))
          ])),
      Padding(
          padding: const EdgeInsets.only(bottom: 50, top: 20),
          child: Align(
              child: SizedBox(
                  height: 50,
                  width: 300,
                  child: TextButton(
                      onPressed: () {
                        continueRound();
                      },
                      child: const Text("Next match",
                          style: TextStyle(fontSize: 30))))))
    ]);
  }
}
