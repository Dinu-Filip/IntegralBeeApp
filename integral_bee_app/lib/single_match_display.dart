import 'package:flutter/material.dart';
import 'package:integral_bee_app/round.dart';

class SingleMatchDisplay extends StatelessWidget {
  final List<Player> players;
  final Function switchPlayers;
  final int idx;

  const SingleMatchDisplay(
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
                    child: Text(
                        textAlign: TextAlign.start,
                        players[0].name,
                        style: const TextStyle(fontSize: 45))),
                const Padding(
                    padding: EdgeInsets.only(left: 30, right: 30),
                    child: Text("vs.", style: TextStyle(fontSize: 45))),
                Expanded(
                    child: Text(
                        textAlign: TextAlign.end,
                        players[1].name,
                        style: const TextStyle(fontSize: 45)))
              ],
            )));
  }
}
