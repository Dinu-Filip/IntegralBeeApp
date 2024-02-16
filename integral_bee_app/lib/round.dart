import 'package:flutter/material.dart';
import 'package:integral_bee_app/match_preview.dart';
import 'package:integral_bee_app/round_preview.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'dart:io';
import 'dart:math';
import 'package:integral_bee_app/match.dart';

class Player {
  final String name;
  final String school;
  final String year;
  final bool studiesFM;
  String? lastRound;

  Player(
      {required this.name,
      required this.school,
      required this.year,
      required this.studiesFM});
}

class Integral {
  final String integral;
  final String answer;
  final String difficulty;
  bool played;
  final String years;

  Integral(
      {required this.integral,
      required this.answer,
      required this.difficulty,
      required this.played,
      required this.years});
}

class Round extends StatefulWidget {
  const Round({super.key});

  @override
  State<Round> createState() => RoundState();
}

class RoundState extends State<Round> {
  final List<List<dynamic>> matches = [[], [], []];
  final List<List<Player>> currentFinished = [];
  final List<String> rounds = ["Quarterfinal", "Semifinal", "Final"];
  final List<Integral> integrals = [];
  final Map<String, List<Integral>> remainingIntegrals = {
    "Easy": [],
    "Medium": [],
    "Hard": []
  };
  static const String playerFile = "player.txt";
  static const String integralFile = "integrals.txt";
  static const List<String> schools = ["Beths Grammar School"];
  static const Map<String, String> schoolCode = {
    "Beths Grammar School": "Beths"
  };
  bool initialised = false;
  final Map<String, int> schoolPoints = {};
  List<Player> participants = [];
  int currentRound = 0;
  late dynamic currentStage;

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
    if (round == "Semifinal" || round == "Final") {
      return 5;
    } else {
      return 3;
    }
  }

  double timePerIntegral(String round) {
    if (round == "Quarterfinal") {
      return 3;
    } else if (round == "Semifinal") {
      return 4;
    } else if (round == "Final") {
      return 5;
    } else {
      return 0.1;
    }
  }

  String integralDifficulty() {
    String roundName = rounds[currentRound];
    if (roundName == "Quarterfinal") {
      return "Medium";
    } else if (roundName == "Semifinal") {
      return "Hard";
    } else if (roundName == "Final") {
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
        numIntegrals: numberOfIntegrals(round),
      );
    });
  }

  void startRound() {
    List<List<Player>> unfinishedMatches = [];
    for (List<Player> match in matches[currentRound]) {
      if (!currentFinished.contains(match)) {
        unfinishedMatches.add(match);
      }
    }
    if (unfinishedMatches.isEmpty) {
      print("finished round");
    } else {
      setState(() {
        currentStage = MatchPreview(
            round: rounds[currentRound],
            matchData: unfinishedMatches,
            startMatch: startMatch);
      });
    }
  }

  Future<int> initialise() async {
    await initialiseParticipants();
    setRounds();
    initialiseMatches();
    String roundName = rounds[currentRound];
    currentStage = RoundPreview(
        round: roundName,
        numParticipants: matches[currentRound].length * 2,
        numIntegrals: numberOfIntegrals(roundName),
        integralTime: timePerIntegral(roundName),
        roundData: matches[currentRound],
        startRound: startRound);
    await loadIntegrals();
    return 1;
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