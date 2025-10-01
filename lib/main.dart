import 'package:integral_bee_app/src/settings/add_integrals.dart';
import 'package:integral_bee_app/src/settings/add_players.dart';
import 'package:integral_bee_app/src/player.dart';
import 'package:integral_bee_app/src/settings/settings.dart';
import 'package:integral_bee_app/src/round/round.dart';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool initialised = false;
  final currentWindow = null;
  static const double paddingVal = 20;

  void onPageSelect(StatefulWidget page) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => Scaffold(body: Center(child: page))));
  }

  void loadFromPrevious() async {
    String compData = await File("compData.json").readAsString();
    if (compData == "") return;
    Map<String, dynamic> jsonContent = json.decode(compData);
    Map<Map<String, dynamic>, Player> jsonToPlayer = {};
    //
    // Creates player objects from previous player data
    //
    if (jsonContent.keys.isNotEmpty) {
      for (Map<String, dynamic> playerData in jsonContent["participants"]) {
        jsonToPlayer[playerData] = Player(
            name: playerData["name"],
            school: playerData["school"],
            year: playerData["year"],
            studiesFM: playerData["studiesFM"],
            lastRound: playerData["lastRound"]);
      }
      List<List<dynamic>> matches = [];
      for (List<dynamic> round in jsonContent["matches"]) {
        matches.add([]);

        for (List<dynamic> pairing in round) {
          Player? player1;
          Player? player2;
          for (Map<String, dynamic> playerData in jsonToPlayer.keys) {
            if (mapEquals(playerData, pairing[0])) {
              player1 = jsonToPlayer[playerData]!;
            }
            if (pairing.length == 2) {
              if (mapEquals(playerData, pairing[1])) {
                player2 = jsonToPlayer[playerData]!;
              }
            }
          }
          if (player2 != null) {
            matches.last.add([player1!, player2]);
          } else {
            matches.last.add([player1!]);
          }
        }
      }
      List<List<Player>> currentFinished = [];
      for (List<dynamic> pairings in jsonContent["currentFinished"]) {
        late Player player1;
        late Player player2;
        for (Map<String, dynamic> playerData in jsonToPlayer.keys) {
          if (mapEquals(playerData, pairings[0])) {
            player1 = jsonToPlayer[playerData]!;
          } else if (mapEquals(playerData, pairings[1])) {
            player2 = jsonToPlayer[playerData]!;
          }
        }
        for (List<Player> match in matches[jsonContent["currentRound"]]) {
          if (match[0] == player1 && match[1] == player2) {
            currentFinished.add(match);
          }
        }
      }

      List<List<Player>> unfinishedMatches = [];
      for (List<dynamic> pairings in jsonContent["unfinishedMatches"]) {
        late Player player1;
        late Player player2;
        for (Map<String, dynamic> playerData in jsonToPlayer.keys) {
          if (mapEquals(playerData, pairings[0])) {
            player1 = jsonToPlayer[playerData]!;
          } else if (mapEquals(playerData, pairings[1])) {
            player2 = jsonToPlayer[playerData]!;
          }
        }
        for (List<Player> match in matches[jsonContent["currentRound"]]) {
          if (match[0] == player1 && match[1] == player2) {
            unfinishedMatches.add(match);
          }
        }
      }
      List<Player> participants = [];
      for (Map<String, dynamic> player in jsonContent["participants"]) {
        for (Map<String, dynamic> playerData in jsonToPlayer.keys) {
          if (mapEquals(playerData, player)) {
            participants.add(jsonToPlayer[playerData]!);
          }
        }
      }

      onPageSelect(Round(
        matches: matches,
        currentFinished: currentFinished,
        unfinishedMatches: unfinishedMatches,
        schoolPoints: jsonContent["schoolPoints"],
        assignedIntegrals: jsonContent["assignedIntegrals"],
        currentRound: jsonContent["currentRound"],
        participants: participants,
        loadFromPrevious: true,
      ));
    }
  }

  Future<int> initialise() async {
    var settings = File("settings.json");
    bool settingsExists = await settings.exists();
    if (!settingsExists) {
      await updateSettings();
    } else {
      await loadSettings();
    }
    var integrals = File("integrals.txt");
    bool integralsExists = await integrals.exists();
    if (!integralsExists) {
      await integrals.writeAsString("");
    }
    var players = File("player.txt");
    bool playersExists = await players.exists();
    if (!playersExists) {
      await players.writeAsString("");
    }
    var compData = File("compData.json");
    bool compDataExists = await compData.exists();
    if (!compDataExists) {
      await compData.writeAsString(json.encode({}));
    }
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
      return Scaffold(
          body: Center(
              child: LoadingAnimationWidget.stretchedDots(
                  color: Colors.black, size: 50)));
    } else {
      return Scaffold(
        body: Center(
          child: FractionallySizedBox(
              widthFactor: 0.7,
              heightFactor: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                      padding: const EdgeInsets.only(top: 25),
                      child: Text(competitionTitle,
                          style: const TextStyle(
                              fontSize: 60, fontWeight: FontWeight.bold))),
                  Padding(
                      padding: const EdgeInsets.only(top: 20, bottom: 20),
                      child: Text(hostSchool,
                          style: const TextStyle(fontSize: 40))),
                  Expanded(
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                        Expanded(
                            flex: 1,
                            child: Column(children: [
                              Expanded(
                                  child: SizedBox(
                                      width: MediaQuery.of(context).size.width,
                                      child: Padding(
                                          padding:
                                              const EdgeInsets.all(paddingVal),
                                          child: ConstrainedBox(
                                              constraints: BoxConstraints(
                                                  maxWidth:
                                                      MediaQuery.of(context)
                                                          .size
                                                          .width,
                                                  minWidth:
                                                      MediaQuery.of(context)
                                                          .size
                                                          .width),
                                              child: ElevatedButton.icon(
                                                  icon: const Icon(
                                                      size: 35.0,
                                                      Icons.settings_outlined),
                                                  style: ElevatedButton.styleFrom(
                                                      shape:
                                                          RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10))),
                                                  onPressed: () {
                                                    onPageSelect(
                                                        const Settings());
                                                  },
                                                  label: const AutoSizeText(
                                                      "Settings",
                                                      maxLines: 1,
                                                      style: TextStyle(
                                                          fontSize: 35))))))),
                              Expanded(
                                  child: SizedBox(
                                      width: MediaQuery.of(context).size.width,
                                      child: Padding(
                                          padding: const EdgeInsets.only(
                                              left: paddingVal,
                                              right: paddingVal,
                                              bottom: paddingVal),
                                          child: ConstrainedBox(
                                              constraints: BoxConstraints(
                                                  maxWidth:
                                                      MediaQuery.of(context)
                                                          .size
                                                          .width,
                                                  minWidth:
                                                      MediaQuery.of(context)
                                                          .size
                                                          .width),
                                              child: ElevatedButton.icon(
                                                  icon: const Icon(
                                                      Icons.history,
                                                      size: 35),
                                                  style: ElevatedButton.styleFrom(
                                                      shape: RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                  10))),
                                                  onPressed: () {
                                                    loadFromPrevious();
                                                  },
                                                  label: const AutoSizeText(
                                                      textAlign:
                                                          TextAlign.center,
                                                      "Load from previous",
                                                      maxLines: 1,
                                                      style: TextStyle(
                                                          fontSize: 35))))))),
                            ])),
                        Expanded(
                            flex: 1,
                            child: SizedBox(
                                height: MediaQuery.of(context).size.height,
                                child: Padding(
                                    padding: const EdgeInsets.only(
                                        top: paddingVal, bottom: paddingVal),
                                    child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10))),
                                        onPressed: () {
                                          onPageSelect(const Round());
                                        },
                                        child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(Icons.play_circle,
                                                  size: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.05),
                                              const SizedBox(height: 10),
                                              ConstrainedBox(
                                                  constraints: BoxConstraints(
                                                    minWidth:
                                                        MediaQuery.of(context)
                                                            .size
                                                            .width,
                                                    maxWidth:
                                                        MediaQuery.of(context)
                                                            .size
                                                            .width,
                                                  ),
                                                  child: const AutoSizeText(
                                                      textAlign:
                                                          TextAlign.center,
                                                      maxLines: 1,
                                                      "Start tournament",
                                                      style: TextStyle(
                                                          fontSize: 45)))
                                            ]))))),
                        Expanded(
                            flex: 1,
                            child: Column(children: [
                              Expanded(
                                  child: SizedBox(
                                      width: MediaQuery.of(context).size.width,
                                      child: Padding(
                                          padding:
                                              const EdgeInsets.all(paddingVal),
                                          child: ConstrainedBox(
                                              constraints: BoxConstraints(
                                                  maxWidth:
                                                      MediaQuery.of(context)
                                                          .size
                                                          .width,
                                                  minWidth:
                                                      MediaQuery.of(context)
                                                          .size
                                                          .width),
                                              child: ElevatedButton.icon(
                                                  icon: const Icon(
                                                      Icons.person_2_sharp,
                                                      size: 35.0),
                                                  style: TextButton.styleFrom(
                                                      shape: RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                  10))),
                                                  onPressed: () {
                                                    onPageSelect(
                                                        const AddPlayer());
                                                  },
                                                  label: const AutoSizeText(
                                                      "Add players",
                                                      maxLines: 1,
                                                      style: TextStyle(
                                                          fontSize: 35))))))),
                              Expanded(
                                  child: SizedBox(
                                      width: MediaQuery.of(context).size.width,
                                      child: Padding(
                                          padding: const EdgeInsets.only(
                                              left: paddingVal,
                                              right: paddingVal,
                                              bottom: paddingVal),
                                          child: ConstrainedBox(
                                              constraints: BoxConstraints(
                                                  maxWidth: MediaQuery.of(context)
                                                      .size
                                                      .width,
                                                  minWidth:
                                                      MediaQuery.of(context)
                                                          .size
                                                          .width),
                                              child: ElevatedButton.icon(
                                                  icon: const Icon(Icons.add,
                                                      size: 35.0),
                                                  style: ElevatedButton.styleFrom(
                                                      shape:
                                                          RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10))),
                                                  onPressed: () {
                                                    onPageSelect(
                                                        const AddIntegrals());
                                                  },
                                                  label: const AutoSizeText(
                                                      textAlign:
                                                          TextAlign.center,
                                                      "Add integrals",
                                                      maxLines: 1,
                                                      style: TextStyle(
                                                          fontSize: 35)))))))
                            ])),
                      ])),
                  const SizedBox(height: 25)
                ],
              )),
        ),
      );
    }
  }
}
