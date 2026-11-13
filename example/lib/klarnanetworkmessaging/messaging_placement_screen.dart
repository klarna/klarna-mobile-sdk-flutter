import 'package:flutter/material.dart';
import 'package:klarna_network_core/klarna_network_core.dart';
import 'package:klarna_network_messaging/klarna_network_messaging.dart';

import 'prequalification_display.dart';

/// Demonstrates the Klarna messaging operations: the native placement (with
/// pickers for the placement type and theme) and prequalification, sharing one
/// amount/currency input.
enum _PlacementKind { autoSize, badge }

enum _Operation { placement, prequalification }

class MessagingPlacementScreen extends StatefulWidget {
  const MessagingPlacementScreen({super.key, required this.klarna});

  final Klarna klarna;

  @override
  State<MessagingPlacementScreen> createState() =>
      _MessagingPlacementScreenState();
}

class _MessagingPlacementScreenState extends State<MessagingPlacementScreen> {
  _Operation _operation = _Operation.placement;
  _PlacementKind _kind = _PlacementKind.autoSize;
  KlarnaTheme _theme = KlarnaTheme.automatic;
  final _amountController = TextEditingController(text: '19900');
  final _currencyController = TextEditingController(text: 'EUR');
  String _status = 'Ready';

  KlarnaMessagingPlacementConfiguration? _rendered;

  bool _prequalifying = false;
  String? _prequalificationResult;
  String? _prequalificationError;

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

  Future<void> _initiatePrequalification() async {
    if (!_canRender) {
      final missing = <String>[
        if (_amount == null || _amount! <= 0) 'a valid amount',
        if (_currency.isEmpty) 'a currency',
      ];
      setState(() {
        _prequalificationResult = null;
        _prequalificationError = 'Please enter ${missing.join(' and ')}.';
      });
      return;
    }
    setState(() {
      _prequalifying = true;
      _prequalificationResult = null;
      _prequalificationError = null;
    });
    try {
      final result = await widget.klarna.messaging.prequalification.initiate(
        KlarnaMessagingPrequalificationData(
          amount: _amount!,
          currency: _currency,
        ),
      );
      if (!mounted) return;
      setState(() {
        _prequalificationResult = prequalificationResultToDisplayString(result);
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _prequalificationError = prequalificationErrorToDisplayString(error);
      });
    } finally {
      if (mounted) setState(() => _prequalifying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final rendered = _rendered;
    final isPlacement = _operation == _Operation.placement;
    return Scaffold(
      appBar: AppBar(title: const Text('Messaging')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SegmentedButton<_Operation>(
            segments: const [
              ButtonSegment(
                value: _Operation.placement,
                label: Text('Placement'),
              ),
              ButtonSegment(
                value: _Operation.prequalification,
                label: Text('Prequalification'),
              ),
            ],
            selected: {_operation},
            onSelectionChanged: (selection) =>
                setState(() => _operation = selection.first),
          ),
          const SizedBox(height: 8),
          if (isPlacement) ...[
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
          ],
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
          if (isPlacement) ...[
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
          ] else ...[
            const Text(
              'Messaging placements are the recommended surface. Use '
              'prequalification when a placement cannot be rendered.',
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _prequalifying ||
                      _amountController.text.trim().isEmpty ||
                      _currency.isEmpty
                  ? null
                  : _initiatePrequalification,
              child: Text(
                _prequalifying
                    ? 'Prequalifying...'
                    : 'Initiate prequalification',
              ),
            ),
            const SizedBox(height: 16),
            if (_prequalificationResult != null)
              _panel(
                context,
                title: 'Result',
                text: _prequalificationResult!,
                isError: false,
              ),
            if (_prequalificationError != null)
              _panel(
                context,
                title: 'Error',
                text: _prequalificationError!,
                isError: true,
              ),
          ],
        ],
      ),
    );
  }

  Widget _panel(
    BuildContext context, {
    required String title,
    required String text,
    required bool isError,
  }) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      color: isError ? scheme.errorContainer : scheme.secondaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 4),
            SelectableText(text),
          ],
        ),
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
