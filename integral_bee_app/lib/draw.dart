import 'package:flutter/material.dart';
import 'package:integral_bee_app/player.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:integral_bee_app/standard_widgets.dart';

class Draw extends StatefulWidget {
  final List<List<dynamic>> draw;

  const Draw({super.key, required this.draw});

  @override
  State<Draw> createState() => DrawState();
}

class DrawState extends State<Draw> {
  static const TextStyle labelStyle = TextStyle(fontSize: 18);
  BoxConstraints bracketConstraints = const BoxConstraints(minHeight: 1000);
  final List<Widget> brackets = [];

  List<dynamic> orderPairs() {
    List<dynamic> orderedDraw = [];
    //
    // latestAdded used to check if latest non-empty round (which determines
    // order of all previous rounds) has been inserted into orderedDraw
    //
    bool latestAdded = false;
    List<dynamic> lastRound = [];
    for (int i = widget.draw.length - 1; i >= 1; i--) {
      if (widget.draw[i].isNotEmpty) {
        if (!latestAdded) {
          orderedDraw.add(widget.draw[i].map((pair) => pair).toList());
          lastRound = widget.draw[i].map((pair) => pair).toList();
          latestAdded = true;
        }
        List<Player> roundPlayers = [];
        //
        // prevRoundPairs stores ordered pairs from previous round
        //
        List<List<Player>> prevRoundPairs = [];
        for (List<Player> pair in lastRound) {
          roundPlayers.add(pair[0]);
          if (pair.length > 1) {
            roundPlayers.add(pair[1]);
          }
        }
        //
        // Sorts the pairings in the previous round in the order that the
        // winners are given so pairings are adjacent
        //
        for (Player player in roundPlayers) {
          bool pairAdded = false;
          for (List<Player> pair in widget.draw[i - 1]) {
            if (pair.contains(player)) {
              prevRoundPairs.add(pair);
              pairAdded = true;
            }
          }
          //
          // In the case that a player received a bye to the second round
          //
          if (!pairAdded) {
            prevRoundPairs.add([player]);
          }
        }
        orderedDraw.insert(0, prevRoundPairs);
        lastRound = prevRoundPairs;
      }
    }
    if (orderedDraw.isEmpty) {
      orderedDraw.add(widget.draw[0].map((pair) => pair).toList());
    }
    //
    // When still on first round
    //
    bool firstRoundPlayed = true;
    for (List<Player> pair in widget.draw[0]) {
      if (!orderedDraw[0].contains(pair)) {
        orderedDraw[0].add(pair);
        firstRoundPlayed = false;
      }
    }
    if (!firstRoundPlayed) {
      orderedDraw[1].clear();
    }
    return orderedDraw;
  }

  void createBrackets(BuildContext context) {
    List<dynamic> draw = orderPairs();

    double bracketWidth = 200;

    for (int i = 0; i < draw.length; i++) {
      if (draw[i].isEmpty) {
        break;
      }
      //
      // Orders the pairs in each rounds so that each bracket leads onto the
      // winner in the next round
      //
      List<Widget> pairings = [];
      List<Widget> lines = [];
      for (int j = 0; j < draw[i].length; j++) {
        //
        // In the case that a player received a bye to the next round
        //
        if (draw[i][j].length == 1) {
          Player player1 = draw[i][j][0];
          pairings.add(Expanded(
              flex: 2,
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                        textAlign: TextAlign.center,
                        player1.name,
                        style: labelStyle)
                  ])));
          lines.add(const Spacer(flex: 2));
        } else {
          Player player1 = draw[i][j][0];
          pairings.add(Expanded(
              flex: 1,
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                        textAlign: TextAlign.center,
                        player1.name,
                        style: labelStyle)
                  ])));
          Player player2 = draw[i][j][1];
          pairings.add(Expanded(
              flex: 1,
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(player2.name,
                        textAlign: TextAlign.center, style: labelStyle)
                  ])));
          lines.add(Expanded(
              flex: 2,
              child: Padding(
                  padding: const EdgeInsets.only(top: 5, bottom: 5),
                  child: SvgPicture.asset("assets/bracket.svg",
                      fit: BoxFit.fitHeight))));
        }
      }
      brackets.add(
          SizedBox(width: bracketWidth, child: Column(children: pairings)));
      brackets.add(SizedBox(width: 50, child: Column(children: lines)));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (brackets.isEmpty) {
      createBrackets(context);
    }
    return Column(children: [
      const StageTitle2(text: "Tournament draw"),
      const SizedBox(height: 20),
      Expanded(child: Row(children: brackets)),
      const SizedBox(height: 20),
      SizedBox(
          width: 400,
          height: 50,
          child: TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Go back", style: TextStyle(fontSize: 30)))),
      const SizedBox(height: 20)
    ]);
  }
}
