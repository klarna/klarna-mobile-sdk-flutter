import 'package:flutter/material.dart';
import 'package:flutter_klarna_inapp_sdk/klarna_hybrid_sdk.dart';
import 'package:flutter_klarna_inapp_sdk/klarna_post_purchase_experience.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final localeController = TextEditingController();
  final countryController = TextEditingController();

  @override
  void initState() {
    super.initState();
    initHybridSDK();

    localeController.text = "sv-SE";
    countryController.text = "SE";
  }

  void initHybridSDK() async {
    await KlarnaHybridSDK.initialize("");
  }

  void initPostPurchaseExperience() async {
    await KlarnaPostPurchaseExperience.initialize(
        localeController.text, countryController.text,
        design: null);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Flutter Klarna In-App SDK Example'),
        ),
        body: Stack(
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                ),
              ),
            ),
            Positioned.fill(
              child: Opacity(
                opacity: .25,
                child: FittedBox(
                  fit: BoxFit.cover,
                  child: FlutterLogo(),
                ),
              ),
            ),
            Container(
              child: Column(
                children: <Widget>[
                  TextFormField(
                    controller: localeController,
                    decoration: InputDecoration(
                        border: InputBorder.none, labelText: "Locale"),
                  ),
                  TextFormField(
                    controller: countryController,
                    decoration: InputDecoration(
                        border: InputBorder.none, labelText: 'Country'),
                  ),
                  MaterialButton(
                    color: Theme.of(context).primaryColor,
                    child: new Text("Initialize PostPurchaseExperience"),
                    onPressed: initPostPurchaseExperience,
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
