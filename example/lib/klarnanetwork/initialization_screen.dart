import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:klarna_network_core/klarna_network_core.dart';

import 'integrations_screen.dart';

/// Collects config, creates a Klarna Network instance, then opens integrations.
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
  final _returnUrl = TextEditingController(
    text: 'klarna-mobile-sdk-flutter://example',
  );

  Klarna? _klarna;
  bool _initializing = false;
  bool _clearing = false;

  @override
  void dispose() {
    final network = _klarna;
    _klarna = null;
    if (network != null) {
      unawaited(_disposeInBackground(network));
    }
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
    if (_klarna != null) {
      _show('Error', 'Clear the active Klarna instance before initializing.');
      return;
    }
    if (_initializing || _clearing) return;

    final clientId = _clientId.text.trim();
    if (clientId.isEmpty) {
      _show('Error', 'Client ID can not be null or empty.');
      return;
    }

    setState(() => _initializing = true);
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
      if (!mounted) {
        try {
          await _disposeOwnedNetwork(network);
        } catch (error, stackTrace) {
          debugPrint('Klarna instance cleanup after unmount failed: $error');
          debugPrintStack(stackTrace: stackTrace);
        }
        return;
      }
      setState(() => _klarna = network);
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => KlarnaNetworkIntegrationsScreen(klarna: network),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      _show('Klarna SDK Error', 'Failed to initialize: $error');
    } finally {
      if (mounted) setState(() => _initializing = false);
    }
  }

  Future<void> _clearInstance() async {
    if (_clearing || _initializing) return;
    final network = _klarna;
    if (network == null) {
      _show('Error', 'No active Klarna instance to clear.');
      return;
    }
    setState(() {
      _clearing = true;
      _klarna = null;
    });
    try {
      await _disposeOwnedNetwork(network);
      if (!mounted) return;
      setState(() => _clearing = false);
      _show('Success', 'Klarna instance cleared.');
    } catch (error, stackTrace) {
      debugPrint('Klarna instance clear failed: $error');
      debugPrintStack(stackTrace: stackTrace);
      if (!mounted) return;
      setState(() {
        _klarna = network;
        _clearing = false;
      });
      _show('Klarna SDK Error', 'Failed to clear instance: $error');
    }
  }

  Future<void> _disposeInBackground(Klarna network) async {
    try {
      await _disposeOwnedNetwork(network);
    } catch (error, stackTrace) {
      debugPrint(
          'Klarna instance cleanup after screen disposal failed: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  Future<void> _disposeOwnedNetwork(Klarna network) => network.dispose();

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
            // App Return URL is iOS-only; Android doesn't handle it via the core SDK.
            if (!Platform.isAndroid) _field('App Return URL', _returnUrl),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _initializing || _clearing || _klarna != null
                  ? null
                  : _initialize,
              child: Text(_initializing ? 'Initializing…' : 'Initialize'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _klarna == null || _initializing || _clearing
                  ? null
                  : _clearInstance,
              child: Text(_clearing ? 'Clearing…' : 'Clear Klarna instance'),
            ),
          ],
        ),
      ),
    );
  }
}
