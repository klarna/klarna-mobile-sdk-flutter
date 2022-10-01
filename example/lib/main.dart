import 'package:flutter/material.dart';
import 'package:flutter_klarna_inapp_sdk_example/home_screen.dart';

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
