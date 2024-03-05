import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:integral_bee_app/player.dart';

class SingleMatchDisplay extends StatelessWidget {
  final List<Player> players;
  final Function switchPlayers;
  final int idx;
  final AutoSizeGroup textSizing = AutoSizeGroup();

  SingleMatchDisplay(
      {super.key,
      required this.players,
      required this.switchPlayers,
      required this.idx});

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
        widthFactor: 0.6,
        child: Padding(
            padding: const EdgeInsets.only(top: 20, bottom: 20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                    onPressed: () {
                      switchPlayers(players, idx);
                    },
                    icon: const Icon(
                        IconData(0xf00e9, fontFamily: 'MaterialIcons'))),
                Expanded(
                    child: AutoSizeText(
                        textAlign: TextAlign.start,
                        maxLines: 1,
                        group: textSizing,
                        players[0].name,
                        style: const TextStyle(fontSize: 45))),
                Padding(
                    padding: const EdgeInsets.only(left: 30, right: 30),
                    child: AutoSizeText("vs.",
                        group: textSizing,
                        style: const TextStyle(fontSize: 45))),
                Expanded(
                    child: AutoSizeText(
                        textAlign: TextAlign.end,
                        group: textSizing,
                        players[1].name,
                        style: const TextStyle(fontSize: 45)))
              ],
            )));
  }
}
