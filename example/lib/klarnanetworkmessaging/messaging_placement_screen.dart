import 'package:flutter/material.dart';
import 'package:klarna_network_core/klarna_network_core.dart';
import 'package:klarna_network_messaging/klarna_network_messaging.dart';

/// Demonstrates the native Klarna messaging placement, with pickers for the
/// placement type and theme plus an amount/currency input.
enum _PlacementKind { autoSize, badge }

class MessagingPlacementScreen extends StatefulWidget {
  const MessagingPlacementScreen({super.key, required this.klarna});

  final Klarna klarna;

  @override
  State<MessagingPlacementScreen> createState() =>
      _MessagingPlacementScreenState();
}

class _MessagingPlacementScreenState extends State<MessagingPlacementScreen> {
  _PlacementKind _kind = _PlacementKind.autoSize;
  KlarnaTheme _theme = KlarnaTheme.automatic;
  final _amountController = TextEditingController(text: '19900');
  final _currencyController = TextEditingController(text: 'EUR');
  String _status = 'Ready';

  KlarnaMessagingPlacementConfiguration? _rendered;

  @override
  void dispose() {
    _amountController.dispose();
    _currencyController.dispose();
    super.dispose();
  }

  int? get _amount => int.tryParse(_amountController.text.trim());
  String get _currency => _currencyController.text.trim();
  bool get _canRender =>
      _amount != null && _amount! > 0 && _currency.isNotEmpty;

  void _render() {
    if (!_canRender) {
      final missing = <String>[
        if (_amount == null || _amount! <= 0) 'a valid amount',
        if (_currency.isEmpty) 'a currency',
      ];
      setState(() {
        _rendered = null;
        _status = 'Please enter ${missing.join(' and ')}.';
      });
      return;
    }
    setState(() {
      _status = 'Ready';
      _rendered = switch (_kind) {
        _PlacementKind.autoSize =>
          KlarnaMessagingPlacementConfiguration.creditPromotionAutoSize(
            amount: _amount!,
            currency: _currency,
            theme: _theme,
          ),
        _PlacementKind.badge =>
          KlarnaMessagingPlacementConfiguration.creditPromotionBadge(
            amount: _amount!,
            currency: _currency,
            theme: _theme,
          ),
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    final rendered = _rendered;
    return Scaffold(
      appBar: AppBar(title: const Text('Messaging Placement')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _picker<_PlacementKind>(
            'Placement type',
            _PlacementKind.values,
            _kind,
            (v) => setState(() => _kind = v),
          ),
          _picker<KlarnaTheme>(
            'Theme',
            KlarnaTheme.values,
            _theme,
            (v) => setState(() => _theme = v),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Amount (minor units)',
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: TextField(
              controller: _currencyController,
              decoration: const InputDecoration(
                labelText: 'Currency (ISO 4217)',
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton(onPressed: _render, child: const Text('Render')),
          const SizedBox(height: 16),
          Text(
            'Status: $_status',
            style: _rendered == null && _status != 'Ready'
                ? TextStyle(color: Theme.of(context).colorScheme.error)
                : null,
          ),
          const SizedBox(height: 16),
          if (rendered == null)
            const Text('Enter an amount and currency, then tap Render.')
          else
            KlarnaMessagingPlacementView(
              key: ValueKey(
                '$_kind-${rendered.theme}-'
                '${rendered.amount}-${rendered.currency}',
              ),
              instance: widget.klarna,
              configuration: rendered,
            ),
        ],
      ),
    );
  }

  Widget _picker<T>(
    String label,
    List<T> values,
    T selected,
    ValueChanged<T> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          DropdownButton<T>(
            value: selected,
            items: [
              for (final value in values)
                DropdownMenuItem<T>(
                  value: value,
                  child: Text(value.toString().split('.').last),
                ),
            ],
            onChanged: (value) {
              if (value != null) onChanged(value);
            },
          ),
        ],
      ),
    );
  }
}
