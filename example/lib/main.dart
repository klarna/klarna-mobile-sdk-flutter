import 'package:flutter/material.dart';
import 'package:klarna_mobile_sdk_flutter_example/home_screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // hide the debug banner
      debugShowCheckedModeBanner: false,
      title: "Flutter Klarna In-App SDK - Example",
      home: HomeScreen(),
    );
  }
}
