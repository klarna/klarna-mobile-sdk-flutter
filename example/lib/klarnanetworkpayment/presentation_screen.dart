import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:klarna_network_core/klarna_network_core.dart';
import 'package:klarna_network_payment/klarna_network_payment.dart';

/// Fetch presentation content and render the returned payment option(s).
/// Link taps route through `presentation.handleLink`.
class PresentationScreen extends StatefulWidget {
  const PresentationScreen({
    super.key,
    required this.klarna,
    required this.payment,
  });

  final Klarna klarna;
  final KlarnaPayment payment;

  @override
  State<PresentationScreen> createState() => _PresentationScreenState();
}

class _PresentationScreenState extends State<PresentationScreen> {
  final _amount = TextEditingController(text: '1000');
  final _currency = TextEditingController(text: 'USD');
  final _programCodes = TextEditingController();
  final _billingFrequency = TextEditingController();
  KlarnaPaymentPresentationIntent? _intent;
  KlarnaInterval? _billingInterval;

  bool _loading = false;
  String? _error;
  KlarnaPaymentPresentationContent? _content;

  @override
  void dispose() {
    _amount.dispose();
    _currency.dispose();
    _programCodes.dispose();
    _billingFrequency.dispose();
    super.dispose();
  }

  KlarnaPaymentPresentationData? _buildData() {
    final amount = int.tryParse(_amount.text.trim());
    final currency = _currency.text.trim();
    if (amount == null || amount <= 0) {
      setState(() => _error = 'Amount must be a positive integer.');
      return null;
    }
    if (currency.isEmpty) {
      setState(() => _error = 'Currency is required.');
      return null;
    }
    int? frequency;
    if (_billingFrequency.text.trim().isNotEmpty) {
      frequency = int.tryParse(_billingFrequency.text.trim());
      if (frequency == null || frequency <= 0) {
        setState(() =>
            _error = 'Billing interval frequency must be a positive integer.');
        return null;
      }
    }
    final codes = _programCodes.text
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    return KlarnaPaymentPresentationData(
      amount: amount,
      currency: currency,
      intent: _intent,
      paymentProgramEnablementCodes: codes.isEmpty ? null : codes,
      subscriptionBillingInterval: _billingInterval,
      subscriptionBillingIntervalFrequency: frequency,
    );
  }

