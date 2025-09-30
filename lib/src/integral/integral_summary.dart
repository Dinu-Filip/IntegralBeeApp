import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:integral_bee_app/src/player.dart';
import 'package:integral_bee_app/src/integral/integral.dart';
import 'package:integral_bee_app/src/standard_widgets.dart';

class IntegralSummary extends StatefulWidget {
  final Map<List<Player>, Integral?> integralData;
  final Function updateMatch;

  const IntegralSummary(
      {super.key, required this.integralData, required this.updateMatch});

  @override
  State<IntegralSummary> createState() => IntegralSummaryState();
}

class IntegralSummaryState extends State<IntegralSummary> {
  Map<List<Player>, Player?> rawResults = {};
  TextStyle nameStyle = const TextStyle(fontSize: 25);
  bool initialised = false;
  List<ScrollController> scrollers = [];

  List<Widget> generatePlayerSummary() {
    List<List<Player>> pairs = widget.integralData.keys.toList();
    List<Widget> integralSummaries = [
      const Row(children: [
        Expanded(
            child: Text("Answers",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 35, fontWeight: FontWeight.w500))),
        Expanded(
            child: Text("Select student",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 35, fontWeight: FontWeight.w500)))
      ]),
      const SizedBox(height: 35)
    ];
    for (int i = 0; i < pairs.length; i++) {
      List<Player> currentPair = pairs[i];
      Player player1 = currentPair[0];
      Player player2 = currentPair[1];

      String answer = widget.integralData[currentPair]!.answer;
      scrollers.add(ScrollController());
      integralSummaries.add(Padding(
          padding: const EdgeInsets.only(top: 20, bottom: 20),
          child: Row(children: [
            Expanded(
                flex: 3,
                child: Scrollbar(
                    controller: scrollers.last,
                    child: SingleChildScrollView(
                        controller: scrollers.last,
                        scrollDirection: Axis.horizontal,
                        child: Math.tex(answer,
                            textStyle: const TextStyle(fontSize: 45))))),
            Expanded(
                flex: 1,
                child: ListTile(
                    title: Text(player1.name, style: nameStyle),
                    leading: Radio<Player?>(
                        value: player1,
                        groupValue: rawResults[currentPair],
                        onChanged: (Player? value) {
                          setState(() {
                            rawResults[currentPair] = value;
                          });
                        }))),
            Expanded(
                flex: 1,
                child: ListTile(
                    title: Text(player2.name, style: nameStyle),
                    leading: Radio<Player?>(
                        value: player2,
                        groupValue: rawResults[currentPair],
                        onChanged: (Player? value) {
                          setState(() {
                            rawResults[currentPair] = value;
                          });
                        }))),
            Expanded(
                flex: 1,
                child: ListTile(
                    title: Text("None", style: nameStyle),
                    leading: Radio<Player?>(
                        value: null,
                        groupValue: rawResults[currentPair],
                        onChanged: (Player? value) {
                          setState(() {
                            rawResults[currentPair] = value;
                          });
                        })))
          ])));
    }
    return integralSummaries;
  }

  @override
  Widget build(BuildContext context) {
    if (!initialised) {
      for (List<Player> pair in widget.integralData.keys.toList()) {
        rawResults[pair] = null;
      }
      initialised = true;
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
      const StageTitle2(text: "Answers and results"),
      Expanded(
          child: FractionallySizedBox(
              widthFactor: 0.80,
              child: ListView(children: generatePlayerSummary()))),
      Padding(
          padding: const EdgeInsets.only(bottom: 50),
          child: SizedBox(
              height: 60,
              width: 400,
              child: TextButton(
                  onPressed: () {
                    widget.updateMatch(rawResults);
                  },
                  child: const Text("Next", style: TextStyle(fontSize: 30)))))
    ]);
  }
}
