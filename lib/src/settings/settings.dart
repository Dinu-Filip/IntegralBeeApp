import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:integral_bee_app/src/standard_widgets.dart';

enum Rounds {
  quarterfinalRound("Quarterfinal"),
  semifinalRound("Semifinal"),
  finalRound("Final");

  final String round;
  const Rounds(this.round);
}

List<String> schoolNames = [];

enum Years {
  allYears("all"),
  year12("12"),
  year13("13");

  final String year;
  const Years(this.year);
}

const String playerFile = "storage/player.txt";
const String integralFile = "storage/integrals.txt";

Map<String, int> timePerRound = {
  "other": 120,
  Rounds.quarterfinalRound.round: 180,
  Rounds.semifinalRound.round: 240,
  Rounds.finalRound.round: 300,
};

Map<String, int> integralsPerRound = {
  "other": 3,
  Rounds.quarterfinalRound.round: 3,
  Rounds.semifinalRound.round: 5,
  Rounds.finalRound.round: 5,
};

List<String> difficulties = ["Easy", "Medium", "Hard", "Final"];

String hostSchool = "[no school entered]";

String competitionTitle = "Integration Bee ${DateTime.now().year}";

Future<int> updateSettings() async {
  var file = File("settings.json");
  Map<String, dynamic> settingsData = {
    "host_school": hostSchool,
    "competition_title": competitionTitle,
    "time_per_round": timePerRound,
    "num_integrals": integralsPerRound
  };
  var jsonData = json.encode(settingsData);
  await file.writeAsString(jsonData);
  await loadSettings();
  return 1;
}

Future<int> loadSettings() async {
  var file = File("settings.json");
  String settingsData = await file.readAsString();

  if (settingsData.isNotEmpty) {
    Map<String, dynamic> rawData = json.decode(settingsData);
    Map<String, int> tempTimePerRound = {};
    Map<String, dynamic> rawTimePerRound = rawData["time_per_round"];
    Map<String, int> tempIntegralsPerRound = {};
    Map<String, dynamic> rawIntegralsPerRound = rawData["num_integrals"];
    for (String round in rawTimePerRound.keys) {
      tempTimePerRound[round] = rawTimePerRound[round];
    }
    for (String round in rawIntegralsPerRound.keys) {
      tempIntegralsPerRound[round] = rawIntegralsPerRound[round];
    }

    hostSchool = rawData["host_school"];
    competitionTitle = rawData["competition_title"];
    timePerRound = tempTimePerRound;
    integralsPerRound = tempIntegralsPerRound;
  } else {
    await updateSettings();
  }
  return 1;
}

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => SettingsState();
}

class SettingsState extends State<Settings> {
  Map<String, TextEditingController> controllers = {
    "host school": TextEditingController(text: hostSchool),
    "competition title": TextEditingController(text: competitionTitle),
    "time per round":
        TextEditingController(text: timePerRound.values.join("/")),
    "integrals per round":
        TextEditingController(text: integralsPerRound.values.join("/")),
  };
  List<String> errors = [];
  bool valid = false;
  TextStyle inputStyle = const TextStyle(fontSize: 25);

