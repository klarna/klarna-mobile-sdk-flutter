import 'package:flutter/material.dart';
import 'package:flutter_klarna_inapp_sdk_example/postpurchaseexperience/post_purchase_experience_screen.dart';
import 'package:flutter_klarna_inapp_sdk_example/postpurchasesdk/post_purchase_sdk_screen.dart';

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
          ),
          TextButton(
            child: const Text('KlarnaPostPurchaseExperience (deprecated)'),

            // Navigate to the Setting screen
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => PostPurchaseExperienceScreen()));
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
