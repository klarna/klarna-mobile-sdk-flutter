import 'package:flutter/material.dart';
import 'package:flutter_klarna_inapp_sdk/klarna_callback.dart';
import 'package:flutter_klarna_inapp_sdk/klarna_hybrid_sdk.dart';
import 'package:flutter_klarna_inapp_sdk/klarna_post_purchase_experience.dart';
import 'package:flutter_klarna_inapp_sdk/klarna_result.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final localeController = TextEditingController(text: "en-SE");
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
    initEventAndErrorCallbacks();
  }

  void initHybridSDK() async {
    await KlarnaHybridSDK.initialize("https://www.klarna.com");
  }

  void initEventAndErrorCallbacks() async {
    KlarnaCallback.registerCallback((event) {
      _showToast(context, "event: $event");
    }, (error) {
      _showToast(context, "error: $error");
    });
  }

  void ppeInitialize(BuildContext context) async {
    this.ppe = new KlarnaPostPurchaseExperience();
    final KlarnaResult result = await ppe.initialize(
        localeController.text, countryController.text,
        design: null);
    _showToast(context, result.toString());
  }

  void ppeAuthorizationRequest(BuildContext context) async {
    final KlarnaResult result = await ppe?.authorizationRequest(
        clientIdController.text,
        scopeController.text,
        redirectUriController.text);
    _showToast(context, result.toString());
  }

  void ppeRenderOperation(BuildContext context) async {
    final KlarnaResult result =
        await ppe?.renderOperation(operationTokenController.text);
    _showToast(context, result.toString());
  }

  void destroy(BuildContext context) async {
    await ppe?.destroy();
    _showToast(context, "Destroyed.");
  }

  void _showToast(BuildContext context, String text) {
    final scaffold = Scaffold.of(context);
    scaffold.showSnackBar(
      SnackBar(
        content: Text(text),
        action: SnackBarAction(
            label: 'CLOSE', onPressed: scaffold.hideCurrentSnackBar),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: new Builder(builder: (BuildContext context) {
        return new Scaffold(
            appBar: AppBar(
              title: const Text('Flutter Klarna In-App SDK Example'),
            ),
            body: new Builder(builder: (BuildContext context) {
              return new SingleChildScrollView(
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
                                    border: InputBorder.none,
                                    labelText: "Locale"),
                              ),
                              TextFormField(
                                controller: countryController,
                                decoration: InputDecoration(
                                    border: InputBorder.none,
                                    labelText: 'Country'),
                              ),
                              MaterialButton(
                                color: Theme.of(context).accentColor,
                                child: new Text("Initialize"),
                                onPressed: () => ppeInitialize(context),
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
                                    border: InputBorder.none,
                                    labelText: 'Scope'),
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
                                onPressed: () =>
                                    ppeAuthorizationRequest(context),
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
                                onPressed: () => ppeRenderOperation(context),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          child: Column(
                            children: <Widget>[
                              Text(
                                "PostPurchaseExperience.destroy",
                                style: Theme.of(context).textTheme.subtitle,
                              ),
                              MaterialButton(
                                color: Theme.of(context).accentColor,
                                child: new Text("Destroy"),
                                onPressed: () => destroy(context),
                              ),
                            ],
                          ),
                        )
                      ]),
                    )
                  ],
                ),
              );
            }));
      }),
    );
  }
}
