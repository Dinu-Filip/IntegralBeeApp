import 'package:flutter/material.dart';
import 'package:integral_bee_app/player.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:integral_bee_app/standard_widgets.dart';

class Draw extends StatefulWidget {
  final List<List<dynamic>> draw;
  final List<String> rounds;

  const Draw({super.key, required this.draw, required this.rounds});

  @override
  State<Draw> createState() => DrawState();
}

class DrawState extends State<Draw> {
  static const TextStyle labelStyle =
      TextStyle(fontSize: 18, color: Colors.black, fontWeight: FontWeight.w500);
  static const TextStyle winnerStyle =
      TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.red);
  static const TextStyle loserStyle =
      TextStyle(fontSize: 18, decoration: TextDecoration.lineThrough);
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

    brackets.add(const SizedBox(width: 50));
    double height = draw[0].length * 80.0;

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
                        style:
                            player1.lastRound == null ? labelStyle : loserStyle)
                  ])));
          lines.add(const Spacer(flex: 2));
        } else {
          Player player1 = draw[i][j][0];
          Player player2 = draw[i][j][1];
          bool played = true;
          if (player1.lastRound == null &&
              player2.lastRound == null &&
              i == 0) {
            played = false;
          }
          pairings.add(Expanded(
              flex: 1,
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                        textAlign: TextAlign.center,
                        player1.name,
                        style: played
                            ? (player1.lastRound != null
                                ? loserStyle
                                : winnerStyle)
                            : labelStyle)
                  ])));
          pairings.add(Expanded(
              flex: 1,
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(player2.name,
                        textAlign: TextAlign.center,
                        style: played
                            ? (player2.lastRound != null
                                ? loserStyle
                                : winnerStyle)
                            : labelStyle)
                  ])));
          lines.add(Expanded(
              flex: 2,
              child: Padding(
                  padding: const EdgeInsets.only(top: 5, bottom: 5),
                  child: SvgPicture.asset("assets/bracket.svg",
                      fit: BoxFit.fitHeight))));
        }
      }
      brackets.add(SizedBox(
          height: height,
          width: bracketWidth,
          child: Column(
              children: <Widget>[
                    SizedBox(
                        height: 50,
                        child: Text(
                            i < widget.rounds.length ? widget.rounds[i] : "",
                            style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 30,
                                color: Colors.indigoAccent)))
                  ] +
                  pairings)));
      brackets.add(SizedBox(
          width: 50,
          height: height,
          child:
              Column(children: <Widget>[const SizedBox(height: 50)] + lines)));
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
      Expanded(child: SingleChildScrollView(child: Row(children: brackets))),
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
