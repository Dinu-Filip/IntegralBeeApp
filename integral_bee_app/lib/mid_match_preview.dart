import 'package:flutter/material.dart';
import 'package:integral_bee_app/player.dart';
import 'package:integral_bee_app/standard_widgets.dart';

class MidMatchPreview extends StatelessWidget {
  final List<List<Player>> pairings;
  final Map<Player, int> results;
  final Function continueMatch;
  final String round;
  final List<Player> winners;
  final TextStyle nameStyle =
      const TextStyle(fontSize: 40, color: Colors.black);
  final TextStyle scoreStyle = const TextStyle(fontSize: 30);

  const MidMatchPreview(
      {super.key,
      required this.pairings,
      required this.results,
      required this.continueMatch,
      required this.round,
      required this.winners});

  List<Widget> createDisplays() {
    List<Widget> playerDisplays = [];
    for (List<Player> pair in pairings) {
      List<Widget> singleDisplay = [];
      if (winners.contains(pair[0]) || winners.contains(pair[1])) {
        Player winner = winners.contains(pair[0]) ? pair[0] : pair[1];
        //
        // Makes the name of the winning player bold if the match has already
        // concluded
        //
        singleDisplay.add(RichText(
            text: TextSpan(children: [
          TextSpan(
              text: pair[0].name,
              style: TextStyle(
                  color: winner == pair[0] ? Colors.red : Colors.black,
                  fontWeight:
                      winner == pair[0] ? FontWeight.bold : FontWeight.normal,
                  fontSize: 40)),
          TextSpan(text: " vs. ", style: nameStyle),
          TextSpan(
              text: pair[1].name,
              style: TextStyle(
                  color: winner == pair[1] ? Colors.red : Colors.black,
                  fontWeight:
                      winner == pair[1] ? FontWeight.bold : FontWeight.normal,
                  fontSize: 40))
        ])));
      } else {
        singleDisplay
            .add(Text("${pair[0].name} vs. ${pair[1].name}", style: nameStyle));
      }
      singleDisplay.add(
          Text("${results[pair[0]]} - ${results[pair[1]]}", style: scoreStyle));
      playerDisplays.add(Padding(
          padding: const EdgeInsets.only(top: 20, bottom: 20),
          child: Column(children: singleDisplay)));
    }
    return playerDisplays;
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      StageTitle2(text: "$round match progress"),
      Expanded(child: Column(children: createDisplays())),
      Padding(
          padding: const EdgeInsets.only(bottom: 50),
          child: SizedBox(
              height: 60,
              width: 400,
              child: TextButton(
                  onPressed: () => {continueMatch()},
                  child:
                      const Text("Continue", style: TextStyle(fontSize: 30)))))
    ]);
  }
}
