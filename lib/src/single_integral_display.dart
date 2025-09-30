import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:integral_bee_app/integral.dart';

class SingleIntegralDisplay extends StatelessWidget {
  final Integral rawIntegral;
  static const integralTextStyle = TextStyle(fontSize: 75);
  final int flex;

  const SingleIntegralDisplay(
      {super.key, required this.rawIntegral, this.flex = 1});

  @override
  Widget build(BuildContext context) {
    return Flexible(
        flex: flex,
        child: FittedBox(
            fit: BoxFit.fitWidth,
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                  alignment: Alignment.center,
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                      border: Border.all(
                          color: const Color.fromARGB(255, 196, 196, 196),
                          width: 2.5),
                      borderRadius:
                          const BorderRadius.all(Radius.circular(20))),
                  child: Text(rawIntegral.idx.toString(),
                      style: const TextStyle(
                          color: Color.fromARGB(255, 196, 196, 196),
                          fontWeight: FontWeight.w700))),
              Math.tex(rawIntegral.integral,
                  mathStyle: MathStyle.display, textStyle: integralTextStyle)
            ])));
  }
}
