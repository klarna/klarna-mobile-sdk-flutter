import 'package:flutter/material.dart';
import 'package:flutter_klarna_inapp_sdk/klarna_hybrid_sdk.dart';
import 'package:flutter_klarna_inapp_sdk/klarna_post_purchase_experience.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final localeController = TextEditingController(text: "sv-SE");
  final countryController = TextEditingController(text: "SE");

  final clientIdController = TextEditingController(text: "");
  final scopeController = TextEditingController(text: "read:consumer_order");
  final redirectUriController = TextEditingController(text: "");

  final operationTokenController = TextEditingController(text: "");

  KlarnaPostPurchaseExperience ppe;

  @override
  void initState() {
    super.initState();
    initHybridSDK();
  }

  void initHybridSDK() async {
    await KlarnaHybridSDK.initialize("https://www.klarna.com");
  }

  void ppeInitialize() async {
    ppe = await KlarnaPostPurchaseExperience.initialize(
        localeController.text, countryController.text,
        design: null);
  }

  void ppeAuthorizationRequest() async {
    await ppe?.authorizationRequest(
        clientIdController.text,
        scopeController.text,
        redirectUriController.text);
  }

  void ppeRenderOperation() async {
    await ppe?.renderOperation(operationTokenController.text);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          appBar: AppBar(
            title: const Text('Flutter Klarna In-App SDK Example'),
          ),
          body: SingleChildScrollView(
            child: Stack(
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
                  child: Column(children: [
                    Container(
                      child: Column(
                        children: <Widget>[
                          Text(
                            "PostPurchaseExperience.initialize",
                            style: Theme.of(context).textTheme.subtitle,
                          ),
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
                            color: Theme.of(context).accentColor,
                            child: new Text("Initialize"),
                            onPressed: ppeInitialize,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      child: Column(
                        children: <Widget>[
                          Text(
                            "PostPurchaseExperience.authorizationRequest",
                            style: Theme.of(context).textTheme.subtitle,
                          ),
                          TextFormField(
                            controller: clientIdController,
                            decoration: InputDecoration(
                                border: InputBorder.none,
                                labelText: "Client ID"),
                          ),
                          TextFormField(
                            controller: scopeController,
                            decoration: InputDecoration(
                                border: InputBorder.none, labelText: 'Scope'),
                          ),
                          TextFormField(
                            controller: redirectUriController,
                            decoration: InputDecoration(
                                border: InputBorder.none,
                                labelText: 'Redirect URI'),
                          ),
                          MaterialButton(
                            color: Theme.of(context).accentColor,
                            child: new Text("Authorization Request"),
                            onPressed: ppeAuthorizationRequest,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      child: Column(
                        children: <Widget>[
                          Text(
                            "PostPurchaseExperience.renderOperation",
                            style: Theme.of(context).textTheme.subtitle,
                          ),
                          TextFormField(
                            controller: operationTokenController,
                            decoration: InputDecoration(
                                border: InputBorder.none,
                                labelText: "Operation Token"),
                          ),
                          MaterialButton(
                            color: Theme.of(context).accentColor,
                            child: new Text("Render Operation"),
                            onPressed: ppeRenderOperation,
                          ),
                        ],
                      ),
                    )
                  ]),
                )
              ],
            ),
          )),
    );
  }
}
