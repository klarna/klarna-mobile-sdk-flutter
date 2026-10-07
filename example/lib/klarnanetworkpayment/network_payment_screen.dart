import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:klarna_network_core/klarna_network_core.dart';
import 'package:klarna_network_payment/klarna_network_payment.dart';

import 'cancel_screen.dart';
import 'fetch_screen.dart';
import 'initiate_screen.dart';
import 'payment_button_screen.dart';
import 'presentation_screen.dart';

/// Menu of payment features (Initiate/Fetch/Cancel/Presentation/Payment Button).
/// Owns the deep-link return path and shares `klarna.payment`.
class NetworkPaymentScreen extends StatefulWidget {
  const NetworkPaymentScreen({super.key, required this.klarna});

  final Klarna klarna;

  @override
  State<NetworkPaymentScreen> createState() => _NetworkPaymentScreenState();
}

class _NetworkPaymentScreenState extends State<NetworkPaymentScreen> {
  late final KlarnaPayment _payment = widget.klarna.payment;
  StreamSubscription<Uri>? _deepLinksSub;
  final _appLinks = AppLinks();

  String _lastEvent = '—';

  @override
  void initState() {
    super.initState();
    _listenToDeepLinks();
  }

  @override
  void dispose() {
    final deepLinksSub = _deepLinksSub;
    if (deepLinksSub != null) {
      unawaited(_cancelSubscription('deep links', deepLinksSub));
    }
    super.dispose();
  }

  Future<void> _cancelSubscription<T>(
    String name,
    StreamSubscription<T> subscription,
  ) async {
    try {
      await subscription.cancel();
    } catch (error, stackTrace) {
      debugPrint('KN_PAYMENT $name subscription cancellation failed: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  void _listenToDeepLinks() {
    unawaited(_handleInitialLink());
    _deepLinksSub = _appLinks.uriLinkStream.listen(
      _handleIncomingLink,
      onError: (Object error) {
        if (!mounted) return;
        setState(() => _lastEvent = 'deep link listen failed: $error');
      },
    );
  }

  Future<void> _handleInitialLink() async {
    try {
      final uri = await _appLinks.getInitialLink();
      if (!mounted) return;
      if (uri != null) await _handleIncomingLink(uri);
    } catch (error, stackTrace) {
      debugPrint('KN_PAYMENT initial deep link failed: $error');
      debugPrintStack(stackTrace: stackTrace);
      if (!mounted) return;
      setState(() => _lastEvent = 'initial deep link failed: $error');
    }
  }

  Future<void> _handleIncomingLink(Uri uri) async {
    if (!mounted) return;
    final url = uri.toString();
    try {
      final handledByCore = await Klarna.handleReturnUrl(url);
      if (!mounted) return;
      if (handledByCore) {
        setState(() => _lastEvent = 'return URL handled by Klarna Network');
        return;
      }
      final content = await _payment.presentation.handleLink(url);
      if (!mounted) return;
      setState(() => _lastEvent =
          'return URL handled by presentation (${content.instruction})');
    } catch (error) {
      if (!mounted) return;
      setState(() => _lastEvent = 'return URL failed: $error');
    }
  }

  void _open(Widget screen) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => screen),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Klarna Network Payment')),
      body: ListView(
        children: [
          _MenuItem(
            title: 'Initiate',
            subtitle: 'Start a payment by request data or request id',
            onTap: () => _open(InitiateScreen(payment: _payment)),
          ),
          _MenuItem(
            title: 'Fetch',
            subtitle: 'Fetch a payment request by id',
            onTap: () => _open(FetchScreen(payment: _payment)),
          ),
          _MenuItem(
            title: 'Cancel',
            subtitle: 'Cancel a payment request by id',
            onTap: () => _open(CancelScreen(payment: _payment)),
          ),
          _MenuItem(
            title: 'Presentation',
            subtitle: 'Fetch presentation content',
            onTap: () => _open(PresentationScreen(
              klarna: widget.klarna,
              payment: _payment,
            )),
          ),
          _MenuItem(
            title: 'Payment Button',
            subtitle: 'Render the native Klarna Payment Button',
            onTap: () => _open(PaymentButtonScreen(klarna: widget.klarna)),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text('Latest event: $_lastEvent'),
          ),
        ],
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  const _MenuItem({
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          title: Text(title),
          subtitle: Text(subtitle),
          trailing: const Icon(Icons.chevron_right),
          onTap: onTap,
        ),
        const Divider(height: 1),
      ],
    );
  }
}
