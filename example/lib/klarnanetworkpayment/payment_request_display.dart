import 'package:klarna_network_payment/klarna_network_payment.dart';

/// Renders a [KlarnaPaymentRequest] as a readable multi-line string. The model
/// is Pigeon-generated (no toJson), so all fields are surfaced by hand.
String paymentRequestToDisplayString(KlarnaPaymentRequest r) {
  final b = StringBuffer()
    ..writeln('paymentRequestId: ${r.paymentRequestId}')
    ..writeln('state: ${r.state.name}');
  if (r.previousState != null)
    b.writeln('previousState: ${r.previousState!.name}');
  if (r.stateReason != null) b.writeln('stateReason: ${r.stateReason!.name}');
  if (r.paymentRequestReference != null) {
    b.writeln('paymentRequestReference: ${r.paymentRequestReference}');
  }
  final ctx = r.stateContext;
  if (ctx != null) {
    b.writeln('stateContext:');
    if (ctx.klarnaNetworkSessionToken != null) {
      b.writeln('  sessionToken: ${ctx.klarnaNetworkSessionToken}');
    }
    final customer = ctx.klarnaCustomer;
    if (customer != null) {
      b.writeln('  customer:');
      if (customer.customerToken != null) {
        b.writeln('    token: ${customer.customerToken}');
      }
      if (customer.customerTokenReference != null) {
        b.writeln('    tokenReference: ${customer.customerTokenReference}');
      }
      final profile = customer.customerProfile;
      if (profile != null) {
        if (profile.email != null) b.writeln('    email: ${profile.email}');
        if (profile.givenName != null || profile.familyName != null) {
          b.writeln('    name: ${profile.givenName ?? ''} '
                  '${profile.familyName ?? ''}'
              .trim());
        }
      }
    }
    final shipping = ctx.shipping;
    if (shipping != null) {
      b.writeln('  shipping:');
      final recipient = shipping.recipient;
      if (recipient != null) {
        b.writeln(
            '    recipient: ${recipient.givenName} ${recipient.familyName}');
      }
      final option = shipping.shippingOption;
      if (option != null) {
        b.writeln('    shippingType: ${option.shippingType.name}');
      }
      if (shipping.address?.country != null) {
        b.writeln('    country: ${shipping.address!.country}');
      }
    }
  }
  return b.toString().trimRight();
}