  Future<void> _fetch() async {
    final data = _buildData();
    if (data == null) return;
    setState(() {
      _error = null;
      _content = null;
      _loading = true;
    });
    try {
      final content = await widget.payment.presentation.fetch(data);
      if (!mounted) return;
      setState(() => _content = content);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = '$e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _handleLink(String url) async {
    setState(() {
      _error = null;
      _loading = true;
    });
    try {
      final content = await widget.payment.presentation.handleLink(url);
      if (!mounted) return;
      setState(() => _content = content);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = '$e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Presentation')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Expanded(child: _field(_amount, 'Amount')),
              const SizedBox(width: 8),
              Expanded(child: _field(_currency, 'Currency')),
            ],
          ),
          const SizedBox(height: 8),
          _enumDropdown<KlarnaPaymentPresentationIntent>(
            'Intent (optional)',
            KlarnaPaymentPresentationIntent.values,
            _intent,
            (v) => setState(() => _intent = v),
          ),
          const SizedBox(height: 8),
          _field(_programCodes, 'Program enablement codes (comma separated)'),
          const SizedBox(height: 8),
          _enumDropdown<KlarnaInterval>(
            'Subscription billing interval (optional)',
            KlarnaInterval.values,
            _billingInterval,
            (v) => setState(() => _billingInterval = v),
          ),
          const SizedBox(height: 8),
          _field(_billingFrequency, 'Billing interval frequency'),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: _loading ? null : _fetch,
            child: const Text('Fetch presentation'),
          ),
          const SizedBox(height: 16),
          if (_loading) const Center(child: CircularProgressIndicator()),
          if (_error != null)
            Text('Error: $_error',
                style: TextStyle(color: Theme.of(context).colorScheme.error)),
          if (_content != null) ..._buildContent(_content!),
        ],
      ),
    );
  }

  KlarnaPaymentButtonIntent _buttonIntent() => switch (_intent) {
        KlarnaPaymentPresentationIntent.subscribe =>
          KlarnaPaymentButtonIntent.subscribe,
        KlarnaPaymentPresentationIntent.addToWallet =>
          KlarnaPaymentButtonIntent.addToWallet,
        KlarnaPaymentPresentationIntent.pay ||
        null =>
          KlarnaPaymentButtonIntent.pay,
      };

  List<Widget> _buildContent(KlarnaPaymentPresentationContent content) {
    return [
      const SizedBox(height: 8),
      Text('Instruction: ${content.instruction.name}'),
      if (content.paymentStatus != null)
        Text('Payment status: ${content.paymentStatus!.name}'),
      if (content.paymentOption != null) ...[
        const SizedBox(height: 12),
        Text('Payment option', style: Theme.of(context).textTheme.titleSmall),
        _optionCard(content.paymentOption!),
      ],
      if (content.savedPaymentOption != null) ...[
        const SizedBox(height: 12),
        Text('Saved payment option',
            style: Theme.of(context).textTheme.titleSmall),
        _optionCard(content.savedPaymentOption!),
      ],
    ];
  }

  static const _cardColor = Color(0xFFFFFFFF);
  static const _darker = Color(0xFF222222);
  static const _dark = Color(0xFF444444);
  static const _pink = Color(0xFFFFB3C7);

  Widget _optionCard(KlarnaPaymentPresentationPaymentOption option) {
    final iconUrl =
        option.icon?.rectangleImageUrl ?? option.icon?.squareImageUrl;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 4,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _badge(option.badge),
            _text(
                option.header,
                const TextStyle(
                    fontSize: 17, fontWeight: FontWeight.w700, color: _darker)),
            _text(
                option.subheader,
                const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w500, color: _dark)),
            _text(option.message,
                const TextStyle(fontSize: 13, color: _dark, height: 1.4)),
            _text(option.terms,
                const TextStyle(fontSize: 11, color: Colors.grey, height: 1.4)),
            if (option.paymentButton != null) ...[
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),
              KlarnaPaymentButton(
                instance: widget.klarna,
                configuration: KlarnaPaymentButtonConfiguration(
                  intent: _buttonIntent(),
                ),
                onPressed: () {},
              ),
            ] else if (iconUrl != null) ...[
              const SizedBox(height: 8),
              _icon(iconUrl, height: 40),
            ],
          ],
        ),
      ),
    );
  }

  Widget _badge(KlarnaPaymentPresentationText? badge) {
    final text = badge?.text ?? (badge?.parts?.map((p) => p.text).join() ?? '');
    if (badge == null || text.isEmpty) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: _pink,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: const TextStyle(
            fontSize: 11, fontWeight: FontWeight.w700, color: _darker),
      ),
    );
  }

  /// Renders a presentation icon. Klarna serves these as SVG (via flutter_svg);
  /// raster URLs fall back to Image.network. Failures render nothing.
  Widget _icon(String url, {required double height}) {
    final failed = SizedBox(height: height);
    if (url.toLowerCase().endsWith('.svg')) {
      return SvgPicture.network(
        url,
        height: height,
        placeholderBuilder: (_) => SizedBox(height: height, width: height),
      );
    }
    return Image.network(
      url,
      height: height,
      errorBuilder: (_, __, ___) => failed,
    );
  }

  Widget _text(KlarnaPaymentPresentationText? value, TextStyle style) =>
      value == null
          ? const SizedBox.shrink()
          : _PresentationText(
              value: value,
              style: style,
              onLink: _handleLink,
            );

  Widget _field(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        isDense: true,
      ),
    );
  }

  Widget _enumDropdown<T extends Enum>(
    String label,
    List<T> values,
    T? selected,
    ValueChanged<T?> onChanged,
  ) {
    return DropdownButtonFormField<T?>(
      initialValue: selected,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        isDense: true,
      ),
      items: [
        const DropdownMenuItem(value: null, child: Text('None')),
        for (final v in values) DropdownMenuItem(value: v, child: Text(v.name)),
      ],
      onChanged: onChanged,
    );
  }
}

class _PresentationText extends StatefulWidget {
  const _PresentationText({
    required this.value,
    required this.style,
    required this.onLink,
  });

  final KlarnaPaymentPresentationText value;
  final TextStyle style;
  final ValueChanged<String> onLink;

  @override
  State<_PresentationText> createState() => _PresentationTextState();
}

class _PresentationTextState extends State<_PresentationText> {
  final Map<int, TapGestureRecognizer> _linkRecognizers = {};

  @override
  void initState() {
    super.initState();
    _replaceRecognizers();
  }

  @override
  void didUpdateWidget(covariant _PresentationText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.value, widget.value)) {
      _replaceRecognizers();
    }
  }

  void _replaceRecognizers() {
    for (final recognizer in _linkRecognizers.values) {
      recognizer.dispose();
    }
    _linkRecognizers.clear();

    final parts = widget.value.parts;
    if (parts == null) return;
    for (var index = 0; index < parts.length; index++) {
      final part = parts[index];
      if (part.type == 'link' && part.url != null) {
        _linkRecognizers[index] = TapGestureRecognizer()
          ..onTap = () {
            final currentParts = widget.value.parts;
            if (currentParts == null || index >= currentParts.length) return;
            final url = currentParts[index].url;
            if (url != null) widget.onLink(url);
          };
      }
    }
  }

  @override
  void dispose() {
    for (final recognizer in _linkRecognizers.values) {
      recognizer.dispose();
    }
    _linkRecognizers.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final parts = widget.value.parts;
    if (parts == null || parts.isEmpty) {
      final plain = widget.value.text;
      return plain == null || plain.isEmpty
          ? const SizedBox.shrink()
          : Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text(plain, style: widget.style),
            );
    }

    final linkStyle =
        widget.style.copyWith(decoration: TextDecoration.underline);
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text.rich(
        TextSpan(
          style: widget.style,
          children: [
            for (var index = 0; index < parts.length; index++)
              TextSpan(
                text: parts[index].text,
                style: _linkRecognizers.containsKey(index) ? linkStyle : null,
                recognizer: _linkRecognizers[index],
              ),
          ],
        ),
      ),
    );
  }
}