  void saveChanges() async {
    valid = true;
    errors.clear();
    //
    // Ensures that the school name contains only spaces and letters
    //
    if (!RegExp(r'^[a-zA-Z\s]*$').hasMatch(controllers["host school"]!.text)) {
      errors.add(
          "School name '${controllers["host school"]!.text}' cannot have any special characters");
      valid = false;
    }
    //
    // Ensures that the competition title contains only spaces and letters
    //
    if (!RegExp(r'^[a-zA-Z0-9\s]*$')
        .hasMatch(controllers["competition title"]!.text)) {
      errors.add(
          "Competition title '${controllers["competition title"]!.text}' cannot have any special characters");
      valid = false;
    }
    //
    // Ensures one time given for each round
    //
    List<String> timesPerRound = controllers["time per round"]!.text.split("/");
    if (timesPerRound.length != 4) {
      errors.add(
          "Exactly one time (in seconds) can be specified for each round (other/quarterfinal/semifinal/final)");
      valid = false;
    }
    //
    // Ensures each time valid integer and within acceptable range
    //
    for (String time in timesPerRound) {
      if (int.tryParse(time) == null) {
        errors.add("$time in times per round is not a valid integer");
        valid = false;
      } else if (int.tryParse(time)! < 10 || int.tryParse(time)! > 600) {
        errors
            .add("$time in times per round must be between 10 and 600 seconds");
        valid = false;
      }
    }
    // Checks number of integrals valid odd integer and within acceptable range
    //
    List<String> intsPerRound =
        controllers["integrals per round"]!.text.split("/");
    if (intsPerRound.length != 4) {
      errors.add(
          "The number of integrals must be specified for each round (other/quarterfinal/semifinal/final)");
      valid = false;
    }

    for (String num in intsPerRound) {
      if (int.tryParse(num) == null) {
        errors.add(
            "$num in number of integrals per round is not a valid integer");
        valid = false;
      } else if (int.tryParse(num)! < 1 || int.tryParse(num)! > 9) {
        errors.add(
            "$num in number of integrals per round must be an odd number between 1 and 9");
        valid = false;
      } else if (int.tryParse(num)! % 2 == 0) {
        errors
            .add("$num in number of integrals per round must be an odd number");
        valid = false;
      }
    }
    if (valid) {
      hostSchool = controllers["host school"]!.text;
      competitionTitle = controllers["competition title"]!.text;
      List<String> rounds = timePerRound.keys.toList();
      List<String> inputtedTimes =
          controllers["time per round"]!.text.split("/");
      List<String> inputtedNumIntegrals =
          controllers["integrals per round"]!.text.split("/");
      for (int i = 0; i < rounds.length; i++) {
        timePerRound[rounds[i]] = int.parse(inputtedTimes[i]);
        integralsPerRound[rounds[i]] = int.parse(inputtedNumIntegrals[i]);
      }
      await updateSettings();
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
        alignment: Alignment.topCenter,
        widthFactor: 0.5,
        child: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
          const StageTitle2(text: "Settings"),
          const SizedBox(height: 40),
          Expanded(
              flex: 5,
              child: ListView(
                  //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(children: [
                      Expanded(
                          flex: 1,
                          child: Text("Host school", style: inputStyle)),
                      Expanded(
                          flex: 2,
                          child: TextFormField(
                              controller: controllers["host school"],
                              style: inputStyle))
                    ]),
                    Row(children: [
                      Expanded(
                          flex: 1,
                          child: Text("Competition title", style: inputStyle)),
                      Expanded(
                          flex: 2,
                          child: TextFormField(
                              controller: controllers["competition title"],
                              style: inputStyle))
                    ]),
                    Row(children: [
                      Expanded(
                          flex: 1,
                          child: Text("Times per round", style: inputStyle)),
                      Expanded(
                          flex: 2,
                          child: Tooltip(
                              message:
                                  "(rounds before quarterfinal)/(quarterfinal)/(semifinal)/(final)",
                              child: TextFormField(
                                  controller: controllers["time per round"],
                                  style: inputStyle)))
                    ]),
                    Row(children: [
                      Expanded(
                          flex: 1,
                          child: Text("Num. integrals per round",
                              style: inputStyle)),
                      Expanded(
                          flex: 2,
                          child: Tooltip(
                              message:
                                  "(rounds before quarterfinal)/(quarterfinal)/(semifinal)/(final)",
                              child: TextFormField(
                                  controller:
                                      controllers["integrals per round"],
                                  style: inputStyle)))
                    ]),
                    SizedBox(
                        width: 300,
                        height: 50,
                        child: TextButton(
                            onPressed: saveChanges,
                            child: const Text("Save changes",
                                style: TextStyle(fontSize: 30))))
                  ])),
          const SizedBox(height: 20),
          Expanded(
              flex: 3,
              child: (() {
                if (valid && errors.isEmpty) {
                  return const Text("Saved!",
                      style: TextStyle(
                          fontSize: 30,
                          color: Colors.green,
                          fontWeight: FontWeight.w600));
                } else {
                  return ListView(
                      children: errors
                          .map((error) => Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.error, color: Colors.red),
                                    const SizedBox(width: 15),
                                    Flexible(
                                        child: Text(error,
                                            style: const TextStyle(
                                                fontSize: 20,
                                                color: Colors.red,
                                                fontWeight: FontWeight.w600)))
                                  ]))
                          .toList());
                }
              }())),
          SizedBox(
              height: 40,
              width: 300,
              child: TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("Back", style: TextStyle(fontSize: 20)))),
          const SizedBox(height: 30)
        ]));
  }
}
