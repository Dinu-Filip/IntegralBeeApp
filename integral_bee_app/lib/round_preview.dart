import 'package:flutter/material.dart';

class RoundPreview extends StatefulWidget {
  final String round;
  final int numParticipants;
  final int numIntegrals;
  final double integralTime;
  final List<dynamic> roundData;
  final Function startRound;

  const RoundPreview(
      {super.key,
      required this.round,
      required this.numParticipants,
      required this.numIntegrals,
      required this.integralTime,
      required this.roundData,
      required this.startRound});

  @override
  State<RoundPreview> createState() => RoundPreviewState();
}

class RoundPreviewState extends State<RoundPreview> {
  static const List<String> schools = ["Beths Grammar School"];
  static const Map<String, String> schoolCode = {
    "Beths Grammar School": "Beths"
  };

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
            padding: const EdgeInsets.all(20),
            child: Text(widget.round,
                style: const TextStyle(
                    fontSize: 60, fontWeight: FontWeight.bold))),
        Text("Number of participants: ${widget.numParticipants}",
            style: const TextStyle(fontSize: 40)),
        const Padding(
            padding: EdgeInsets.all(15),
            child: FractionallySizedBox(
                widthFactor: 0.6, child: Divider(color: Colors.black))),
        Text("${widget.numIntegrals} integrals",
            style: const TextStyle(fontSize: 40)),
        Text("${widget.integralTime} minutes per integral",
            style: const TextStyle(fontSize: 40)),
        const Padding(
            padding: EdgeInsets.all(15),
            child: FractionallySizedBox(
                widthFactor: 0.6, child: Divider(color: Colors.black))),
        const Text("Draw",
            style: TextStyle(fontSize: 40, fontWeight: FontWeight.w600)),
        const SizedBox(height: 15),
        FractionallySizedBox(
            widthFactor: 0.6,
            child: SingleChildScrollView(
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: widget.roundData
                          .map((match) => () {
                                return Text(
                                    "${match[0].name} (${schoolCode[match[0].school]})",
                                    style: const TextStyle(fontSize: 30));
                              }())
                          .toList()),
                  (() {
                    List<Text> items = [];
                    for (int i = 0; i < widget.roundData.length; i++) {
                      items.add(
                          const Text("vs.", style: TextStyle(fontSize: 30)));
                    }
                    return Column(children: items);
                  }()),
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: widget.roundData
                          .map((match) => () {
                                return Text(
                                    "${match[1].name} (${schoolCode[match[1].school]})",
                                    style: const TextStyle(fontSize: 30));
                              }())
                          .toList())
                ]))),
        Padding(
            padding: const EdgeInsets.only(top: 40),
            child: FractionallySizedBox(
                widthFactor: 0.3,
                child: SizedBox(
                    height: 60,
                    child: OutlinedButton(
                        onPressed: () {
                          widget.startRound();
                        },
                        child: const Text("Start round",
                            style: TextStyle(fontSize: 25))))))
      ],
    );
  }
}
