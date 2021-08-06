import 'package:flutter/material.dart';
import 'package:flutter_klarna_inapp_sdk/klarna_payment_view.dart';
import 'package:flutter_klarna_inapp_sdk/klarna_payment_sdk_error.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
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
              return SingleChildScrollView(
                child: Container(
                  child: Column(
                    children: <Widget>[
                      PaymentOptionsList(),
                    ],
                  ),
                ),
              );
            }));
      }),
    );
  }
}

class PaymentOptionsList extends StatefulWidget {
  PaymentOptionsList({Key key}) : super(key: key);

  @override
  _PaymentOptionsListState createState() => _PaymentOptionsListState();
}

class _PaymentOptionsListState extends State<PaymentOptionsList> {
  final String clientToken =
      "eyJhbGciOiJSUzI1NiIsImtpZCI6IjgyMzA1ZWJjLWI4MTEtMzYzNy1hYTRjLTY2ZWNhMTg3NGYzZCJ9.eyJzZXNzaW9uX2lkIjoiNWJiNmI2MDgtNmY0MS0zYjliLTljYTMtYTI2NzJjM2VmYTZmIiwiYmFzZV91cmwiOiJodHRwczovL2pzLnBsYXlncm91bmQua2xhcm5hLmNvbS9ldS9rcCIsImRlc2lnbiI6ImtsYXJuYSIsImxhbmd1YWdlIjoiZW4iLCJwdXJjaGFzZV9jb3VudHJ5IjoiREUiLCJlbnZpcm9ubWVudCI6InBsYXlncm91bmQiLCJtZXJjaGFudF9uYW1lIjoiWW91ciBidXNpbmVzcyBuYW1lIiwic2Vzc2lvbl90eXBlIjoiUEFZTUVOVFMiLCJjbGllbnRfZXZlbnRfYmFzZV91cmwiOiJodHRwczovL2V1LnBsYXlncm91bmQua2xhcm5hZXZ0LmNvbSIsInNjaGVtZSI6dHJ1ZSwiZXhwZXJpbWVudHMiOlt7Im5hbWUiOiJpbi1hcHAtc2RrLWNhcmQtc2Nhbm5pbmciLCJ2YXJpYXRlIjoiY2FyZC1zY2FubmluZy1lbmFibGUiLCJwYXJhbWV0ZXJzIjp7InZhcmlhdGVfaWQiOiJjYXJkLXNjYW5uaW5nLWVuYWJsZSJ9fV0sInJlZ2lvbiI6ImV1IiwidWFfZW5hYmxlZF9hbmRfb25lX3BtIjpmYWxzZX0.hQzt9-hdxPm2gqFrjU8B7b-RJtAZgt3S7_RrZVgP9BLzDqyyi387MvqRMaGzXVdaOiqNXmRO1I1piougeDyD5TiuDNj2HHJdNXoa3g_wS8zFFmvpyWKaCxjixTGH16uhMigj4Oy_fUVw3wy9HoqooDl9kF2NFCkdQND6VW_ROk6_-bVAiAJ3--gIgHEL8gL6KrkNE7at_owD3iBQfnHz4WftKrmVP0QF0tId3vdua7_qXbFIIl99wOM8JO-Tz2V6q14FhimNEO_Nm7oNOwD7gNjTksAR1RrGu90z16zrbwZwPDzZCLCEmGKOvLAZHrLPgVR6aNE4_lAozTZhlkT9kw";

  List<ItemModel> itemData = <ItemModel>[
    ItemModel(headerItem: 'Pay Now'),
    ItemModel(headerItem: 'Pay Later'),
    ItemModel(headerItem: 'Slice It'),
  ];

  KlarnaPaymentController payNowController;
  KlarnaPaymentController payLaterController;
  KlarnaPaymentController sliceItController;

  int selectedIndex;

