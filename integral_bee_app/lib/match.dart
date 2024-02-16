import 'package:flutter/material.dart';
import 'package:integral_bee_app/integral_summary.dart';
import 'package:integral_bee_app/mid_match_preview.dart';
import 'package:integral_bee_app/round.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:timer_count_down/timer_controller.dart';
import 'package:timer_count_down/timer_count_down.dart';
import 'package:integral_bee_app/match_countdown.dart';

class Match extends StatefulWidget {
  final List<Integral> integrals;
  final String round;
  final List<List<Player>> pairings;
  final String difficulty;
  final int numIntegrals;

  const Match(
      {super.key,
      required this.round,
      required this.integrals,
      required this.pairings,
      required this.difficulty,
      required this.numIntegrals});

  @override
  State<Match> createState() => MatchState();
}

class MatchState extends State<Match> {
  late int timeLimit;
  late List<List<Player>> remainingPairings =
      widget.pairings.map((List<Player> pair) => pair).toList();
  final CountdownController _controller = CountdownController(autoStart: true);
  //
  // playedIntegrals stores integrals that have been played so far
  //
  final Map<List<Player>, List<Integral>> playedIntegrals = {};
  //
  // currentIntegrals stores integrals being shown in this part of the match
  //
  final Map<List<Player>, Integral?> currentIntegrals = {};
  final Map<Player, int> playerWins = {};
  //
  // Stores the winners of their matches to progress to the next round
  //
  final List<Player> winners = [];
  int numIntegralsPlayed = 0;
  static const integralTextStyle = TextStyle(fontSize: 75);
  late Widget currentStage;
  bool initialised = false;

  void assignIntegrals() {
    if (playedIntegrals.isNotEmpty) {
      for (List<Player> pairing in currentIntegrals.keys) {
        playedIntegrals[pairing]!.add(currentIntegrals[pairing]!);
        widget.integrals.remove(currentIntegrals[pairing]);
        currentIntegrals[pairing]!.played = true;
      }
    } else {
      for (List<Player> pairing in widget.pairings) {
        playedIntegrals[pairing] = [];
        currentIntegrals[pairing] = null;
      }
    }

    for (List<Player> pairing in remainingPairings) {
      int idx = 0;
      while (idx < widget.integrals.length) {
        Integral currentIntegral = widget.integrals[idx];
        //
        // Assigns FM integral only if both players in Year 13 and study FM
        //
        if (currentIntegral.years == "13FM") {
          if (pairing[0].year == "13" &&
              pairing[0].studiesFM &&
              pairing[1].year == "13" &&
              pairing[1].studiesFM) {
            currentIntegrals[pairing] = currentIntegral;
            widget.integrals.removeAt(idx);
            break;
          }
        }
        //
        // Assigns Year 12 integral only if both players in Year 12
        //
        else if (currentIntegral.years == "12") {
          if (pairing[0].year == "12" && pairing[1].year == "12") {
            currentIntegrals[pairing] = currentIntegral;
            widget.integrals.removeAt(idx);
            break;
          }
        } else {
          currentIntegrals[pairing] = currentIntegral;
          widget.integrals.removeAt(idx);
          break;
        }
        idx += 1;
      }
    }
  }

