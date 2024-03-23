import 'package:flutter/material.dart';
import 'package:integral_bee_app/settings.dart';
import 'package:integral_bee_app/standard_widgets.dart';

class RoundPreview extends StatefulWidget {
  final String round;
  final int numParticipants;
  final int numIntegrals;
  final int integralTime;
  final List<dynamic> roundData;
  final Function startRound;
  final Function showDraw;

  const RoundPreview(
      {super.key,
      required this.round,
      required this.numParticipants,
      required this.numIntegrals,
      required this.integralTime,
      required this.roundData,
      required this.startRound,
      required this.showDraw});

  @override
  State<RoundPreview> createState() => RoundPreviewState();
}

class RoundPreviewState extends State<RoundPreview> {
  static const List<String> schools = ["Beths Grammar School"];
  Map<String, String> schoolCode = {};

  @override
  Widget build(BuildContext context) {
    for (String school in schoolNames) {
      String initials = "";
      for (String word in school.split(" ")) {
        initials += word[0].toUpperCase();
      }
      schoolCode[school] = initials;
    }

    return ListView(
      children: [
        StageTitle1(text: widget.round),
        StageHeader(text: "Number of participants: ${widget.numParticipants}"),
        const Padding(
            padding: EdgeInsets.all(15),
            child: FractionallySizedBox(
                widthFactor: 0.6, child: Divider(color: Colors.black))),
        StageHeader(text: "${widget.numIntegrals} integrals"),
        StageHeader(text: "${widget.integralTime / 60} minutes per integral"),
        const Padding(
            padding: EdgeInsets.all(15),
            child: FractionallySizedBox(
                widthFactor: 0.6, child: Divider(color: Colors.black))),
        const Text("Draw",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 40, fontWeight: FontWeight.w600)),
        const SizedBox(height: 15),
        FractionallySizedBox(
            widthFactor: 0.6,
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: widget.roundData
                          .map((match) => () {
                                return Text(
                                    "${match[0].name} (${schoolCode[match[0].school]})",
                                    style: const TextStyle(fontSize: 25));
                              }())
                          .toList()),
                  (() {
                    List<Text> items = [];
                    for (int i = 0; i < widget.roundData.length; i++) {
                      items.add(
                          const Text("vs.", style: TextStyle(fontSize: 25)));
                    }
                    return Column(children: items);
                  }()),
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: widget.roundData
                          .map((match) => () {
                                return Text(
                                    "${match[1].name} (${schoolCode[match[1].school]})",
                                    style: const TextStyle(fontSize: 25));
                              }())
                          .toList())
                ])),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Padding(
              padding: const EdgeInsets.only(top: 20),
              child: SizedBox(
                  height: 60,
                  width: 200,
                  child: OutlinedButton(
                      onPressed: () {
                        widget.startRound();
                      },
                      child: const Text("Start round",
                          style: TextStyle(fontSize: 25))))),
          const SizedBox(width: 100),
          Padding(
              padding: const EdgeInsets.only(top: 20),
              child: SizedBox(
                  width: 200,
                  height: 60,
                  child: OutlinedButton(
                      onPressed: () {
                        widget.showDraw();
                      },
                      child: const Text("Show draw",
                          style: TextStyle(fontSize: 25)))))
        ]),
        const SizedBox(height: 25)
      ],
    );
  }
}
