import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:klarna_network_payment/klarna_network_payment.dart';

import 'payment_request_data_json.dart';
import 'payment_request_display.dart';

/// Initiate a payment request — by client-side request data (amount/currency)
/// or by an existing server-side payment request id.
class InitiateScreen extends StatefulWidget {
  const InitiateScreen({super.key, required this.payment});

  final KlarnaPayment payment;

  @override
  State<InitiateScreen> createState() => _InitiateScreenState();
}

class _InitiateScreenState extends State<InitiateScreen> {
  final _amount = TextEditingController(text: '100');
  final _currency = TextEditingController(text: 'USD');
  final _requestId = TextEditingController();
  final _json = TextEditingController(
    text: '{\n  "amount": 100,\n  "currency": "USD"\n}',
  );
  String _status = 'Ready';

  String? _resultId;
  String? _result;

  @override
  void dispose() {
    _amount.dispose();
    _currency.dispose();
    _requestId.dispose();
    _json.dispose();
    super.dispose();
  }

  Future<void> _run(String label, Future<KlarnaPaymentRequest> op) async {
    setState(() => _status = '$label…');
    try {
      final request = await op;
      if (!mounted) return;
      setState(() {
        _resultId = request.paymentRequestId;
        _result = paymentRequestToDisplayString(request);
        _status = '$label → ${request.state.name}';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _resultId = null;
        _result = null;
        _status = '$label failed: $e';
      });
    }
  }

  void _initiateWithData() {
    final amount = int.tryParse(_amount.text.trim());
    final currency = _currency.text.trim();
    if (amount == null || currency.isEmpty) {
      setState(() => _status = 'Enter a valid amount and currency.');
      return;
    }
    _run(
      'initiate (data)',
      widget.payment.initiate(
        KlarnaPaymentRequestData(amount: amount, currency: currency),
      ),
    );
  }

  void _initiateWithId() {
    final id = _requestId.text.trim();
    if (id.isEmpty) {
      setState(() => _status = 'Enter a payment request id.');
      return;
    }
    _run('initiate (id)', widget.payment.initiate(id));
  }

  void _initiateWithJson() {
    final KlarnaPaymentRequestData data;
    try {
      final decoded = jsonDecode(_json.text) as Map<String, dynamic>;
      data = paymentRequestDataFromJson(decoded);
    } on FormatException catch (e) {
      setState(() => _status = 'Invalid JSON: ${e.message}');
      return;
    } catch (e) {
      setState(() => _status = 'Invalid JSON: $e');
      return;
    }
    _run('initiate (json)', widget.payment.initiate(data));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Initiate')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('With payment request data',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _field(_amount, 'Amount')),
              const SizedBox(width: 8),
              Expanded(child: _field(_currency, 'Currency')),
            ],
          ),
          ElevatedButton(
            onPressed: _initiateWithData,
            child: const Text('Initiate with data'),
          ),
          const SizedBox(height: 24),
          Text('With JSON request data',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          TextField(
            controller: _json,
            maxLines: 8,
            style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
            decoration: const InputDecoration(
              labelText: 'KlarnaPaymentRequestData JSON',
              border: OutlineInputBorder(),
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: _initiateWithJson,
            child: const Text('Initiate with JSON'),
          ),
          const SizedBox(height: 24),
          Text('With payment request id',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          _field(_requestId, 'Payment Request ID'),
          ElevatedButton(
            onPressed: _initiateWithId,
            child: const Text('Initiate with id'),
          ),
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

  Widget _field(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          isDense: true,
        ),
      ),
    );
  }
}
