import 'package:flutter/material.dart';
import 'dart:io';

import 'package:integral_bee_app/settings.dart';

class AddPlayer extends StatefulWidget {
  const AddPlayer({super.key});

  @override
  State<AddPlayer> createState() => AddPlayerState();
}

class AddPlayerState extends State<AddPlayer> {
  static const String fileName = "player.txt";
  static List<String> schools = schoolNames;
  static const Color primaryColour = Color(0xFF03045E);
  static const Color secondaryColour = Color(0xFFFFFFFF);
  late Color btnBackground = secondaryColour;
  late Color borderColour = primaryColour;
  late Color btnTextColour = primaryColour;

  final TextEditingController _nameController = TextEditingController();
  String _yearValue = "Year 13";
  String _currentSchool = schools[0];
  bool _studyingFM = true;

  void addPlayer() async {
    //
    // Writes data to external CSV
    //
    String playerData =
        "${_nameController.text},$_currentSchool,$_yearValue,${_studyingFM.toString()}\n";
    await File(fileName).writeAsString(playerData, mode: FileMode.append);
    setState(() {
      _nameController.text = "";
    });
  }

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
        widthFactor: 0.3,
        child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
          const Padding(
              padding: EdgeInsets.all(40), child: Text("Add student")),
          Padding(
              padding: const EdgeInsets.only(top: 10, bottom: 10),
              child: TextFormField(
                  textInputAction: TextInputAction.none,
                  onFieldSubmitted: (event) {
                    addPlayer();
                  },
                  cursorColor: primaryColour,
                  style: const TextStyle(fontSize: 18),
                  controller: _nameController,
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: primaryColour, width: 2)),
                      hintText: "Enter student name"))),
          Padding(
              padding: const EdgeInsets.only(top: 10, bottom: 10),
              child: SizedBox(
                  height: 50,
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Select year group",
                            style: TextStyle(
                                fontWeight: FontWeight.w500, fontSize: 19)),
                        const SizedBox(width: 40),
                        DropdownButton(
                            value: _yearValue,
                            items: const [
                              DropdownMenuItem(
                                  value: "Year 12",
                                  child: Text("Year 12",
                                      style: TextStyle(fontSize: 19))),
                              DropdownMenuItem(
                                  value: "Year 13",
                                  child: Text("Year 13",
                                      style: TextStyle(fontSize: 19)))
                            ],
                            onChanged: (String? newYear) {
                              setState(() {
                                _yearValue = newYear!;
                              });
                            })
                      ]))),
          Padding(
              padding: const EdgeInsets.only(top: 10, bottom: 10),
              child: SizedBox(
                  height: 50,
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Select school",
                            style: TextStyle(
                                fontWeight: FontWeight.w500, fontSize: 19)),
                        const SizedBox(width: 40),
                        DropdownButton(
                            value: _currentSchool,
                            items: schools.map((String school) {
                              return DropdownMenuItem(
                                  value: school,
                                  child: Text(school,
                                      style: const TextStyle(fontSize: 19)));
                            }).toList(),
                            onChanged: (String? newSchool) {
                              setState(() {
                                _currentSchool = newSchool!;
                              });
                            })
                      ]))),
          Padding(
              padding: const EdgeInsets.only(top: 10, bottom: 10),
              child: SizedBox(
                  height: 50,
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Studying FM?",
                            style: TextStyle(
                                fontWeight: FontWeight.w500, fontSize: 19)),
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
              child: MouseRegion(
                  onEnter: (event) {
                    setState(() {
                      btnBackground = primaryColour;
                      btnTextColour = secondaryColour;
                    });
                  },
                  onExit: (event) {
                    setState(() {
                      btnBackground = secondaryColour;
                      btnTextColour = primaryColour;
                    });
                  },
                  child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                          backgroundColor: btnBackground,
                          shape: const StadiumBorder(),
                          side: BorderSide(width: 3, color: borderColour)),
                      onPressed: addPlayer,
                      child: Text("Submit",
                          style:
                              TextStyle(fontSize: 19, color: btnTextColour))))),
        ]));
  }
}
