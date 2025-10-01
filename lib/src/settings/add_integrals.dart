import 'package:flutter/material.dart';
import 'package:integral_bee_app/src/standard_widgets.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

class AddIntegrals extends StatefulWidget {
  const AddIntegrals({super.key});

  @override
  State<AddIntegrals> createState() => AddIntegralsState();
}

class AddIntegralsState extends State<AddIntegrals> {
  String? newPath;
  String? newFileName;
  bool showSaved = false;
  List<Padding> errors = [];
  List<String> validDifficulties = ["Easy", "Medium", "Hard", "Final"];
  List<String> validYearGroups = ["all", "12", "13FM"];
  bool fileValid = false;
  final ScrollController errorController = ScrollController();
  TextStyle primaryStyle = const TextStyle(
      color: Colors.red, fontSize: 20, fontWeight: FontWeight.w500);
  TextStyle secondaryStyle = const TextStyle(
      color: Colors.black, fontSize: 20, fontWeight: FontWeight.w500);

  void uploadFile() async {
    FilePickerResult? result = await FilePicker.platform
        .pickFiles(allowedExtensions: [".txt", ".csv"]);
    if (result != null) {
      PlatformFile file = result.files.first;
      newPath = file.path!;
      newFileName = file.name;
      validateFile().then((event) => {
            setState(() {
              showSaved = false;
            })
          });
    }
  }

  void saveNewFile() async {
    if (newPath != null) {
      if (fileValid && !showSaved) {
        var newFile = File(newPath!);
        String newFileData = await newFile.readAsString();
        var currentFile = File("integrals.txt");
        await currentFile.writeAsString(newFileData);
        setState(() {
          showSaved = true;
        });
      }
    }
  }

