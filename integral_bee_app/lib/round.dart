import 'package:flutter/material.dart';
import 'package:integral_bee_app/integral.dart';
import 'package:integral_bee_app/match_preview.dart';
import 'package:integral_bee_app/match_summary.dart';
import 'package:integral_bee_app/round_preview.dart';
import 'package:integral_bee_app/tournament_summary.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'dart:io';
import 'dart:math';
import 'package:integral_bee_app/match.dart';
import 'package:integral_bee_app/player.dart';
import 'package:integral_bee_app/draw.dart';
import 'package:integral_bee_app/settings.dart';

class Round extends StatefulWidget {
  const Round({super.key});

  @override
  State<Round> createState() => RoundState();
}

class RoundState extends State<Round> {
  final List<List<dynamic>> matches = [[], [], []];
  //
  // currentFinished stores matches that have finished as part of the current round
  //
  final List<List<Player>> currentFinished = [];
  //
  // unfinishedMatches stores matches that have not yet taken place
  //
  final List<List<Player>> unfinishedMatches = [];
  final List<String> rounds = Rounds.values.map((val) => val.round).toList();
  final List<Integral> integrals = [];
  final Map<String, List<Integral>> remainingIntegrals = {
    "Easy": [],
    "Medium": [],
    "Hard": []
  };
  final List<String> schools =
      Schools.values.map((school) => school.schoolName).toList();
  bool initialised = false;
  final Map<String, int> schoolPoints = {};
  List<Player> participants = [];
  int currentRound = 0;
  late dynamic currentStage;
  late Player winner;
  late Player runnerUp;
  late String winningSchool;

  Future<int> initialiseParticipants() async {
    String participantData = await File(playerFile).readAsString();
    List<String> splitData = participantData.split("\n");
    //
    // Removes trailing empty record
    //
    splitData.removeLast();
    participants = splitData
        .map((p) => () {
              List<String> playerData = p.split(",");
              return Player(
                  name: playerData[0],
                  school: playerData[1],
                  year: playerData[2],
                  studiesFM: playerData[3] == "true" ? true : false);
            }())
        .toList();
    return 1;
  }

  Future<int> loadIntegrals() async {
    String integralData = await File(integralFile).readAsString();
    List<String> splitData = integralData.split("\n");
    splitData.removeLast();
    //
    // Creates array of Integral objects as the definitive collection of integrals
    // to use in the tournament
    //
    for (String d in splitData) {
      List<String> intData = d.split(",");
      integrals.add(Integral(
          integral: intData[0],
          answer: intData[1],
          difficulty: intData[2],
          played: false,
          years: intData[3]));
      remainingIntegrals[integrals.last.difficulty]!.add(integrals.last);
    }
    //
    // Ensures that selection of integrals is random
    //
    for (List<Integral> integrals in remainingIntegrals.values) {
      integrals.shuffle();
    }
    return 1;
  }

  void setRounds() {
    int totalPlayers = participants.length;
    int totalRounds = (log(totalPlayers) / log(2)).ceil();
    //
    // Deducts quarters, semis and final which is already accounted for
    //
    totalRounds -= 3;
    for (int r = totalRounds; r > 0; r--) {
      rounds.insert(0, "Round $r");
      //
      // Initialises list for pairings in each round
      //
      matches.add([]);
    }
  }

  void initialiseMatches() {
    //
    // The first round is designed to produce a second round that always has a number of players
    // that is a power of 2
    //
    List<Player> initialPlayers = [];
    List<List<Player>> initialPairings = [];
    for (Player player in participants) {
      initialPlayers.add(player);
    }
    //
    // Pairings are taken from adjacent pairs of players - list is shuffled first for randomness
    //
    initialPlayers.shuffle();
    int totalPlayers = initialPlayers.length;
    double log2 = log(totalPlayers) / log(2);
    //
    // If total number of players is perfect power of 2 then a full first round can be drawn
    //
    if (log2 == log2.roundToDouble()) {
      for (int i = 0; i <= totalPlayers - 2; i += 2) {
        initialPairings.add([initialPlayers[i], initialPlayers[i + 1]]);
      }
    } else {
      int prevPowerOf2 = pow(2, log2.floor()).toInt();
      int totalRound1 = (totalPlayers - prevPowerOf2) * 2;
      for (int i = 0; i <= totalRound1 - 2; i += 2) {
        initialPairings.add([initialPlayers[i], initialPlayers[i + 1]]);
      }
      //
      // Remaining players that receive bye to 2nd round are paired with winners of round
      // 1
      //
      for (int j = totalRound1; j <= totalPlayers - 1; j += 1) {
        matches[1].add([initialPlayers[j]]);
      }
    }
    matches[0] = initialPairings;
  }

  int numberOfIntegrals(String round) {
    if (round == Rounds.semifinalRound.round ||
        round == Rounds.finalRound.round) {
      return 5;
    } else {
      return 3;
    }
  }

