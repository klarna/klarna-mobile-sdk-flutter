# klarna_network_payment

Flutter plugin for Klarna Network Payment on iOS and Android. The package
exposes payment request APIs, payment presentation content, and the native
Klarna Payment Button.

This package binds to a Klarna Network session created by
`klarna_network_core`.

## Installation

Add both packages to your Flutter app:

```bash
flutter pub add klarna_network_core
flutter pub add klarna_network_payment
```

## Requirements

- Flutter 3.22 or later.
- Dart 3.6 or later.
- iOS 13 or later.
- Android API 24 or later.
- A Klarna Network client id and session token from Klarna.

## Platform setup

### Android — use `FlutterFragmentActivity`

The Klarna SDK opens its payment custom tab from the host `Activity`, which must
be a `FragmentActivity`. Otherwise payment fails at runtime with *"failed to open
custom tab. Activity is not FragmentActivity"*. Make your `MainActivity` extend
`FlutterFragmentActivity`:

```kotlin
import io.flutter.embedding.android.FlutterFragmentActivity

class MainActivity : FlutterFragmentActivity()
```

### iOS — register your return URL scheme

The `appReturnUrl` passed to `Klarna.initialize` must use a URL scheme registered
in your app's `Info.plist`, or the SDK rejects it as an invalid return URL. Add
it under `CFBundleURLTypes`:

```xml
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleURLName</key>
    <string>$(PRODUCT_BUNDLE_IDENTIFIER).returnurl</string>
    <key>CFBundleURLSchemes</key>
    <array>
      <string>your-app</string>
    </array>
  </dict>
</array>
```

Then use a matching return URL, e.g. `appReturnUrl: 'your-app://return'`.

## Basic Flow

```dart
import 'package:klarna_network_core/klarna_network_core.dart';
import 'package:klarna_network_payment/klarna_network_payment.dart';

final klarna = await Klarna.initialize(
  KlarnaConfiguration(
    clientId: 'your-client-id',
    appReturnUrl: 'merchant-app://klarna-return',
    accountId: 'your-account-id',
    locale: 'en-US',
    klarnaNetworkSessionToken: 'session-token',
  ),
);

final payment = klarna.payment;

final request = await payment.initiate(
  KlarnaPaymentRequestData(
    currency: 'EUR',
    amount: 1000,
  ),
);

await payment.fetch(request.paymentRequestId);

final content = await payment.presentation.fetch(
  KlarnaPaymentPresentationData(currency: 'EUR', amount: 1000),
);

await klarna.dispose();
```

Use `cancel(paymentRequestId)` only for non-final payment requests.

## Payment Button

The package includes a platform view that renders Klarna's Payment Button:

```dart
KlarnaPaymentButton(
  instance: klarna,
  configuration: const KlarnaPaymentButtonConfiguration(
    intent: KlarnaPaymentButtonIntent.pay,
    theme: KlarnaTheme.dark,
  ),
  onPressed: () {
    // Start or continue your payment flow.
  },
);
```

The configuration uses the shared `KlarnaButtonShape`, `KlarnaButtonState`,
`KlarnaButtonStyle`, and `KlarnaTheme` types from `klarna_network_core`.
The widget's top-level `state` overrides `configuration.state` for runtime
loading and disabled-state updates.

The `instance` must be an initialized `Klarna` instance.

### Button props

| Prop            | Notes                                                                                     |
| --------------- | ----------------------------------------------------------------------------------------- |
| `instance`      | Required. The initialized `Klarna` instance.                                              |
| `configuration` | Button appearance and intent (`KlarnaButtonShape`/`Style`/`State`, `KlarnaTheme`).        |
| `state`         | Optional. Overrides `configuration.state` for runtime loading/disabled updates.           |
| `onPressed`     | Required. Called when the button is tapped.                                               |
| `height`        | Optional. Button height; defaults to the native minimum of 56 logical pixels.             |

## Errors

Future-returning APIs throw `KlarnaSDKError` for SDK failures.

```dart
try {
  await payment.fetch(paymentRequestId);
} on KlarnaSDKError catch (error) {
  // error.name, error.message, error.cause
}
```

## Deep links

Route app return URLs through core first, then through payment presentation when
the URL belongs to presentation content:

```dart
final handledByCore = await Klarna.handleReturnUrl(url);
if (!handledByCore) {
  await payment.presentation.handleLink(url);
}
```

The example app wires this with `app_links` and shows the latest deep-link
handling result in the Network Payment screen.

## Architecture

The package uses:

1. **Pigeon** for the typed API surface. `pigeons/kn_payment.dart` generates the
   Dart, Swift, and Kotlin message APIs.
2. **Platform views** for the native Klarna Payment Button on iOS and Android.

## Regenerating the Pigeon code

```bash
dart run pigeon --input pigeons/kn_payment.dart
```

## Tests

```bash
flutter test
```

From the workspace root, run `melos run analyze` and `melos run test` before
submitting changes. The example app also includes an integration test that
verifies the Dart-to-native Pigeon wiring on iOS simulators and Android
emulators.
