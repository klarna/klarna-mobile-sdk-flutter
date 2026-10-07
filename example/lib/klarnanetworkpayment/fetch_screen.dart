import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:klarna_network_payment/klarna_network_payment.dart';

import 'payment_request_display.dart';

/// Fetch the current state of a payment request by its id.
class FetchScreen extends StatefulWidget {
  const FetchScreen({super.key, required this.payment});

  final KlarnaPayment payment;

  @override
  State<FetchScreen> createState() => _FetchScreenState();
}

class _FetchScreenState extends State<FetchScreen> {
  final _requestId = TextEditingController();
  String _status = 'Ready';

  String? _resultId;
  String? _result;

  @override
  void dispose() {
    _requestId.dispose();
    super.dispose();
  }

  Future<void> _fetch() async {
    final id = _requestId.text.trim();
    if (id.isEmpty) {
      setState(() => _status = 'Enter a payment request id.');
      return;
    }
    setState(() => _status = 'fetch…');
    try {
      final request = await widget.payment.fetch(id);
      if (!mounted) return;
      setState(() {
        _resultId = request.paymentRequestId;
        _result = paymentRequestToDisplayString(request);
        _status = 'fetch → ${request.state.name}';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _resultId = null;
        _result = null;
        _status = 'fetch failed: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Fetch')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: TextField(
              controller: _requestId,
              decoration: const InputDecoration(
                labelText: 'Payment Request ID',
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
          ),
          ElevatedButton(onPressed: _fetch, child: const Text('Fetch')),
          const SizedBox(height: 24),
          Text('Status: $_status'),
          if (_result != null) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Text('Result',
                      style: Theme.of(context).textTheme.titleMedium),
                ),
                if (_resultId != null)
                  IconButton(
                    icon: const Icon(Icons.copy),
                    tooltip: 'Copy payment request id',
                    onPressed: () async {
                      await Clipboard.setData(ClipboardData(text: _resultId!));
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Copied payment request id')),
                      );
                    },
                  ),
              ],
            ),
            const SizedBox(height: 4),
            SelectableText(
              _result!,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
            ),
          ],
        ],
      ),
    );
  }
}