  Future<int> validateFile() async {
    errors.clear();
    fileValid = false;

    if (newPath != null) {
      var newFile = File(newPath!);
      String newIntegralData = await newFile.readAsString();
      List<String> splitData = newIntegralData.split("\n");
      if (splitData.isNotEmpty) {
        splitData.removeLast();
      }
      List<RichText> errorData = [];
      for (String record in splitData) {
        int idx = splitData.indexOf(record);
        List<String> d = record.trim().split(",");
        if (d.length != 5) {
          errorData.add(RichText(
              text: TextSpan(children: [
            TextSpan(text: record.trim(), style: primaryStyle),
            TextSpan(
                style: secondaryStyle,
                text:
                    " must have exactly five items: (integral),(answer),(difficulty),(year groups),(is tiebreak) (line ${idx + 1})")
          ])));
        } else if (!validDifficulties.contains(d[2])) {
          errorData.add(RichText(
              text: TextSpan(children: [
            TextSpan(text: "${d[2]} in ", style: secondaryStyle),
            TextSpan(text: record.trim(), style: primaryStyle),
            TextSpan(
                text:
                    " is not a valid difficulty (Easy, Medium, Hard, Final) (line ${idx + 1})",
                style: secondaryStyle)
          ])));
        } else if (!validYearGroups.contains(d[3])) {
          errorData.add(RichText(
              text: TextSpan(children: [
            TextSpan(text: "${d[3]} in ", style: secondaryStyle),
            TextSpan(text: record.trim(), style: primaryStyle),
            TextSpan(
                style: secondaryStyle,
                text:
                    " is not a valid year group (all, 12, 13FM) (line ${idx + 1})")
          ])));
        } else if (d[4] != "true" && d[4] != "false") {
          errorData.add(RichText(
              text: TextSpan(children: [
            TextSpan(
                style: const TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.w500),
                text: "${d[4]} for is tiebreak in "),
            TextSpan(style: primaryStyle, text: record.trim()),
            TextSpan(
                style: secondaryStyle,
                text: " must be either true or false (line ${idx + 1})")
          ])));
        } else {
          fileValid = true;
        }
      }

      for (RichText error in errorData) {
        errors.add(Padding(
            padding: const EdgeInsets.all(10),
            child: Row(children: [
              const Icon(Icons.error, color: Colors.red),
              const SizedBox(width: 10),
              Flexible(child: error)
            ])));
      }
    } else {
      fileValid = true;
    }
    return 1;
  }

  void generateAnswerDoc() async {
    //
    // Generates LaTeX showing integral in first column and answer in the next column
    //
    String? newFile = await FilePicker.platform.saveFile(
        dialogTitle: "Save integral answer data",
        fileName: "integral_answers.txt",
        allowedExtensions: [".txt"]);

    if (newFile != null) {
      var file = File(newFile);
      var integralData = await File("integrals.txt").readAsString();
      List<String> splitIntegrals = integralData.split("\n");
      splitIntegrals.removeLast();
      String newFileData = r"""
                          \documentclass[]{article}
                          \usepackage[left=2cm, right=2cm, top=2cm, bottom=2cm]{geometry}
                          \usepackage{amsmath}
                          \usepackage{longtable}
                          \usepackage{amssymb}
                          \title{All Integrals with Answers}
                          \author{}
                          \date{13/03/2024}

                          \begin{document}

                          \maketitle
                          \begin{Large}
                          """;
      Map<String, List<List<String>>> difficulties = {
        "Easy": [],
        "Medium": [],
        "Hard": [],
        "Final": []
      };

      for (String integralItem in splitIntegrals) {
        List<String> d = integralItem.trim().split(",");
        difficulties[d[2]]!.add(d);
      }
      int idx = 1;
      for (String difficulty in difficulties.keys) {
        newFileData += "\\section*{$difficulty} \n"
            r"""
                        \renewcommand*{\arraystretch}{2}
                        \begin{longtable}{l c c}
                        """;
        for (List<String> d in difficulties[difficulty]!) {
          String integral = d[0];
          String answer = d[1];
          newFileData += "($idx)&\$$integral\$&\$$answer\$\\\\ \n";
          idx += 1;
        }
        newFileData += r"""\end{longtable}
""";
      }
      newFileData += r"""
                    \end{Large}
                    \end{document}
                    """;
      await file.writeAsString(newFileData);
    }
  }

  void generateIntegralDisplays() async {
    //
    // Generates the integral on one full page and the answer on the next page
    //
    String? newFile = await FilePicker.platform.saveFile(
        dialogTitle: "Save integral displays",
        fileName: "integral_displays.txt",
        allowedExtensions: [".txt"]);

    if (newFile != null) {
      var file = File(newFile);
      var integralData = await File("integrals.txt").readAsString();
      List<String> splitIntegrals = integralData.split("\n");
      splitIntegrals.removeLast();
      //
      // Partitions integrals by difficulty
      //
      Map<String, List<List<String>>> difficulties = {
        "Easy": [],
        "Medium": [],
        "Hard": [],
        "Final": []
      };

      for (String integralItem in splitIntegrals) {
        List<String> d = integralItem.trim().split(",");
        difficulties[d[2]]!.add(d);
      }
      String newFileData = r"""\documentclass[]{article}
                            \usepackage[landscape]{geometry}
                            \usepackage{amsmath}
                            %opening
                            \title{Integration Bee}
                            \author{}
                            \date{}
                            \begin{document}

                            \maketitle
                            \begin{Huge}
                            \newpage
                            """;
      for (String difficulty in difficulties.keys) {
        newFileData += "\\section*{$difficulty}\n \\newpage";
        for (List<String> i in difficulties[difficulty]!) {
          String integral = i[0];
          String answer = i[1];
          newFileData +=
              "\\vspace*{\\fill}\\begin{gather*}$integral\\end{gather*} \n";
          newFileData += "\\vspace*{\\fill}\\newpage \n";
          newFileData +=
              "\\vspace*{\\fill}\\begin{gather*}$answer\\end{gather*} \n";
          newFileData += "\\vspace*{\\fill}\\newpage \n";
        }
      }
      newFileData += r"""\end{Huge}
                    \end{document}
                    """;
      await file.writeAsString(newFileData);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const StageTitle2(text: "Add integrals"),
        const SizedBox(height: 20),
        SizedBox(
          height: MediaQuery.of(context).size.height / 2.5,
          child: Padding(
              padding: const EdgeInsets.only(left: 30, right: 30),
              child: Row(children: [
                Expanded(
                    flex: 1,
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Flexible(
                              child: Text(
                                  textAlign: TextAlign.center,
                                  "The current integral file will be overwritten with the uploaded file",
                                  style: TextStyle(
                                      color: Colors.black, fontSize: 30))),
                          Flexible(
                              child: InkWell(
                                  onTap: () {
                                    launchUrlString(
                                        'https://alunity.github.io/integral-entry/');
                                  },
                                  child: const Text(
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color: Colors.indigo,
                                          fontSize: 30,
                                          decoration: TextDecoration.underline),
                                      'Generate a CSV file using the online Integral Entry app'))),
                        ])),
                Expanded(
                    child: Column(children: [
                  (() {
                    if (newFileName != null) {
                      if (errors.isEmpty) {
                        return const Text("No errors to resolve",
                            style: TextStyle(
                                fontSize: 30,
                                color: Colors.green,
                                fontWeight: FontWeight.w700));
                      } else {
                        return Text("${errors.length} errors remaining",
                            style: const TextStyle(
                                fontSize: 30,
                                color: Colors.red,
                                fontWeight: FontWeight.w700));
                      }
                    } else {
                      return const Text(
                          "Any errors in the uploaded file will be shown here",
                          style: TextStyle(fontSize: 30, color: Colors.black));
                    }
                  }()),
                  const SizedBox(height: 10),
                  Expanded(
                      child: SingleChildScrollView(
                          controller: errorController,
                          child: Scrollbar(
                              thumbVisibility: true,
                              controller: errorController,
                              child: Column(
                                  children: (() {
                                return errors;
                              }()))))),
                  const SizedBox(height: 15),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Spacer(flex: 1),
                        Expanded(
                            flex: 3,
                            child: TextButton(
                                onPressed: uploadFile,
                                child: const Text("Upload file",
                                    style: TextStyle(fontSize: 20)))),
                        const Spacer(flex: 1),
                        Expanded(
                            flex: 3,
                            child: TextButton(
                                onPressed: saveNewFile,
                                child: const Text("Save",
                                    style: TextStyle(fontSize: 20)))),
                        const Spacer(flex: 1),
                        Expanded(
                            flex: 3,
                            child: Text(newFileName ?? "No file uploaded",
                                style: const TextStyle(fontSize: 20))),
                        const Spacer(flex: 1),
                        (() {
                          if (showSaved) {
                            return const Row(children: [
                              Icon(Icons.check, color: Colors.green, size: 30),
                              Text("Saved!",
                                  style: TextStyle(
                                      fontSize: 25,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.green))
                            ]);
                          } else {
                            return const SizedBox();
                          }
                        }()),
                        const Spacer(flex: 1)
                      ])
                ]))
              ])),
        ),
        const Spacer(),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          SizedBox(
              width: MediaQuery.of(context).size.width / 5,
              child: Tooltip(
                  message:
                      "Shows integral and answer for marking. LaTeX must be compiled separately.\nRequires geometry, amsmath, longtable, mathtools and amssymb packages.",
                  child: TextButton(
                      child: const Padding(
                          padding: EdgeInsets.only(top: 6, bottom: 6),
                          child: Text(("Generate integral/answer LaTeX"),
                              style: TextStyle(fontSize: 20))),
                      onPressed: () => {generateAnswerDoc()}))),
          const SizedBox(width: 40),
          SizedBox(
              width: MediaQuery.of(context).size.width / 5,
              child: Tooltip(
                  message:
                      "Shows integral on one page and answer on the next. LaTeX must be compiled separately.\nRequires amsmath and geometry packages",
                  child: TextButton(
                      child: const Padding(
                          padding: EdgeInsets.only(top: 6, bottom: 6),
                          child: Text("Generate integral displays LaTeX",
                              style: TextStyle(fontSize: 20))),
                      onPressed: () => {generateIntegralDisplays()})))
        ]),
        const SizedBox(height: 20),
        SizedBox(
            height: 40,
            width: 300,
            child: TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("Back", style: TextStyle(fontSize: 20)))),
        const SizedBox(height: 70)
      ],
    );
  }
}
