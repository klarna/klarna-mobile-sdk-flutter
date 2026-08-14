import 'package:flutter/material.dart';
import 'package:klarna_network_core/klarna_network_core.dart';

/// Shown once a Klarna Network instance has been created. It confirms the live
/// instance and lists the Klarna Network features that can use it.
///
/// Today only the core's own session feature is available. The feature modules
/// (Payment, Messaging) are listed as not-yet-available placeholders so the
/// structure matches the native SDK's integration menu.
class KlarnaNetworkIntegrationsScreen extends StatelessWidget {
  const KlarnaNetworkIntegrationsScreen({super.key, required this.klarna});

  final Klarna klarna;

  Future<void> _getSessionToken(BuildContext context) async {
    // Capture the messenger before the await so we don't use `context` across
    // the async gap.
    final messenger = ScaffoldMessenger.of(context);
    try {
      final token = await klarna.network.session.token();
      messenger.showSnackBar(SnackBar(content: Text('Session token: $token')));
    } catch (error) {
      messenger.showSnackBar(
        SnackBar(content: Text('Failed to fetch session token: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Klarna Network Integrations')),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Klarna instance created.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          const Divider(height: 1),
          ListTile(
            title: const Text('Klarna Session'),
            subtitle: const Text('Fetch a session token from this instance.'),
            onTap: () => _getSessionToken(context),
          ),
          const ListTile(
            title: Text('Klarna Network Payment'),
            subtitle: Text('Not yet available in this SDK.'),
            enabled: false,
          ),
        ],
      ),
    );
  }
}