  Widget createIntegralDisplays() {
    //
    // Integral displays show the integrals in play
    //
    late Widget integralDisplays;
    List<String> rawIntegral = [];
    for (Integral? integral in currentIntegrals.values) {
      if (integral != null) {
        rawIntegral.add(integral.integral);
      }
    }
    if (rawIntegral.length == 1) {
      //
      // Shows single integral across entire screen
      //
      integralDisplays = Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Math.tex(rawIntegral[0],
                mathStyle: MathStyle.display, textStyle: integralTextStyle)
          ]);
    } else if (rawIntegral.length == 2) {
      //
      // Shows two integrals side by side
      //
      integralDisplays =
          Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
        Math.tex(rawIntegral[0],
            mathStyle: MathStyle.display, textStyle: integralTextStyle),
        Math.tex(rawIntegral[1],
            mathStyle: MathStyle.display, textStyle: integralTextStyle)
      ]);
    } else if (rawIntegral.length == 3) {
      //
      // Shows first two integrals side by side and third integral underneath
      //
      integralDisplays = Column(children: [
        const Spacer(flex: 1),
        Expanded(
            flex: 3,
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Math.tex(rawIntegral[0], textStyle: integralTextStyle),
                  Math.tex(rawIntegral[1], textStyle: integralTextStyle)
                ])),
        const Spacer(flex: 1),
        Expanded(
            flex: 3,
            child: Math.tex(rawIntegral[2], textStyle: integralTextStyle)),
        const Spacer(flex: 1)
      ]);
    } else {
      //
      // Shows two integrals on top, two underneath
      //
      integralDisplays = Column(children: [
        const Spacer(flex: 1),
        Expanded(
            flex: 3,
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Math.tex(rawIntegral[0], textStyle: integralTextStyle),
                  Math.tex(rawIntegral[1], textStyle: integralTextStyle),
                ])),
        const Spacer(flex: 1),
        Expanded(
            flex: 3,
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Math.tex(rawIntegral[2], textStyle: integralTextStyle),
                  Math.tex(rawIntegral[3], textStyle: integralTextStyle),
                ])),
        const Spacer(flex: 1)
      ]);
    }
    return integralDisplays;
  }

  void setTimeLimit() {
    //
    // Calculates number of seconds for corresponding round
    //
    if (widget.round == "Quarterfinal") {
      timeLimit = 3 * 60;
    } else if (widget.round == "Semifinal") {
      timeLimit = 4 * 60;
    } else if (widget.round == "Final") {
      timeLimit = 5 * 60;
    } else {
      timeLimit = (3).toInt();
    }
  }

  void showIntegralSummary() {
    setState(() {
      currentStage = IntegralSummary(
          updateMatch: updateMatch, integralData: currentIntegrals);
    });
  }

  void updateMatch(Map<List<Player>, Player?> results) {
    numIntegralsPlayed += 1;
    for (List<Player> pair in results.keys) {
      Player? winner = results[pair];
      if (winner != null) {
        Player loser = pair[0] == winner ? pair[1] : pair[0];
        playerWins[winner] = playerWins[winner]! + 1;
        int numRemainingIntegrals = widget.numIntegrals - numIntegralsPlayed;
        //
        // Checks to see if losing player can draw if they get all remaining
        // integrals correct
        //
        if (playerWins[loser]! + numRemainingIntegrals < playerWins[winner]!) {
          loser.lastRound = widget.round;
          //
          // Removes pairing to show only integrals for pairs still in play
          //
          remainingPairings.remove(pair);
          currentIntegrals.remove(pair);
          winners.add(winner);
        }
      }
    }
    print("-------");
    for (List<Player> pair in widget.pairings) {
      print("${pair[0].name} vs ${pair[1].name}");
    }
    print("-------");
    for (List<Player> pair in remainingPairings) {
      print("${pair[0].name} vs ${pair[1].name}");
    }
    print("-------");
    for (Player player in playerWins.keys) {
      print("${player.name}: ${playerWins[player]}");
    }
    print("-------");

    if (numIntegralsPlayed == widget.numIntegrals ||
        remainingPairings.isEmpty) {
      print("finished round");
    } else {
      setState(() {
        currentStage = MidMatchPreview(
            pairings: widget.pairings,
            results: playerWins,
            continueMatch: continueMatch,
            round: widget.round,
            winners: winners);
      });
    }
  }

  void continueMatch() {
    setState(() {
      assignIntegrals();
      currentStage = MatchCountdown(loadMatch: loadMatch);
    });
  }

  void loadMatch() {
    initialised = true;
    setState(() {
      currentStage = Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(child: createIntegralDisplays()),
            SizedBox(
                height: MediaQuery.of(context).size.height * 0.25,
                child: Column(children: [
                  Expanded(
                      child: Countdown(
                    controller: _controller,
                    seconds: timeLimit,
                    build: (_, double time) => Text(
                      time.toString(),
                      style: const TextStyle(
                        fontSize: 100,
                      ),
                    ),
                    interval: const Duration(milliseconds: 100),
                    onFinished: () {
                      showIntegralSummary();
                    },
                  )),
                  Padding(
                      padding: const EdgeInsets.only(bottom: 50),
                      child: SizedBox(
                          height: 70,
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                    width: 200,
                                    height: 55,
                                    child: TextButton(
                                        onPressed: () {
                                          _controller.pause();
                                        },
                                        child: const Text("Pause",
                                            style: TextStyle(fontSize: 30)))),
                                const SizedBox(width: 200),
                                SizedBox(
                                    width: 200,
                                    height: 55,
                                    child: TextButton(
                                        onPressed: () {
                                          _controller.resume();
                                        },
                                        child: const Text("Resume",
                                            style: TextStyle(fontSize: 30))))
                              ])))
                ]))
          ]);
    });
  }

  void initialisePlayerWins() {
    for (List<Player> pair in widget.pairings) {
      playerWins[pair[0]] = 0;
      playerWins[pair[1]] = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!initialised) {
      setTimeLimit();
      initialisePlayerWins();
      assignIntegrals();
      currentStage = MatchCountdown(loadMatch: loadMatch);
    }

    return currentStage;
  }
}
