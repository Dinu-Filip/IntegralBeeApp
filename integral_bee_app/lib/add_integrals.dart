import 'package:flutter/material.dart';
import 'package:integral_bee_app/standard_widgets.dart';
import 'package:url_launcher/url_launcher_string.dart';

class AddIntegrals extends StatefulWidget {
  const AddIntegrals({super.key});

  @override
  State<AddIntegrals> createState() => AddIntegralsState();
}

class AddIntegralsState extends State<AddIntegrals> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const StageTitle1(text: "Add integrals"),
        SizedBox(
            height: MediaQuery.of(context).size.height / 2,
            child: Row(children: [
              Column(children: [
                Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                  const Text(
                      softWrap: true,
                      style: TextStyle(color: Colors.black),
                      "Generate a CSV file containing the integral data from "),
                  InkWell(
                      onTap: () {
                        launchUrlString(
                            'https://alunity.github.io/integral-entry/');
                      },
                      child: const Text(
                          softWrap: true,
                          style: TextStyle(
                              color: Colors.indigo,
                              decoration: TextDecoration.underline),
                          'https://alunity.github.io/integral-entry/'))
                ])
              ]),
            ]))
      ],
    );
  }
}
