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
        child: Column(
          children: [
            const Text("Integral Bee 2024"),
            const Text("Beths Grammar School"),
            Row(children: [
              TextButton(
                  onPressed: () {
                    onPageSelect(const AddPlayer());
                  },
                  child: const Text("Add players")),
              TextButton(
                  onPressed: () {
                    onPageSelect(const Round());
                  },
                  child: const Text("Begin")),
            ]),
          ],
        ),
      ),
    );
  }
}
