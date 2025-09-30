import 'package:flutter/material.dart';
import 'dart:io';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:integral_bee_app/src/standard_widgets.dart';

class AddPlayer extends StatefulWidget {
  const AddPlayer({super.key});

  @override
  State<AddPlayer> createState() => AddPlayerState();
}

class AddPlayerState extends State<AddPlayer> {
  static const String fileName = "player.txt";
  TextStyle inputStyle = const TextStyle(fontSize: 25);
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController schoolController = TextEditingController();
  String _yearValue = "Year 13";
  bool _studyingFM = true;
  List<Widget> playerEntries = [];
  bool initialised = false;

  void addPlayer() async {
    //
    // Writes data to external CSV
    //
    String name = _nameController.text;
    String school = schoolController.text;
    if (name.isNotEmpty && school.isNotEmpty) {
      //
      // Removes characters that may interfere with processing of player data
      //
      name.replaceAll(",", "");
      name.replaceAll("\\", "");
      school.replaceAll(",", "");
      school.replaceAll("\\", "");
      String playerData =
          "$name,$school,${_yearValue.replaceAll("Year ", "")},${_studyingFM.toString()}\n";
      await File(fileName).writeAsString(playerData, mode: FileMode.append);
      //
      // Adds entry to show in window
      //
      int numInList = playerEntries.length;
      playerEntries.add(Container(
          margin: const EdgeInsets.all(10),
          decoration: BoxDecoration(
              border: Border.all(width: 1, color: Colors.grey),
              borderRadius: BorderRadius.circular(12)),
          child: Padding(
              padding: const EdgeInsets.all(15),
              child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                        flex: 2,
                        child: Text(name,
                            textAlign: TextAlign.start,
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.w500))),
                    Expanded(
                        flex: 2,
                        child: Text(
                          school,
                          textAlign: TextAlign.center,
                        )),
                    Expanded(
                        flex: 1,
                        child: Text(_yearValue, textAlign: TextAlign.center)),
                    (() {
                      if (_studyingFM) {
                        return const Expanded(
                            flex: 1,
                            child: Text("FM",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.indigo)));
                      } else {
                        return const Spacer(flex: 1);
                      }
                    }()),
                    IconButton(
                        onPressed: () => removePlayer(numInList,
                            "$name,$school,${_yearValue.replaceAll("Year ", "")},${_studyingFM.toString()}"),
                        icon: const Icon(Icons.close))
                  ]))));
      setState(() {
        _nameController.text = "";
      });
    }
  }

  Future<int> generatePlayerList() async {
    var file = File("player.txt");
    String rawData = await file.readAsString();
    List<String> playerData = rawData.split("\n");
    playerData.removeLast();
    //
    // Generates widget showing existing player data
    //
    for (String player in playerData) {
      List<String> temp = player.split(",");
      playerEntries.add(Container(
          margin: const EdgeInsets.all(10),
          decoration: BoxDecoration(
              border: Border.all(width: 1, color: Colors.grey),
              borderRadius: BorderRadius.circular(12)),
          child: Padding(
              padding: const EdgeInsets.all(15),
              child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                        flex: 2,
                        child: Text(temp[0],
                            textAlign: TextAlign.start,
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.w500))),
                    Expanded(
                        flex: 2,
                        child: Text(
                          temp[1],
                          textAlign: TextAlign.center,
                        )),
                    Expanded(
                        flex: 1,
                        child: Text("Year ${temp[2]}",
                            textAlign: TextAlign.center)),
                    (() {
                      if (temp[3] == "true") {
                        return const Expanded(
                            flex: 1,
                            child: Text("FM",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.indigo)));
                      } else {
                        return const Spacer(flex: 1);
                      }
                    }()),
                    IconButton(
                        onPressed: () =>
                            removePlayer(playerData.indexOf(player), player),
                        icon: const Icon(Icons.close))
                  ]))));
    }
    return 1;
  }

  void removePlayer(int idx, String player) async {
    var file = File("player.txt");
    String rawData = await file.readAsString();
    List<String> playerData = rawData.split("\n");
    playerData.remove(player);
    await file.writeAsString(playerData.join("\n"));

    setState(() {
      playerEntries[idx] = Container(height: 0);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!initialised) {
      generatePlayerList().then((r) {
        setState(() {
          initialised = true;
        });
      });
      return LoadingAnimationWidget.stretchedDots(
          color: Colors.black, size: 50);
    } else {
      return FractionallySizedBox(
          widthFactor: 0.7,
          child: Column(children: [
            const Padding(
                padding: EdgeInsets.all(40),
                child: StageTitle2(text: "Add student")),
            Expanded(
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Expanded(
                      flex: 4,
                      child: ListView(
                          //crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Padding(
                                padding:
                                    const EdgeInsets.only(top: 10, bottom: 10),
                                child: TextFormField(
                                    style: inputStyle,
                                    autofocus: true,
                                    textInputAction: TextInputAction.none,
                                    onFieldSubmitted: (event) {
                                      addPlayer();
                                    },
                                    controller: _nameController,
                                    decoration: const InputDecoration(
                                        hintText: "Enter student name"))),
                            Padding(
                                padding:
                                    const EdgeInsets.only(top: 10, bottom: 10),
                                child: SizedBox(
                                    height: 50,
                                    child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text("Select year group",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 25)),
                                          const SizedBox(width: 40),
                                          DropdownButton(
                                              value: _yearValue,
                                              items: const [
                                                DropdownMenuItem(
                                                    value: "Year 12",
                                                    child: Text("Year 12",
                                                        style: TextStyle(
                                                            fontSize: 19))),
                                                DropdownMenuItem(
                                                    value: "Year 13",
                                                    child: Text("Year 13",
                                                        style: TextStyle(
                                                            fontSize: 19)))
                                              ],
                                              onChanged: (String? newYear) {
                                                setState(() {
                                                  _yearValue = newYear!;
                                                });
                                              })
                                        ]))),
                            Padding(
                                padding:
                                    const EdgeInsets.only(top: 10, bottom: 10),
                                child: SizedBox(
                                    height: 50,
                                    child: TextFormField(
                                        onFieldSubmitted: (event) {
                                          addPlayer();
                                        },
                                        controller: schoolController,
                                        style: inputStyle,
                                        decoration: const InputDecoration(
                                            hintText: "Enter school")))),
                            Padding(
                                padding:
                                    const EdgeInsets.only(top: 10, bottom: 10),
                                child: SizedBox(
                                    height: 50,
                                    child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text("Studying FM?",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 25)),
                                          const SizedBox(width: 40),
                                          Checkbox(
                                              value: _studyingFM,
                                              onChanged: (bool? newStudyingFM) {
                                                setState(() {
                                                  _studyingFM = newStudyingFM!;
                                                });
                                              })
                                        ]))),
                            const SizedBox(height: 50),
                            SizedBox(
                                height: 50,
                                width: double.infinity,
                                child: TextButton(
                                    onPressed: addPlayer,
                                    child: const Text("Submit",
                                        style: TextStyle(
                                          fontSize: 25,
                                        )))),
                          ])),
                  const SizedBox(width: 40),
                  Expanded(
                      flex: 3,
                      child: SingleChildScrollView(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: playerEntries)))
                ])),
            const SizedBox(height: 30),
            SizedBox(
                height: 40,
                width: 300,
                child: TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text("Back", style: TextStyle(fontSize: 20)))),
            const SizedBox(height: 100)
          ]));
    }
  }
}
