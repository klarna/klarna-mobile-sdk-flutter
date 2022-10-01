import 'package:flutter/material.dart';
import 'package:flutter_klarna_inapp_sdk_example/postpurchaseexperience/post_purchase_experience_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Home'),
        ),
        body: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              child: const Text('PostPurchaseExperience'),

              // Navigate to the Setting screen
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => PostPurchaseExperienceScreen()));
              },
            )
          ],
        ));
  }
}
