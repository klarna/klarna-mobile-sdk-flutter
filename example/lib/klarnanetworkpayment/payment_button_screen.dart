import 'package:flutter/material.dart';
import 'package:klarna_network_core/klarna_network_core.dart';
import 'package:klarna_network_payment/klarna_network_payment.dart';

/// Renders the native Klarna Payment Button, with pickers for each typed prop
/// (state / intent / shape / style / theme).
class PaymentButtonScreen extends StatefulWidget {
  const PaymentButtonScreen({super.key, required this.klarna});

  final Klarna klarna;

  @override
  State<PaymentButtonScreen> createState() => _PaymentButtonScreenState();
}

const double _widthStep = 20;
const double _heightStep = 8;
const double _minWidth = 80;
// The native button clips below this, so don't offer shorter sizes.
const double _minHeight = 56;

class _PaymentButtonScreenState extends State<PaymentButtonScreen> {
  KlarnaButtonState _state = KlarnaButtonState.default_;
  KlarnaPaymentButtonIntent _intent = KlarnaPaymentButtonIntent.pay;
  KlarnaButtonShape _shape = KlarnaButtonShape.roundedRect;
  KlarnaButtonStyle _style = KlarnaButtonStyle.filled;
  KlarnaTheme _theme = KlarnaTheme.automatic;
  double _width = 300;
  double _height = _minHeight;
  String _status = 'Ready';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Payment Button')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _picker<KlarnaButtonState>(
            'State',
            KlarnaButtonState.values,
            _state,
            (v) => setState(() => _state = v),
          ),
          _picker<KlarnaPaymentButtonIntent>(
            'Intent',
            KlarnaPaymentButtonIntent.values,
            _intent,
            (v) => setState(() => _intent = v),
          ),
          _picker<KlarnaButtonShape>(
            'Shape',
            KlarnaButtonShape.values,
            _shape,
            (v) => setState(() => _shape = v),
          ),
          _picker<KlarnaButtonStyle>(
            'Style',
            KlarnaButtonStyle.values,
            _style,
            (v) => setState(() => _style = v),
          ),
          _picker<KlarnaTheme>(
            'Theme',
            KlarnaTheme.values,
            _theme,
            (v) => setState(() => _theme = v),
          ),
          const SizedBox(height: 16),
          _sizeControls(),
          const SizedBox(height: 8),
          Text('Size: ${_width.toStringAsFixed(0)} × '
              '${_height.toStringAsFixed(0)}'),
          const SizedBox(height: 8),
          Center(
            // Sized, centered box so the button's layout footprint can be varied.
            child: SizedBox(
              width: _width,
              height: _height,
              child: KlarnaPaymentButton(
                // No ValueKey: prop changes are pushed to the existing native
                // view, so the button updates without remounting/flicker.
                instance: widget.klarna,
                state: _state,
                configuration: KlarnaPaymentButtonConfiguration(
                  intent: _intent,
                  shape: _shape,
                  style: _style,
                  theme: _theme,
                ),
                height: _height,
                onPressed: () => setState(() => _status = 'Button pressed'),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text('Status: $_status'),
        ],
      ),
    );
  }

  Widget _sizeControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Column(
          children: [
            const Text('Width'),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                OutlinedButton(
                  onPressed: () => setState(() =>
                      _width = (_width - _widthStep).clamp(_minWidth, 1000)),
                  child: const Text('W−'),
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: () => setState(() => _width += _widthStep),
                  child: const Text('W+'),
                ),
              ],
            ),
          ],
        ),
        Column(
          children: [
            const Text('Height'),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                OutlinedButton(
                  onPressed: () => setState(() => _height =
                      (_height - _heightStep).clamp(_minHeight, 1000)),
                  child: const Text('H−'),
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: () => setState(() => _height += _heightStep),
                  child: const Text('H+'),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _picker<T extends Enum>(
    String label,
    List<T> values,
    T selected,
    ValueChanged<T> onChanged, {
    String Function(T)? labelOf,
  }) {
    final toLabel = labelOf ?? (v) => v.name;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: DropdownButtonFormField<T>(
        initialValue: selected,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          isDense: true,
        ),
        items: [
          for (final v in values)
            DropdownMenuItem(value: v, child: Text(toLabel(v))),
        ],
        onChanged: (v) {
          if (v != null) onChanged(v);
        },
      ),
    );
  }
}
