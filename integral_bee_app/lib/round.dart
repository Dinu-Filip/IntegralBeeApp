import 'package:flutter/material.dart';
import 'package:integral_bee_app/integral.dart';
import 'package:integral_bee_app/match_preview.dart';
import 'package:integral_bee_app/match_summary.dart';
import 'package:integral_bee_app/round_preview.dart';
import 'package:integral_bee_app/tournament_summary.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'dart:io';
import 'dart:convert';
import 'dart:math';
import 'package:integral_bee_app/match.dart';
import 'package:integral_bee_app/player.dart';
import 'package:integral_bee_app/draw.dart';
import 'package:integral_bee_app/settings.dart';

class Round extends StatefulWidget {
  final List<List<dynamic>>? matches;
  final List<List<Player>>? currentFinished;
  final List<List<Player>>? unfinishedMatches;
  final Map<String, dynamic>? schoolPoints;
  final List<dynamic>? assignedIntegrals;
  final int? currentRound;
  final List<Player>? participants;
  final bool loadFromPrevious;
  const Round(
      {super.key,
      this.matches,
      this.currentFinished,
      this.unfinishedMatches,
      this.schoolPoints,
      this.assignedIntegrals,
      this.currentRound,
      this.participants,
      this.loadFromPrevious = false});

  @override
  State<Round> createState() => RoundState();
}

class RoundState extends State<Round> {
  //
  // Stores the pairings of the tournament
  //
  List<List<dynamic>> matches = [[], [], []];
  //
  // Stores matches that have finished as part of the current round
  //
  List<List<Player>> currentFinished = [];
  //
  // Stores matches that have not yet taken place as part of the current round
  //
  List<List<Player>> unfinishedMatches = [];
  //
  // Stores names of the rounds
  //
  final List<String> rounds = Rounds.values.map((val) => val.round).toList();
  //
  // Stores available integrals
  //
  final List<Integral> integrals = [];
  //
  // Stores integrals that have not been shown
  //
  final Map<String, List<Integral>> remainingIntegrals = {
    "Easy": [],
    "Medium": [],
    "Hard": [],
    "Final": [],
  };
  //
  // Stores names of participating schools
  //
  final Map<String, List<Player>> schools = {};

  //
  // Stores whether attributes have been initialised for tournament
  //
  bool initialised = false;
  //
  // Stores points earned per school
  //
  Map<String, dynamic> schoolPoints = {};
  //
  // Stores all participants in tournament
  //
  List<Player> participants = [];
  //
  // Stores index of current round in matches array
  //
  int currentRound = 0;
  //
  // Stores the number of participants in the school with the highest number of participants
  //
  int maxInSchool = 0;
  //
  // Stores widget corresponding to the current stage in the tournament
  //
  late dynamic currentStage;
  //
  // Stores overall winning player
  //
  late Player winner;
  //
  // Stores runner up
  //
  late Player runnerUp;
  //
  // Stores name of winning school
  //
  late String winningSchool;

  Future<bool> initialiseParticipants() async {
    String participantData = await File(playerFile).readAsString();
    List<String> splitData = participantData.split("\n");
    //
    // Removes trailing empty record
    //
    splitData.removeLast();
    //
    // At least 4 participants required for competition
    //
    if (splitData.length < 5) {
      return false;
    }
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

    var file = File("compData.json");
    String jsonString = await file.readAsString();
    Map<String, dynamic> jsonContent = json.decode(jsonString);
    jsonContent["participants"] =
        participants.map((player) => player.toJson()).toList();
    jsonString = json.encode(jsonContent);
    await file.writeAsString(jsonString);
    return true;
  }

