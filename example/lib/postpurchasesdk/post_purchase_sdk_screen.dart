import 'package:flutter/material.dart';
import 'package:flutter_klarna_inapp_sdk/klarna_environment.dart';
import 'package:flutter_klarna_inapp_sdk/klarna_post_purchase_sdk.dart';
import 'package:flutter_klarna_inapp_sdk/klarna_region.dart';
import 'package:flutter_klarna_inapp_sdk/klarna_resource_endpoint.dart';
import 'package:flutter_klarna_inapp_sdk/klarna_result.dart';

class PostPurchaseSDKScreen extends StatefulWidget {
  @override
  _PostPurchaseSDKScreenState createState() => _PostPurchaseSDKScreenState();
}

class _PostPurchaseSDKScreenState extends State<PostPurchaseSDKScreen> {
  // create
  KlarnaEnvironment? klarnaEnvironment;
  KlarnaRegion? klarnaRegion;
  KlarnaResourceEndpoint? klarnaResourceEndpoint;

  // initialize
  final initializeLocaleController = TextEditingController(text: "en-SE");
  final initializePurchaseCountryController = TextEditingController(text: "SE");
  final initializeDesignController = TextEditingController(text: null);

  // authorizationRequest
  final authorizationRequestClientIdController =
      TextEditingController(text: "");
  final authorizationRequestScopeController =
      TextEditingController(text: "read:consumer_order");
  final authorizationRequestRedirectUriController =
      TextEditingController(text: "");
  final authorizationRequestLocaleController =
      TextEditingController(text: null);
  final authorizationRequestStateController = TextEditingController(text: null);
  final authorizationRequestLoginHintController =
      TextEditingController(text: null);
  final authorizationRequestResponseTypeController =
      TextEditingController(text: null);

  // renderOperation
  final renderOperationOperationTokenController =
      TextEditingController(text: "");
  final renderOperationLocaleController = TextEditingController(text: null);
  final renderOperationRedirectUriController =
      TextEditingController(text: null);

  KlarnaPostPurchaseSDK? postPurchaseSDK;

  void _sdkCreate(BuildContext context) async {
    postPurchaseSDK = await KlarnaPostPurchaseSDK.createInstance(
        klarnaEnvironment, klarnaRegion, klarnaResourceEndpoint);
    KlarnaPostPurchaseSDK.registerEventListenerString((p0) =>
        _showToast(context, p0)
    );
    _showToast(context, postPurchaseSDK.toString());
  }

  void _sdkInitialize(BuildContext context) async {
    final KlarnaResult? result = await postPurchaseSDK?.initialize(
        initializeLocaleController.text,
        initializePurchaseCountryController.text,
        design: (initializeDesignController.text.isEmpty ? null : initializeDesignController.text));
    _showToast(context, result.toString());
  }

  void _sdkAuthorizationRequest(BuildContext context) async {
    final KlarnaResult? result = await postPurchaseSDK?.authorizationRequest(
        authorizationRequestClientIdController.text,
        authorizationRequestScopeController.text,
        authorizationRequestRedirectUriController.text,
        locale: (authorizationRequestLocaleController.text.isEmpty ? null : authorizationRequestLocaleController.text),
        state: (authorizationRequestStateController.text.isEmpty ? null : authorizationRequestStateController.text),
        loginHint: (authorizationRequestLoginHintController.text.isEmpty ? null : authorizationRequestLoginHintController.text),
        responseType: (authorizationRequestResponseTypeController.text.isEmpty ? null : authorizationRequestResponseTypeController.text));
    _showToast(context, result.toString());
  }

  void _sdkRenderOperation(BuildContext context) async {
    final KlarnaResult? result = await postPurchaseSDK?.renderOperation(
        renderOperationOperationTokenController.text,
        locale: (renderOperationLocaleController.text.isEmpty ? null : renderOperationLocaleController.text),
        redirectUri: (renderOperationRedirectUriController.text.isEmpty ? null : renderOperationRedirectUriController.text));
    _showToast(context, result.toString());
  }

  void _sdkDestroy(BuildContext context) async {
    await postPurchaseSDK?.destroy();
    _showToast(context, "KlarnaPostPurchaseSDK destroyed.");
  }

  void _showToast(BuildContext context, String text) {
    final scaffold = ScaffoldMessenger.of(context);
    scaffold.showSnackBar(
      SnackBar(
        content: Text(text),
        action: SnackBarAction(
            label: 'CLOSE', onPressed: scaffold.hideCurrentSnackBar),
      ),
    );
  }

