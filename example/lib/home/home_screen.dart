import 'package:flutter/material.dart';
import 'package:klarna_mobile_sdk_flutter_example/common/theme_controller.dart';
import 'package:klarna_mobile_sdk_flutter_example/klarnanetwork/initialization_screen.dart';
import 'package:klarna_mobile_sdk_flutter_example/postpurchasesdk/post_purchase_sdk_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  void _open(BuildContext context, Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: const [ThemeModeButton()],
      ),
      body: ListView(
        children: [
          _NavMenuItem(
            title: 'KlarnaPostPurchaseSDK',
            onTap: () => _open(context, PostPurchaseSDKScreen()),
          ),
          _NavMenuItem(
            title: 'Klarna Network Integrations',
            onTap: () =>
                _open(context, const KlarnaNetworkInitializationScreen()),
          ),
        ],
      ),
    );
  }
}

class _NavMenuItem extends StatelessWidget {
  const _NavMenuItem({required this.title, required this.onTap});

  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surface,
      child: InkWell(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          margin: const EdgeInsets.all(20),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 20),
          ),
        ),
      ),
    );
  }
}
