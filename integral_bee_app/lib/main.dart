import 'package:flutter/material.dart';

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

  void addPlayers() {

  }

  void begin() {

  }

  void addIntegrals() {
    
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text("Integral Bee 2024"),
            Text("Beths Grammar School"),
            Column(children: [
              TextButton(onPressed: onPressed, child: Text("Add players")),
              TextButton(onPressed: onPressed, child: Text("Begin")),
              TextButton(onPressed: onPressed, child: Text("Add integrals"))
            ]),
          ],
        ),
      ),
    );
  }
}