  Container _createContainer(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          Text(
            "KlarnaPostPurchaseSDK.createInstance",
            style: Theme.of(context).textTheme.subtitle1,
          ),
          DropdownButton<KlarnaEnvironment>(
            value: klarnaEnvironment,
            icon: Icon(Icons.arrow_drop_down),
            hint: Text("Klarna Environment"),
            iconSize: 24,
            elevation: 16,
            onChanged: (KlarnaEnvironment? newValue) {
              setState(() {
                klarnaEnvironment = newValue;
              });
            },
            items: KlarnaEnvironment.values
                .map<DropdownMenuItem<KlarnaEnvironment>>(
                    (KlarnaEnvironment value) {
              return DropdownMenuItem<KlarnaEnvironment>(
                value: value,
                child: Text(value.toString()),
              );
            }).toList(),
          ),
          DropdownButton<KlarnaRegion>(
            value: klarnaRegion,
            icon: Icon(Icons.arrow_drop_down),
            hint: Text("Klarna Region"),
            iconSize: 24,
            elevation: 16,
            onChanged: (KlarnaRegion? newValue) {
              setState(() {
                klarnaRegion = newValue;
              });
            },
            items: KlarnaRegion.values
                .map<DropdownMenuItem<KlarnaRegion>>((KlarnaRegion value) {
              return DropdownMenuItem<KlarnaRegion>(
                value: value,
                child: Text(value.toString()),
              );
            }).toList(),
          ),
          DropdownButton<KlarnaResourceEndpoint>(
            value: klarnaResourceEndpoint,
            icon: Icon(Icons.arrow_drop_down),
            hint: Text("Klarna Resource Endpoint"),
            iconSize: 24,
            elevation: 16,
            onChanged: (KlarnaResourceEndpoint? newValue) {
              setState(() {
                klarnaResourceEndpoint = newValue;
              });
            },
            items: KlarnaResourceEndpoint.values
                .map<DropdownMenuItem<KlarnaResourceEndpoint>>(
                    (KlarnaResourceEndpoint value) {
              return DropdownMenuItem<KlarnaResourceEndpoint>(
                value: value,
                child: Text(value.toString()),
              );
            }).toList(),
          ),
          MaterialButton(
            color: Theme.of(context).colorScheme.secondary,
            child: new Text("Create"),
            onPressed: () => _sdkCreate(context),
          ),
        ],
      ),
    );
  }

  Container _initializeContainer(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          Text(
            "KlarnaPostPurchaseSDK.initialize",
            style: Theme.of(context).textTheme.subtitle1,
          ),
          TextFormField(
            controller: initializeLocaleController,
            decoration:
                InputDecoration(border: InputBorder.none, labelText: "Locale"),
          ),
          TextFormField(
            controller: initializePurchaseCountryController,
            decoration:
                InputDecoration(border: InputBorder.none, labelText: 'Country'),
          ),
          TextFormField(
            controller: initializeDesignController,
            decoration:
                InputDecoration(border: InputBorder.none, labelText: 'Design'),
          ),
          MaterialButton(
            color: Theme.of(context).colorScheme.secondary,
            child: new Text("Initialize"),
            onPressed: () => _sdkInitialize(context),
          ),
        ],
      ),
    );
  }

  Container _authorizationRequest(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          Text(
            "KlarnaPostPurchaseSDK.authorizationRequest",
            style: Theme.of(context).textTheme.subtitle1,
          ),
          TextFormField(
            controller: authorizationRequestClientIdController,
            decoration: InputDecoration(
                border: InputBorder.none, labelText: "Client ID"),
          ),
          TextFormField(
            controller: authorizationRequestScopeController,
            decoration:
                InputDecoration(border: InputBorder.none, labelText: 'Scope'),
          ),
          TextFormField(
            controller: authorizationRequestRedirectUriController,
            decoration: InputDecoration(
                border: InputBorder.none, labelText: 'Redirect URI'),
          ),
          TextFormField(
            controller: authorizationRequestLocaleController,
            decoration:
                InputDecoration(border: InputBorder.none, labelText: 'Locale'),
          ),
          TextFormField(
            controller: authorizationRequestStateController,
            decoration:
                InputDecoration(border: InputBorder.none, labelText: 'State'),
          ),
          TextFormField(
            controller: authorizationRequestLoginHintController,
            decoration: InputDecoration(
                border: InputBorder.none, labelText: 'Login Hint'),
          ),
          TextFormField(
            controller: authorizationRequestResponseTypeController,
            decoration: InputDecoration(
                border: InputBorder.none, labelText: 'Response Type'),
          ),
          MaterialButton(
            color: Theme.of(context).colorScheme.secondary,
            child: new Text("Authorization Request"),
            onPressed: () => _sdkAuthorizationRequest(context),
          ),
        ],
      ),
    );
  }

  Container _renderOperationContainer(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          Text(
            "KlarnaPostPurchaseSDK.renderOperation",
            style: Theme.of(context).textTheme.subtitle1,
          ),
          TextFormField(
            controller: renderOperationOperationTokenController,
            decoration: InputDecoration(
                border: InputBorder.none, labelText: "Operation Token"),
          ),
          TextFormField(
            controller: renderOperationLocaleController,
            decoration:
                InputDecoration(border: InputBorder.none, labelText: "Locale"),
          ),
          TextFormField(
            controller: renderOperationRedirectUriController,
            decoration: InputDecoration(
                border: InputBorder.none, labelText: "Redirect URI"),
          ),
          MaterialButton(
            color: Theme.of(context).colorScheme.secondary,
            child: new Text("Render Operation"),
            onPressed: () => _sdkRenderOperation(context),
          ),
        ],
      ),
    );
  }

  Container _destroyContainer(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          Text(
            "KlarnaPostPurchaseSDK.destroy",
            style: Theme.of(context).textTheme.subtitle1,
          ),
          MaterialButton(
            color: Theme.of(context).colorScheme.secondary,
            child: new Text("Destroy"),
            onPressed: () => _sdkDestroy(context),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: AppBar(
          title: const Text('KlarnaPostPurchaseSDK'),
        ),
        body: new Builder(builder: (BuildContext context) {
          return new SingleChildScrollView(
            child: Stack(
              children: [
                Container(
                  child: Column(children: [
                    _createContainer(context),
                    _initializeContainer(context),
                    _authorizationRequest(context),
                    _renderOperationContainer(context),
                    _destroyContainer(context)
                  ]),
                )
              ],
            ),
          );
        }));
  }
}
