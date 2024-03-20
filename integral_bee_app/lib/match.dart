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
  final Map<String, List<Integral>> integrals;
  final String round;
  final List<List<Player>> pairings;
  final String difficulty;
  final int numIntegrals;
  final Function updateRounds;
  final Function addUsedIntegral;
  final Function endMatch;

  const Match(
      {super.key,
      required this.round,
      required this.integrals,
      required this.pairings,
      required this.difficulty,
      required this.numIntegrals,
      required this.updateRounds,
      required this.endMatch,
      required this.addUsedIntegral});

  @override
  State<Match> createState() => MatchState();
}

class MatchState extends State<Match> {
  late int timeLimit;
  late List<List<Player>> remainingPairings =
      widget.pairings.map((List<Player> pair) => pair).toList();
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
  List<Player> winners = [];
  //
  // Stores total number of given integrals
  //
  int numIntegralsPlayed = 0;
  static const integralTextStyle = TextStyle(fontSize: 75);
  late Widget currentStage;
  bool initialised = false;
  bool toPause = true;
  late String currentDifficulty = widget.difficulty;
  List<List<Player>> completed = [];

  void assignIntegrals() {
    List<Integral> assignedIntegrals = [];
    bool selectTiebreak =
        numIntegralsPlayed >= widget.numIntegrals ? true : false;
    for (List<Player> pairing in remainingPairings) {
      int idx = 0;
      //
      // If all the integrals at a particular level of difficulty have been exhausted
      // then should go down one level of difficulty
      //
      if (widget.integrals[currentDifficulty]!.isEmpty) {
        currentDifficulty = reduceDifficulty(currentDifficulty);
      }
      while (idx < widget.integrals[currentDifficulty]!.length) {
        Integral currentIntegral = widget.integrals[currentDifficulty]![idx];
        //
        // Assigns FM integral only if both players in Year 13 and study FM
        //
        if (!selectTiebreak || currentIntegral.isTiebreak) {
          if (currentIntegral.years == "13FM") {
            if (pairing[0].year == Years.year13.year &&
                pairing[0].studiesFM &&
                pairing[1].year == Years.year13.year &&
                pairing[1].studiesFM) {
              currentIntegrals[pairing] = currentIntegral;
              currentIntegral.played = true;
              assignedIntegrals.add(currentIntegral);
              widget.integrals[currentDifficulty]!.removeAt(idx);
              break;
            }
          }
          //
          // Assigns Year 12 integral only if both players in Year 12
          //
          else if (currentIntegral.years == "12") {
            if (pairing[0].year == Years.year12.year &&
                pairing[1].year == Years.year12.year) {
              currentIntegrals[pairing] = currentIntegral;
              currentIntegral.played = true;
              assignedIntegrals.add(currentIntegral);
              widget.integrals[currentDifficulty]!.removeAt(idx);
              break;
            }
          } else {
            currentIntegrals[pairing] = currentIntegral;
            currentIntegral.played = true;
            assignedIntegrals.add(currentIntegral);
            widget.integrals[currentDifficulty]!.removeAt(idx);
            break;
          }
        }
        idx += 1;
        if (idx == widget.integrals[currentDifficulty]!.length) {
          //
          // If no tiebreak integrals at current difficulty level, then will go through
          // other integrals at same difficulty
          //
          if (selectTiebreak) {
            selectTiebreak = false;
          } else {
            currentDifficulty = reduceDifficulty(currentDifficulty);
          }
          idx = 0;
        }
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
            Flexible(
                child: FittedBox(
                    fit: BoxFit.fitWidth,
                    child: Math.tex(rawIntegral[0],
                        mathStyle: MathStyle.display,
                        textStyle: integralTextStyle)))
          ]);
    } else if (rawIntegral.length == 2) {
      //
      // Shows two integrals side by side
      //
      integralDisplays =
          Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
        Flexible(
            child: FittedBox(
                fit: BoxFit.fitWidth,
                child: Math.tex(rawIntegral[0],
                    mathStyle: MathStyle.display,
                    textStyle: integralTextStyle))),
        Flexible(
            child: FittedBox(
                fit: BoxFit.fitWidth,
                child: Math.tex(rawIntegral[1],
                    mathStyle: MathStyle.display,
                    textStyle: integralTextStyle)))
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
                  Flexible(
                      child: FittedBox(
                          fit: BoxFit.fitWidth,
                          child: Math.tex(rawIntegral[0],
                              textStyle: integralTextStyle))),
                  Flexible(
                      child: FittedBox(
                          fit: BoxFit.fitWidth,
                          child: Math.tex(rawIntegral[1],
                              textStyle: integralTextStyle)))
                ])),
        const Spacer(flex: 1),
        Flexible(
            flex: 3,
            child: FittedBox(
                fit: BoxFit.fitWidth,
                child: Math.tex(rawIntegral[2], textStyle: integralTextStyle))),
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
                  Flexible(
                      child: FittedBox(
                          fit: BoxFit.fitWidth,
                          child: Math.tex(rawIntegral[0],
                              textStyle: integralTextStyle))),
                  Flexible(
                      child: FittedBox(
                          fit: BoxFit.fitWidth,
                          child: Math.tex(rawIntegral[1],
                              textStyle: integralTextStyle))),
                ])),
        const Spacer(flex: 1),
        Expanded(
            flex: 3,
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Flexible(
                      child: FittedBox(
                          fit: BoxFit.fitWidth,
                          child: Math.tex(rawIntegral[2],
                              textStyle: integralTextStyle))),
                  Flexible(
                      child: FittedBox(
                          fit: BoxFit.fitWidth,
                          child: Math.tex(rawIntegral[3],
                              textStyle: integralTextStyle))),
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
      timeLimit = 180;
    }
  }

  void showIntegralSummary() {
    setState(() {
      currentStage = IntegralSummary(
          updateMatch: updateMatch, integralData: currentIntegrals);
    });
  }

  String reduceDifficulty(String difficulty) {
    if (difficulty == "Final") {
      return "Hard";
    } else if (difficulty == "Hard") {
      return difficulty = "Medium";
    } else if (currentDifficulty == "Medium") {
      return currentDifficulty = "Easy";
    } else {
      return "Easy";
    }
  }

  void updateMatch(Map<List<Player>, Player?> results) {
    numIntegralsPlayed += 1;
    if (numIntegralsPlayed > widget.numIntegrals) {
      //
      // Reduces difficulty every three integrals in a tiebreak
      //
      if (numIntegralsPlayed % 3 == 0) {
        currentDifficulty = reduceDifficulty(currentDifficulty);
      }
    }
    List<List<Player>> newCompleted = [];
    List<Player> newWinners = [];
    for (List<Player> pair in results.keys) {
      Player? winner = results[pair];
      if (winner != null) {
        Player loser = pair[0] == winner ? pair[1] : pair[0];
        playerWins[winner] = playerWins[winner]! + 1;
        //
        // Checks if the match is currently at a tiebreak
        //
        if (numIntegralsPlayed > widget.numIntegrals) {
          //
          // Player wins if they have just one more win than the other player
          //
          if (playerWins[winner]! > playerWins[loser]!) {
            loser.lastRound = widget.round;
            //
            // Removes pairing to show only integrals for pairs still in play
            //
            remainingPairings.remove(pair);
            newWinners.add(winner);
            newCompleted.add(pair);
            currentIntegrals.remove(pair);
          }
        } else {
          int numRemainingIntegrals = widget.numIntegrals - numIntegralsPlayed;
          //
          // Checks to see if losing player can draw if they get all remaining
          // integrals correct
          //
          if (playerWins[loser]! + numRemainingIntegrals <
              playerWins[winner]!) {
            loser.lastRound = widget.round;
            remainingPairings.remove(pair);
            newCompleted.add(pair);
            currentIntegrals.remove(pair);
            newWinners.add(winner);
          }
        }
      } else if (numIntegralsPlayed >= widget.numIntegrals) {
        Player? winner;
        Player? loser;
        if (playerWins[pair[0]]! > playerWins[pair[1]]!) {
          winner = pair[0];
          loser = pair[1];
        } else if (playerWins[pair[0]]! < playerWins[pair[1]]!) {
          winner = pair[1];
          loser = pair[0];
        }
        if (winner != null) {
          loser!.lastRound = widget.round;
          remainingPairings.remove(pair);
          newCompleted.add(pair);
          currentIntegrals.remove(pair);
          newWinners.add(winner);
        }
      }
    }
    winners += newWinners;
    completed += newCompleted;
    if (remainingPairings.isEmpty) {
      widget.updateRounds(newCompleted, newWinners, playerWins);
      widget.endMatch(completed, winners, playerWins);
    } else {
      widget.updateRounds(newCompleted, newWinners, playerWins);
      setState(() {
        currentStage = MidMatchPreview(
            pairings: widget.pairings,
            results: playerWins,
            continueMatch: continueMatch,
            round: widget.round,
            winners: winners,
            tiebreak: numIntegralsPlayed >= widget.numIntegrals ? true : false);
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