  @override
  Widget build(BuildContext context) {
    final paynow = KlarnaPaymentView.payNow(
      onCreated: (controller) async {
        this.payNowController = controller;
        await controller.initialize(
            clientToken: clientToken, returnUrl: "returnUrl://");
      },
      onAuthorized: onAuthorized,
      onErrorOccurred: onErrorOccured,
      onFinalized: onFinalized,
      onInitialized: onInitialized,
      onLoadPaymentReview: onLoadPaymentReview,
      onLoaded: onLoaded,
      onReauthorized: onReauthorized,
    );

    final paylater = KlarnaPaymentView.payLater(
      onCreated: (controller) async {
        this.payLaterController = controller;
        await controller.initialize(
            clientToken: clientToken, returnUrl: "returnUrl://");
      },
      onAuthorized: onAuthorized,
      onErrorOccurred: onErrorOccured,
      onFinalized: onFinalized,
      onInitialized: onInitialized,
      onLoadPaymentReview: onLoadPaymentReview,
      onLoaded: onLoaded,
      onReauthorized: onReauthorized,
    );

    final sliceit = KlarnaPaymentView.sliceIt(
      onCreated: (controller) async {
        this.sliceItController = controller;
        await controller.initialize(
            clientToken: clientToken, returnUrl: "returnUrl://");
      },
      onAuthorized: onAuthorized,
      onErrorOccurred: onErrorOccured,
      onFinalized: onFinalized,
      onInitialized: onInitialized,
      onLoadPaymentReview: onLoadPaymentReview,
      onLoaded: onLoaded,
      onReauthorized: onReauthorized,
    );

    final categories = [paynow, paylater, sliceit];

    return Column(
      children: <Widget>[
        Container(
          padding: EdgeInsets.all(10),
          child: ListView.builder(
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            itemCount: itemData.length,
            itemBuilder: (BuildContext context, int index) {
              return ExpansionPanelList.radio(
                animationDuration: Duration(milliseconds: 500),
                children: [
                  ExpansionPanelRadio(
                    value: index,
                    headerBuilder: (BuildContext context, bool isExpanded) {
                      return Container(
                        padding: EdgeInsets.all(10),
                        child: Text(
                          itemData[index].headerItem,
                          style: TextStyle(
                            fontSize: 18,
                          ),
                        ),
                      );
                    },
                    body: Container(
                      padding: EdgeInsets.all(10),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          categories[index],
                        ],
                      ),
                    ),
                    canTapOnHeader: true,
                  )
                ],
                expansionCallback: (int item, bool status) {
                  setState(() {
                    itemData[index].expanded = !itemData[index].expanded;
                    selectedIndex = index;
                  });
                  if (!status) {
                    final controllers = [
                      this.payNowController,
                      this.payLaterController,
                      this.sliceItController
                    ];
                    controllers[index].load();
                  }
                },
              );
            },
          ),
        ),
        Container(
          child: RaisedButton(
              color: Colors.orange,
              onPressed: () {
                final controllers = [
                  this.payNowController,
                  this.payLaterController,
                  this.sliceItController
                ];
                controllers[selectedIndex].authorize(autoFinalize: false);
              },
              child: Text(
                "Pay",
                style: TextStyle(color: Colors.white),
              )),
        ),
      ],
    );
  }

  void onAuthorized(KlarnaPaymentController controller, bool approved,
      String authToken, bool finalizeRequired) {
    print(
        "authorized approved: $approved, authToken: $authToken, finalizeRequired: $finalizeRequired");
  }

  void onErrorOccured(
      KlarnaPaymentController controller, KlarnaPaymentSDKError error) {
    print("error occured $error");
  }

  void onFinalized(
      KlarnaPaymentController controller, bool approved, String authToken) {
    print("finalized approved: $approved, authToken: $authToken");
  }

  void onInitialized(KlarnaPaymentController controller) {
    print("initialized");
  }

  void onLoadPaymentReview(KlarnaPaymentController controller, bool showForm) {
    print("payment review loaded showForm: $showForm");
  }

  void onLoaded(KlarnaPaymentController controller) {
    print("loaded");
  }

  void onReauthorized(
      KlarnaPaymentController controller, bool approved, String authToken) {
    print("reauthorized approved: $approved, authToken: $authToken");
  }
}

class ItemModel {
  bool expanded;
  String headerItem;

  ItemModel({this.expanded: false, this.headerItem});
}
