import 'package:flutter/material.dart';
import 'package:klarna_network_core/klarna_network_core.dart';

import '../klarnanetworkmessaging/messaging_placement_screen.dart';
import '../klarnanetworkpayment/network_payment_screen.dart';

/// Confirms the live instance and lists Klarna Network features scoped to it.
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
          ListTile(
            title: const Text('Klarna Network Payment'),
            subtitle: const Text(
              'Initiate, fetch, cancel, and present payments.',
            ),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => NetworkPaymentScreen(klarna: klarna),
              ),
            ),
          ),
          ListTile(
            title: const Text('Klarna Network Messaging'),
            subtitle: const Text(
              'Render a messaging placement (banner or badge).',
            ),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => MessagingPlacementScreen(klarna: klarna),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
