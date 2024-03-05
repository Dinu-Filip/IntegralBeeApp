import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:integral_bee_app/add_players.dart';
import 'package:integral_bee_app/round.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final currentWindow = null;
  static const double paddingVal = 20;

  void onPageSelect(page) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => Scaffold(body: Center(child: page))));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: FractionallySizedBox(
            widthFactor: 0.7,
            heightFactor: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Padding(
                    padding: EdgeInsets.only(top: 25),
                    child: Text("Integral Bee 2024",
                        style: TextStyle(
                            fontSize: 60, fontWeight: FontWeight.bold))),
                const Padding(
                    padding: EdgeInsets.only(top: 20, bottom: 20),
                    child: Text("Beths Grammar School",
                        style: TextStyle(fontSize: 40))),
                Expanded(
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                      Expanded(
                          flex: 1,
                          child: Column(children: [
                            Expanded(
                                child: SizedBox(
                                    width: MediaQuery.of(context).size.width,
                                    child: Padding(
                                        padding:
                                            const EdgeInsets.all(paddingVal),
                                        child: ConstrainedBox(
                                            constraints: BoxConstraints(
                                                maxWidth: MediaQuery.of(context)
                                                    .size
                                                    .width,
                                                minWidth: MediaQuery.of(context)
                                                    .size
                                                    .width),
                                            child: ElevatedButton.icon(
                                                icon: const Icon(
                                                    size: 35.0,
                                                    Icons.settings_outlined),
                                                style: ElevatedButton.styleFrom(
                                                    shape:
                                                        RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10))),
                                                onPressed: () {
                                                  print("ok");
                                                },
                                                label: const AutoSizeText(
                                                    "Settings",
                                                    maxLines: 1,
                                                    style: TextStyle(
                                                        fontSize: 35))))))),
                            Expanded(
                                child: SizedBox(
                                    width: MediaQuery.of(context).size.width,
                                    child: Padding(
                                        padding: const EdgeInsets.only(
                                            left: paddingVal,
                                            right: paddingVal,
                                            bottom: paddingVal),
                                        child: ConstrainedBox(
                                            constraints: BoxConstraints(
                                                maxWidth: MediaQuery.of(context)
                                                    .size
                                                    .width,
                                                minWidth: MediaQuery.of(context)
                                                    .size
                                                    .width),
                                            child: ElevatedButton.icon(
                                                icon: const Icon(Icons.history,
                                                    size: 35),
                                                style: ElevatedButton.styleFrom(
                                                    shape:
                                                        RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10))),
                                                onPressed: () {
                                                  print("good");
                                                },
                                                label: const AutoSizeText(
                                                    textAlign: TextAlign.center,
                                                    "Load from previous",
                                                    maxLines: 1,
                                                    style: TextStyle(
                                                        fontSize: 35))))))),
                          ])),
                      Expanded(
                          flex: 1,
                          child: SizedBox(
                              height: MediaQuery.of(context).size.height,
                              child: Padding(
                                  padding: const EdgeInsets.only(
                                      top: paddingVal, bottom: paddingVal),
                                  child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10))),
                                      onPressed: () {
                                        onPageSelect(const Round());
                                      },
                                      child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.play_circle,
                                                size: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.05),
                                            const SizedBox(height: 10),
                                            ConstrainedBox(
                                                constraints: BoxConstraints(
                                                  minWidth:
                                                      MediaQuery.of(context)
                                                          .size
                                                          .width,
                                                  maxWidth:
                                                      MediaQuery.of(context)
                                                          .size
                                                          .width,
                                                ),
                                                child: const AutoSizeText(
                                                    textAlign: TextAlign.center,
                                                    maxLines: 1,
                                                    "Start tournament",
                                                    style: TextStyle(
                                                        fontSize: 45)))
                                          ]))))),
                      Expanded(
                          flex: 1,
                          child: Column(children: [
                            Expanded(
                                child: SizedBox(
                                    width: MediaQuery.of(context).size.width,
                                    child: Padding(
                                        padding:
                                            const EdgeInsets.all(paddingVal),
                                        child: ConstrainedBox(
                                            constraints: BoxConstraints(
                                                maxWidth: MediaQuery.of(context)
                                                    .size
                                                    .width,
                                                minWidth: MediaQuery.of(context)
                                                    .size
                                                    .width),
                                            child: ElevatedButton.icon(
                                                icon: const Icon(
                                                    Icons.person_2_sharp,
                                                    size: 35.0),
                                                style: TextButton.styleFrom(
                                                    shape:
                                                        RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10))),
                                                onPressed: () {
                                                  onPageSelect(
                                                      const AddPlayer());
                                                },
                                                label: const AutoSizeText(
                                                    "Add players",
                                                    maxLines: 1,
                                                    style: TextStyle(
                                                        fontSize: 35))))))),
                            Expanded(
                                child: SizedBox(
                                    width: MediaQuery.of(context).size.width,
                                    child: Padding(
                                        padding: const EdgeInsets.only(
                                            left: paddingVal,
                                            right: paddingVal,
                                            bottom: paddingVal),
                                        child: ConstrainedBox(
                                            constraints: BoxConstraints(
                                                maxWidth: MediaQuery.of(context)
                                                    .size
                                                    .width,
                                                minWidth: MediaQuery.of(context)
                                                    .size
                                                    .width),
                                            child: ElevatedButton.icon(
                                                icon: const Icon(Icons.add,
                                                    size: 35.0),
                                                style: ElevatedButton.styleFrom(
                                                    shape:
                                                        RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10))),
                                                onPressed: () {
                                                  print("ok");
                                                },
                                                label: const AutoSizeText(
                                                    textAlign: TextAlign.center,
                                                    "Add integrals",
                                                    maxLines: 1,
                                                    style: TextStyle(
                                                        fontSize: 35)))))))
                          ])),
                    ])),
                const SizedBox(height: 25)
              ],
            )),
      ),
    );
  }
}
