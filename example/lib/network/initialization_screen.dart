import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:klarna_network_core/klarna_network_core.dart';

import 'integrations_screen.dart';

/// Entry screen: collects the merchant-supplied configuration and creates (or
/// clears) a Klarna Network instance. On initialize, it navigates to the
/// integrations screen with the live instance — mirroring the native SDK flow
/// where, once a Klarna instance exists, the app picks a feature to use it with.
class KlarnaNetworkInitializationScreen extends StatefulWidget {
  const KlarnaNetworkInitializationScreen({super.key});

  @override
  State<KlarnaNetworkInitializationScreen> createState() =>
      _KlarnaNetworkInitializationScreenState();
}

class _KlarnaNetworkInitializationScreenState
    extends State<KlarnaNetworkInitializationScreen> {
  final _clientId = TextEditingController();
  final _accountId = TextEditingController();
  final _locale = TextEditingController(text: 'en-US');
  final _sessionToken = TextEditingController();
  // Must use a URL scheme registered in the app (see ios/Runner/Info.plist
  // CFBundleURLSchemes), or the Klarna SDK rejects it as an invalid return URL.
  final _returnUrl =
      TextEditingController(text: 'klarna-mobile-sdk-flutter://example');

  Klarna? _network;

  @override
  void dispose() {
    _clientId.dispose();
    _accountId.dispose();
    _locale.dispose();
    _sessionToken.dispose();
    _returnUrl.dispose();
    super.dispose();
  }

  String? _trimToNull(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  Future<void> _initialize() async {
    final clientId = _clientId.text.trim();
    if (clientId.isEmpty) {
      _show('Error', 'Client ID can not be null or empty.');
      return;
    }

    try {
      final network = await Klarna.initialize(
        KlarnaConfiguration(
          clientId: clientId,
          appReturnUrl: _trimToNull(_returnUrl.text) ??
              'klarna-mobile-sdk-flutter://example',
          accountId: _trimToNull(_accountId.text),
          locale: _trimToNull(_locale.text),
          klarnaNetworkSessionToken: _trimToNull(_sessionToken.text),
        ),
      );
      setState(() => _network = network);
      if (!mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => KlarnaNetworkIntegrationsScreen(klarna: network),
        ),
      );
    } catch (error) {
      _show('Klarna SDK Error', 'Failed to initialize: $error');
    }
  }

  Future<void> _clearInstance() async {
    final network = _network;
    if (network == null) {
      _show('Error', 'No active Klarna instance to clear.');
      return;
    }
    try {
      await network.dispose();
      setState(() => _network = null);
      _show('Success', 'Klarna instance cleared.');
    } catch (error) {
      _show('Klarna SDK Error', 'Failed to clear instance: $error');
    }
  }

  void _show(String title, String message) {
    if (!mounted) return;
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Widget _field(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Klarna Network Initialization')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _field('Client ID', _clientId),
            _field('Account ID', _accountId),
            _field('Locale', _locale),
            _field('Klarna Network Session Token', _sessionToken),
            // App Return URL is only used on iOS; Android doesn't handle the
            // return URL via the core SDK, so hide the field there.
            if (!Platform.isAndroid) _field('App Return URL', _returnUrl),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _initialize,
              child: const Text('Initialize'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _clearInstance,
              child: const Text('Clear Klarna instance'),
            ),
          ],
        ),
      ),
    );
  }
}
