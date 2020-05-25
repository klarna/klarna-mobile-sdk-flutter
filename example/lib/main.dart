import 'package:flutter/material.dart';
import 'package:flutter_klarna_inapp_sdk/klarna_hybrid_sdk.dart';
import 'package:flutter_klarna_inapp_sdk/klarna_post_purchase_experience.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';

  @override
  void initState() {
    super.initState();
    initHybridSDK();
    initWebView();
    initPostPurchaseExperience();
  }

  void initHybridSDK() async {
    await KlarnaHybridSDK.initialize("");
  }

  void initWebView() async {
    // TODO
  }

  void initPostPurchaseExperience() async {
    await KlarnaPostPurchaseExperience.initialize("sv-SE", "SE", design: null);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Text('Running on: $_platformVersion\n'),
        ),
      ),
    );
  }
}
