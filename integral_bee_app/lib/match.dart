import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:math';

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

class Match extends StatefulWidget {
  const Match({super.key});

  @override
  State<Match> createState() => MatchState();
}

class MatchState extends State<Match> {
  final List<List<dynamic>> matches = [[], [], []];
  final List<String> rounds = ["Quarterfinal", "Semifinal", "Final"];
  static const String playerFile = "player.txt";
  static const List<String> schools = ["Beths Grammar School"];
  bool initialised = false;
  final Map<String, int> schoolPoints = {};
  List<Player> participants = [];
  int currentRound = 0;

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

  @override
  Widget build(BuildContext context) {
    if (!initialised) {
      initialiseParticipants().then((r) {
        setRounds();
        initialiseMatches();
      });
    }
    return const Text("");
  }
}