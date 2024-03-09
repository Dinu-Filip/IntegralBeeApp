import 'package:flutter/material.dart';
import 'package:integral_bee_app/integral_summary.dart';
import 'package:integral_bee_app/integral_timer.dart';
import 'package:integral_bee_app/mid_match_preview.dart';
import 'package:integral_bee_app/integral.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:integral_bee_app/settings.dart';
import 'package:integral_bee_app/match_countdown.dart';
import 'package:integral_bee_app/player.dart';

class Match extends StatefulWidget {
  final List<Integral> integrals;
  final String round;
  final List<List<Player>> pairings;
  final String difficulty;
  final int numIntegrals;
  final Function updateRounds;
  final Function addUsedIntegral;

  const Match(
      {super.key,
      required this.round,
      required this.integrals,
      required this.pairings,
      required this.difficulty,
      required this.numIntegrals,
      required this.updateRounds,
      required this.addUsedIntegral});

  @override
  State<Match> createState() => MatchState();
}

class MatchState extends State<Match> {
  late int timeLimit;
  late List<List<Player>> remainingPairings =
      widget.pairings.map((List<Player> pair) => pair).toList();
  //
  // playedIntegrals stores integrals that have been played so far
  //
  final Map<List<Player>, List<Integral>> playedIntegrals = {};
  //
  // currentIntegrals stores integrals being shown in this part of the match
  //
  final Map<List<Player>, Integral?> currentIntegrals = {};
  //
  // Stores number of wins each player has in their match
  //
  final Map<Player, int> playerWins = {};
  //
  // Stores the winners of their matches to progress to the next round
  //
  final List<Player> winners = [];
  int numIntegralsPlayed = 0;
  static const integralTextStyle = TextStyle(fontSize: 75);
  late Widget currentStage;
  bool initialised = false;
  bool toPause = true;

  void assignIntegrals() {
    List<Integral> assignedIntegrals = [];
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
          if (pairing[0].year == Years.year13.year &&
              pairing[0].studiesFM &&
              pairing[1].year == Years.year13.year &&
              pairing[1].studiesFM) {
            currentIntegrals[pairing] = currentIntegral;
            assignedIntegrals.add(currentIntegral);
            widget.integrals.removeAt(idx);
            break;
          }
        }
        //
        // Assigns Year 12 integral only if both players in Year 12
        //
        else if (currentIntegral.years == Years.year12.year) {
          if (pairing[0].year == Years.year12.year &&
              pairing[1].year == Years.year12.year) {
            currentIntegrals[pairing] = currentIntegral;
            assignedIntegrals.add(currentIntegral);
            widget.integrals.removeAt(idx);
            break;
          }
        } else {
          currentIntegrals[pairing] = currentIntegral;
          assignedIntegrals.add(currentIntegral);
          widget.integrals.removeAt(idx);
          break;
        }
        idx += 1;
      }
    }
    widget.addUsedIntegral(
        assignedIntegrals.map((integral) => integral.integral).toList());
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
    if (widget.round == Rounds.quarterfinalRound.round) {
      timeLimit = 180;
    } else if (widget.round == Rounds.semifinalRound.round) {
      timeLimit = 240;
    } else if (widget.round == Rounds.finalRound.round) {
      timeLimit = 300;
    } else {
      timeLimit = 150;
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
    List<List<Player>> completed = [];
    List<Player> currentWinners = [];
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
          print(pair);
          remainingPairings.remove(pair);
          completed.add(pair);
          currentIntegrals.remove(pair);
          winners.add(winner);
          currentWinners.add(winner);
        }
      }
    }

    if (numIntegralsPlayed == widget.numIntegrals ||
        remainingPairings.isEmpty) {
      widget.updateRounds(completed, currentWinners, playerWins, true);
    } else {
      widget.updateRounds(completed, currentWinners, playerWins, false);
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
            IntegralTimer(
                time: timeLimit, showIntegralSummary: showIntegralSummary)
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