  double timePerIntegral(String round) {
    if (round == Rounds.quarterfinalRound.round) {
      return 3;
    } else if (round == Rounds.semifinalRound.round) {
      return 4;
    } else if (round == Rounds.finalRound.round) {
      return 5;
    } else {
      return 0.1;
    }
  }

  String integralDifficulty() {
    String roundName = rounds[currentRound];
    if (roundName == Rounds.quarterfinalRound.round) {
      return "Medium";
    } else if (roundName == Rounds.semifinalRound.round) {
      return "Hard";
    } else if (roundName == Rounds.finalRound.round) {
      return "Hard";
    } else {
      return "Easy";
    }
  }

  void startMatch(List<List<Player>> pairings) {
    String currentDifficulty = integralDifficulty();
    String round = rounds[currentRound];
    setState(() {
      currentStage = Match(
        difficulty: currentDifficulty,
        integrals: remainingIntegrals[currentDifficulty]!,
        pairings: pairings,
        round: round,
        endMatch: updateRounds,
        numIntegrals: numberOfIntegrals(round),
      );
    });
  }

  void doRound() {
    for (List<Player> match in matches[currentRound]) {
      if (!currentFinished.contains(match) &&
          !unfinishedMatches.contains(match)) {
        unfinishedMatches.add(match);
      }
    }
    if (unfinishedMatches.isEmpty) {
      //
      // Moves onto next round
      //
      currentRound += 1;
      if (currentRound == rounds.length) {
        endTournament();
      } else {
        currentFinished.clear();
        setState(() {
          String roundName = rounds[currentRound];
          currentStage = RoundPreview(
              round: roundName,
              numParticipants: matches[currentRound].length * 2,
              numIntegrals: numberOfIntegrals(roundName),
              integralTime: timePerIntegral(roundName),
              roundData: matches[currentRound],
              startRound: doRound,
              showDraw: showDraw);
        });
      }
    } else {
      setState(() {
        currentStage = MatchPreview(
            round: rounds[currentRound],
            matchData: unfinishedMatches,
            startMatch: startMatch);
      });
    }
  }

  void endTournament() {
    String winningSchool = "";
    int winSchoolPoints = 0;
    for (String school in schoolPoints.keys) {
      if (schoolPoints[school]! > winSchoolPoints) {
        winSchoolPoints = schoolPoints[school]!;
        winningSchool = school;
      }
    }
    setState(() {
      currentStage = TournamentSummary(
          winner: winner,
          runnerUp: runnerUp,
          winningSchool: winningSchool,
          winSchoolPoints: winSchoolPoints);
    });
  }

  void initialiseSchoolScores() {
    for (String school in schools) {
      schoolPoints[school] = 0;
    }
  }

  Future<int> initialise() async {
    await initialiseParticipants();
    setRounds();
    initialiseMatches();
    initialiseSchoolScores();
    String roundName = rounds[currentRound];
    currentStage = RoundPreview(
        round: roundName,
        numParticipants: matches[currentRound].length * 2,
        numIntegrals: numberOfIntegrals(roundName),
        integralTime: timePerIntegral(roundName),
        roundData: matches[currentRound],
        startRound: doRound,
        showDraw: showDraw);
    await loadIntegrals();
    return 1;
  }

  void updateRounds(List<List<Player>> pairings, List<Player> winners,
      Map<Player, int> scores) {
    for (List<Player> pair in pairings) {
      unfinishedMatches.remove(pair);
      currentFinished.add(pair);
    }

    if (currentRound == rounds.length - 1) {
      //
      // Checks if the final has finished
      //
      winner = winners[0];
      runnerUp = pairings[0][0] == winner ? pairings[0][1] : pairings[0][0];

      schoolPoints[winner.school] = schoolPoints[winner.school]! + 5;
      winningSchool = winner.school;
    } else {
      for (Player winner in winners) {
        //
        // Places winners in next round by pairing them with the first player that does
        // not have an opponent. Also addresses case where there are players leftover from
        // first round without a partner.
        //
        int idx = 0;
        bool assigned = false;
        while (idx < matches[currentRound + 1].length) {
          if (matches[currentRound + 1][idx].length == 1) {
            matches[currentRound + 1][idx].add(winner);
            assigned = true;
          }
          idx += 1;
        }
        if (!assigned) {
          matches[currentRound + 1].add([winner]);
        }
        //
        // Assigns points to school of winning player
        //
        schoolPoints[winner.school] = schoolPoints[winner.school]! + 5;
      }
    }
    setState(() {
      currentStage = MatchSummary(
          round: rounds[currentRound],
          winners: winners,
          scores: scores,
          pairings: pairings,
          continueRound: doRound);
    });
  }

  void showDraw() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                Scaffold(body: Center(child: Draw(draw: matches)))));
  }

  @override
  Widget build(BuildContext context) {
    if (!initialised) {
      initialise().then((r) {
        setState(() {
          initialised = true;
        });
      });
      return LoadingAnimationWidget.stretchedDots(
          color: Colors.black, size: 50);
    } else {
      return currentStage;
    }
  }
}
