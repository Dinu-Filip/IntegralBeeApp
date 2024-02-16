import 'package:flutter/material.dart';
import 'package:integral_bee_app/round.dart';
import 'package:integral_bee_app/single_match_display.dart';

class MatchPreview extends StatefulWidget {
  final String round;
  //
  // matchData stores all possible matches that can take place
  //
  final List<dynamic> matchData;
  final Function startMatch;

  const MatchPreview(
      {super.key,
      required this.round,
      required this.matchData,
      required this.startMatch});

  @override
  State<MatchPreview> createState() => MatchPreviewState();
}

class MatchPreviewState extends State<MatchPreview> {
  //
  // maxMatches limits the number of matches that can take place at one time
  //
  static const int maxMatches = 4;
  int numPairs = 1;
  //
  // Stores display components that show one pairing each
  //
  List<SingleMatchDisplay> matchDisplays = [];
  //
  // Stores matches that will take place
  //
  List<List<Player>> displayedMatches = [];
  bool enableSwitching = true;

  void switchPlayers(List<Player> players, int idx) {
    //
    // Finds next match not being displayed
    //
    int currentMatchIdx = widget.matchData.indexOf(displayedMatches[idx]);
    while (displayedMatches.contains(widget.matchData[currentMatchIdx])) {
      currentMatchIdx += 1;
      if (currentMatchIdx == widget.matchData.length) {
        currentMatchIdx = 0;
      }
    }
    displayedMatches[idx] = widget.matchData[currentMatchIdx];
    //
    // Updates corresponding match display
    //
    setState(() {
      matchDisplays[idx] = SingleMatchDisplay(
          players: widget.matchData[currentMatchIdx],
          switchPlayers: switchPlayers,
          idx: idx);
    });
  }

  void createMatchDisplays() {
    //
    // Ensures number of displays is less than or equal to number of remaining matches
    //
    int numDisplays = numPairs <= widget.matchData.length
        ? numPairs
        : widget.matchData.length;
    //
    // Adds a display for each match happening at the same time
    //
    for (int i = 0; i < numDisplays; i++) {
      matchDisplays.add(SingleMatchDisplay(
          players: widget.matchData[i], switchPlayers: switchPlayers, idx: i));
      //
      // Appends index of match being displayed in component
      //
      displayedMatches.add(widget.matchData[i]);
    }
  }

  void addDisplay() {
    if (numPairs < maxMatches && numPairs < widget.matchData.length) {
      int idx = 0;
      //
      // Finds next match from beginning of round data that is not currently displayed
      //
      while (displayedMatches.contains(widget.matchData[idx])) {
        idx += 1;
      }
      numPairs += 1;
      displayedMatches.add(widget.matchData[idx]);
      setState(() {
        matchDisplays.add(SingleMatchDisplay(
            players: widget.matchData[idx],
            switchPlayers: switchPlayers,
            idx: matchDisplays.length));
      });
    }
  }

  void removeDisplay() {
    //
    // Removes the last pairing from the match
    //
    if (displayedMatches.length > 1) {
      numPairs -= 1;
      displayedMatches.removeLast();
      setState(() {
        matchDisplays.removeLast();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (numPairs == widget.matchData.length) {
      enableSwitching = false;
    }

    if (matchDisplays.isEmpty) {
      createMatchDisplays();
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
      const SizedBox(height: 40),
      Padding(
          padding: const EdgeInsets.all(15),
          child: Text("${widget.round} match",
              style:
                  const TextStyle(fontSize: 42, fontWeight: FontWeight.bold))),
      const SizedBox(height: 50),
      Expanded(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: matchDisplays)),
      const SizedBox(height: 50),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        (() {
          return SizedBox(
              width: MediaQuery.of(context).size.width / 6,
              height: 50,
              child: TextButton(
                  onPressed: addDisplay,
                  child:
                      const Text("Add pair", style: TextStyle(fontSize: 25))));
        }()),
        const SizedBox(width: 30),
        (() {
          return SizedBox(
              width: MediaQuery.of(context).size.width / 6,
              height: 50,
              child: TextButton(
                  onPressed: removeDisplay,
                  child: const Text("Remove pair",
                      style: TextStyle(fontSize: 25))));
        }())
      ]),
      const SizedBox(height: 40),
      SizedBox(
          width: MediaQuery.of(context).size.width / 5,
          height: 70,
          child: OutlinedButton(
              onPressed: () => {widget.startMatch(displayedMatches)},
              child:
                  const Text("Start match", style: TextStyle(fontSize: 30)))),
      const SizedBox(height: 100),
    ]);
  }
}
