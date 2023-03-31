import 'package:flutter/material.dart';
import 'package:klarna_mobile_sdk_flutter_example/postpurchasesdk/post_purchase_sdk_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  Column menuColumn(BuildContext context) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextButton(
            child: const Text('KlarnaPostPurchaseSDK'),

            // Navigate to the Setting screen
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => PostPurchaseSDKScreen()));
            },
          )
        ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Home'),
        ),
        body: SingleChildScrollView(
            child: Stack(children: [
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
          Container(child: menuColumn(context))
        ])));
  }
}