  Future<bool> loadIntegrals() async {
    String integralData = await File(integralFile).readAsString();
    List<String> splitData = integralData.split("\n");
    splitData.removeLast();
    if (splitData.isEmpty) {
      return false;
    }

    //
    // Creates array of Integral objects as the definitive collection of integrals
    // to use in the tournament
    //
    Map<String, List<String>> tempDifficulties = {
      "Easy": [],
      "Medium": [],
      "Hard": [],
      "Final": []
    };

    for (String d in splitData) {
      List<String> temp = d.trim().split(",");
      tempDifficulties[temp[2]]!.add(d);
    }
    //
    // Keeps track of current integral number
    //
    int currentIdx = 0;
    for (String key in tempDifficulties.keys) {
      List<String> currentDifficultyIntegrals = tempDifficulties[key]!;
      for (String d in currentDifficultyIntegrals) {
        currentIdx += 1;
        List<String> intData = d.trim().split(",");
        //
        // Checks that any integrals have not already been shown if tournament loaded
        // from previous
        //
        if (widget.assignedIntegrals != null) {
          if (widget.assignedIntegrals!.contains(intData[0])) {
            continue;
          }
        }
        integrals.add(Integral(
            integral: intData[0],
            answer: intData[1],
            difficulty: intData[2],
            played: false,
            years: intData[3],
            isTiebreak: intData.length == 4 ? false : true,
            idx: currentIdx));
        // isTiebreak: intData[4] == "true" ? true : false
        remainingIntegrals[integrals.last.difficulty]!.add(integrals.last);
      }
    }
    //
    // Ensures that selection of integrals is random
    //
    for (List<Integral> integrals in remainingIntegrals.values) {
      integrals.shuffle();
    }

    return true;
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
      if (!widget.loadFromPrevious) {
        matches.add([]);
      }
    }
  }

  void initialiseMatches() {
    //
    // The first round is designed to produce a second round that always has a number of players
    // that is a power of 2
    //
    List<Player> initialPlayers = [];
    List<List<Player>> initialPairings = [];
    bool allShuffled = false;
    //
    // Orders participants so that participants from different schools will be paired first
    //
    int currentIdx = 0;
    while (!allShuffled) {
      allShuffled = true;
      for (String school in schools.keys) {
        if (currentIdx < schools[school]!.length) {
          initialPlayers.add(schools[school]![currentIdx]);
          allShuffled = false;
        }
      }
      currentIdx += 1;
    }
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
      // Remaining players receive bye to second round
      //
      for (int j = totalRound1; j <= totalPlayers - 1; j += 2) {
        if (j == totalPlayers - 1) {
          matches[1].add([initialPlayers[j]]);
        } else {
          matches[1].add([initialPlayers[j], initialPlayers[j + 1]]);
        }
      }
    }
    matches[0] = initialPairings;
    for (List<Player> pairing in initialPairings) {
      unfinishedMatches.add(pairing);
    }
  }

  int numberOfIntegrals(String round) {
    if (integralsPerRound.containsKey(round)) {
      return integralsPerRound[round]!;
    } else {
      return integralsPerRound["other"]!;
    }
  }

  int timePerIntegral(String round) {
    if (timePerRound.containsKey(round)) {
      return timePerRound[round]!;
    } else {
      return timePerRound["other"]!;
    }
  }

  String integralDifficulty() {
    String roundName = rounds[currentRound];
    if (roundName == Rounds.quarterfinalRound.round) {
      return "Medium";
    } else if (roundName == Rounds.semifinalRound.round) {
      return "Hard";
    } else if (roundName == Rounds.finalRound.round) {
      return "Final";
    } else {
      return "Easy";
    }
  }

  void startMatch(List<List<Player>> pairings) {
    String currentDifficulty = integralDifficulty();
    String round = rounds[currentRound];
    setState(() {
      currentStage = Match(
        addUsedIntegral: addUsedIntegral,
        difficulty: currentDifficulty,
        integrals: remainingIntegrals,
        pairings: pairings,
        round: round,
        updateRounds: updateRounds,
        endMatch: endMatch,
        numIntegrals: numberOfIntegrals(round),
        errorMoreIntegrals: errorMoreIntegrals,
      );
    });
  }

  void errorMoreIntegrals() {
    setState(() {
      currentStage = AlertDialog(
          title: const Text("More integrals needed"),
          content: const Text(
              "All available integrals have been exhausted. Please add more integrals before continuing with the tournament"),
          actions: <Widget>[
            TextButton(
                onPressed: () => {Navigator.pop(context)},
                child: const Text("Back to home"))
          ]);
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
        updateCompRoundData();
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
              showDraw: showDraw,
              schoolPoints: schoolPoints);
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
    if (widget.loadFromPrevious) {
      if (matches.last[0][0].lastRound == null) {
        winner = matches.last[0][0];
        runnerUp = matches.last[0][1];
      } else {
        winner = matches.last[0][1];
        runnerUp = matches.last[0][0];
      }
    }
    matches.add([
      [winner]
    ]);
    setState(() {
      currentStage = TournamentSummary(
          winner: winner,
          runnerUp: runnerUp,
          winningSchool: winningSchool,
          winSchoolPoints: winSchoolPoints,
          showDraw: showDraw);
    });
  }

  void initialiseSchoolData() {
    //
    // Groups participants by school
    //
    for (Player player in participants) {
      if (!schoolNames.contains(player.school)) {
        schoolNames.add(player.school);
      }
      if (schools.keys.contains(player.school)) {
        schools[player.school]!.add(player);
      } else {
        schools[player.school] = [player];
      }
    }
    //
    // Initialises points for school as 0
    //
    schoolNames = schools.keys.toList();
    if (!widget.loadFromPrevious) {
      for (String school in schoolNames) {
        schoolPoints[school] = 0;
      }
    }
    //
    // Shuffles students from each school to ensure randomised pairings
    //
    for (String school in schools.keys) {
      schools[school]!.shuffle();
    }
    //
    // Initialises maxInSchool to use when calculating number of points
    //
    for (List<Player> schoolPlayers in schools.values) {
      if (schoolPlayers.length > maxInSchool) {
        maxInSchool = schoolPlayers.length;
      }
    }
  }

  Future<int> initialise() async {
    if (widget.loadFromPrevious) {
      //
      // Loads competition data from in progress tournament
      //
      matches = widget.matches!;
      currentFinished = widget.currentFinished!;
      unfinishedMatches = widget.unfinishedMatches!;
      currentRound = widget.currentRound!;
      schoolPoints = widget.schoolPoints!;
      participants = widget.participants!;
      setRounds();
      initialiseSchoolData();
      await loadIntegrals();
      doRound();
    } else {
      //
      // Clears any previously stored competition data
      //
      await clearCompData();
      bool participantsLoaded = await initialiseParticipants();
      bool integralsLoaded = await loadIntegrals();
      if (!participantsLoaded) {
        currentStage = AlertDialog(
            title: const Text("More participants needed"),
            content: const Text(
                "Four or fewer students were found. Please go to 'Add player' and input data for additional students"),
            actions: <Widget>[
              TextButton(
                  onPressed: () => {Navigator.pop(context)},
                  child: const Text("Back to home"))
            ]);
      } else if (!integralsLoaded) {
        currentStage = AlertDialog(
            title: const Text("More integrals needed"),
            content: const Text(
                "No integrals were found. Please go to 'Add integrals' and input data for additional integrals"),
            actions: <Widget>[
              TextButton(
                  onPressed: () => {Navigator.pop(context)},
                  child: const Text("Back to home"))
            ]);
      } else {
        setRounds();
        initialiseSchoolData();
        initialiseMatches();
        String roundName = rounds[currentRound];
        currentStage = RoundPreview(
            round: roundName,
            numParticipants: matches[currentRound].length * 2,
            numIntegrals: numberOfIntegrals(roundName),
            integralTime: timePerIntegral(roundName),
            roundData: matches[currentRound],
            startRound: doRound,
            showDraw: showDraw,
            schoolPoints: schoolPoints);

        updateCompRoundData();
      }
    }
    return 1;
  }

  void updateRounds(List<List<Player>> pairings, List<Player> winners,
      Map<Player, int> scores) {
    //
    // Updates progress of round in external storage
    //
    for (List<Player> pair in pairings) {
      unfinishedMatches.remove(pair);
      if (!currentFinished.contains(pair)) {
        currentFinished.add(pair);
      }
    }

    if (winners.isNotEmpty && currentRound == rounds.length - 1) {
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
        bool assignForSchool = true;
        while (!assigned) {
          while (idx < matches[currentRound + 1].length) {
            if (matches[currentRound + 1][idx].length == 1) {
              //
              // Prioritises pairing a student with a student from a different school
              //
              if (assignForSchool) {
                if (matches[currentRound + 1][idx][0].school != winner.school) {
                  matches[currentRound + 1][idx].add(winner);
                  assigned = true;
                  break;
                }
              } else {
                matches[currentRound + 1][idx].add(winner);
                assigned = true;
                break;
              }
            }
            idx += 1;
          }
          idx = 0;
          if (assignForSchool) {
            assignForSchool = false;
          } else if (!assignForSchool && !assigned) {
            break;
          }
        }
        if (!assigned) {
          matches[currentRound + 1].add([winner]);
        }
        //
        // Assigns points to school of winning player
        //
        assignPoints(winner.school);
      }
    }
    if (pairings.isNotEmpty) {
      updateCompPairData();
    }
  }

  int calculatePoints(String school) {
    return (((maxInSchool / schools[school]!.length) *
                exp(0.45 * (currentRound + 1))) *
            10)
        .round();
  }

  void assignPoints(String school) {
    //
    // Calculates number of points to assign based on number of participants
    // in school and the current round
    //
    schoolPoints[school] = schoolPoints[school]! + calculatePoints(school);
  }

  void endMatch(List<List<Player>> pairings, List<Player> winners,
      Map<Player, int> scores) {
    setState(() {
      currentStage = MatchSummary(
          round: rounds[currentRound],
          winners: winners,
          scores: scores,
          pairings: pairings,
          continueRound: doRound,
          calculatePoints: calculatePoints);
    });
  }

  void showDraw() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => Scaffold(
                body: Center(child: Draw(draw: matches, rounds: rounds)))));
  }

  void addUsedIntegral(List<String> integrals) async {
    //
    // Adds shown integrals to external file
    //
    var file = File("compData.json");
    String jsonString = await file.readAsString();
    Map<String, dynamic> jsonContent = json.decode(jsonString);
    jsonContent["assignedIntegrals"] += integrals;
    jsonString = json.encode(jsonContent);
    file.writeAsString(jsonString);
  }

  void updateCompPairData() async {
    var file = File("compData.json");
    String jsonString = await file.readAsString();
    Map<String, dynamic> jsonContent = json.decode(jsonString);
    jsonContent["unfinishedMatches"] =
        unfinishedMatches.map((e) => [e[0].toJson(), e[1].toJson()]).toList();
    jsonContent["currentFinished"] =
        currentFinished.map((e) => [e[0].toJson(), e[1].toJson()]).toList();
    jsonContent["schoolPoints"] = schoolPoints;
    jsonContent["matches"] = convertMatchDatatoJSON();
    jsonContent["participants"] = participants.map((e) => e.toJson()).toList();
    jsonString = json.encode(jsonContent);
    await file.writeAsString(jsonString);
  }

  List<List<dynamic>> convertMatchDatatoJSON() {
    //
    // Converts match data into a form that cna be stored in external JSON
    //
    List<List<dynamic>> matchJSON = [];
    for (int i = 0; i < matches.length; i++) {
      matchJSON.add([]);
      for (List<Player> pair in matches[i]) {
        if (pair.length == 1) {
          matchJSON[i].add([pair[0].toJson()]);
        } else {
          matchJSON[i].add([pair[0].toJson(), pair[1].toJson()]);
        }
      }
    }
    return matchJSON;
  }

  Future<int> updateCompRoundData() async {
    var file = File("compData.json");
    String jsonString = await file.readAsString();
    Map<String, dynamic> jsonContent = json.decode(jsonString);
    jsonContent["unfinishedMatches"] =
        unfinishedMatches.map((e) => [e[0].toJson(), e[1].toJson()]).toList();
    jsonContent["currentRound"] = currentRound;
    jsonContent["currentFinished"].clear();
    jsonContent["matches"] = convertMatchDatatoJSON();
    jsonContent["schoolPoints"] = schoolPoints;
    jsonContent["participants"] = participants.map((e) => e.toJson()).toList();
    jsonString = json.encode(jsonContent);
    await file.writeAsString(jsonString);
    return 1;
  }

  Future<int> clearCompData() async {
    var file = File("compData.json");
    String jsonString = await file.readAsString();
    Map<String, dynamic> jsonContent = json.decode(jsonString);
    jsonContent = {
      "matches": [],
      "unfinishedMatches": [],
      "currentFinished": [],
      "currentRound": 0,
      "assignedIntegrals": [],
      "schoolPoints": {},
      "participants": []
    };
    jsonString = json.encode(jsonContent);
    await file.writeAsString(jsonString);
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
