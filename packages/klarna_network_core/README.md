# klarna_network_core

[![License][license-image]][license-url]
[![Developed at Klarna][klarna-image]][klarna-url]

> Klarna's Flutter plugin for Klarna Network core — initializes and manages Klarna Network SDK sessions on iOS and Android.

**Looking for the native Klarna Network Core SDK?** Check out [Klarna Mobile SDK iOS](https://github.com/klarna/klarna-mobile-sdk-ios) or [Klarna Mobile SDK Android](https://github.com/klarna/klarna-mobile-sdk-android).

**Looking for the React Native Klarna Network SDK?** Check out the [React Native Klarna Mobile SDK](https://github.com/klarna/react-native-klarna-inapp-sdk).

## Installation

Add the package to your Flutter app:

```bash
flutter pub add klarna_network_core
```

## Requirements

- Flutter 3.22 or later.
- Dart 3.6 or later.
- iOS 13 or later.
- Android API 24 or later.
- A Klarna Network client id and any merchant/account configuration provided by
  Klarna.

## Platform setup

### iOS — register your return URL scheme

The `appReturnUrl` you pass to `Klarna.initialize` must use a URL scheme that is
registered in your app's `Info.plist`. If the scheme is not registered, the
Klarna SDK rejects the value as an invalid return URL. Add it under
`CFBundleURLTypes`:

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

## Usage

```dart
import 'package:klarna_network_core/klarna_network_core.dart';

final klarna = await Klarna.initialize(
  KlarnaConfiguration(
    clientId: 'your-client-id',
    appReturnUrl: 'your-app://return',
    accountId: 'your-account-id',
    locale: 'en-US',
    klarnaNetworkSessionToken: 'session-token',
  ),
);

final token = await klarna.network.session.token();

klarna.setIntegrationMetadata(
  KlarnaIntegrationMetadata(
    integrator: KlarnaIntegratorMetadata(
      name: 'MyFlutterApp',
      sessionReference: 'session-reference',
      moduleName: 'checkout',
      moduleVersion: '1.0.0',
    ),
  ),
);

await klarna.dispose();
```

Keep the `Klarna` instance for as long as Klarna Network features in your app
need to share the same native session. Dispose it when the session is no longer
needed.

Calling `Klarna.initialize` again with an equivalent `KlarnaConfiguration`
returns the same instance and reuses the single native session; `dispose`
releases it so a later `initialize` creates a fresh one.

## Return URLs

Configure your app's custom scheme or universal link according to your Flutter
app-linking setup. When a URL returns to the app, route it through the static
handler:

```dart
final handled = await Klarna.handleReturnUrl(url);
```

On iOS this dispatches to `Klarna.handleReturnUrl`. On Android this currently
returns `false`; return links should then be offered to the relevant Klarna
Network feature package.

## Integration Metadata

`setIntegrationMetadata` lets apps identify the top-level integration and any
originating module. This helps native Klarna SDK telemetry attribute the
integration correctly.

```dart
klarna.setIntegrationMetadata(
  KlarnaIntegrationMetadata(
    integrator: KlarnaIntegratorMetadata(
      name: 'MerchantApp',
      sessionReference: 'cart-or-checkout-session-id',
      moduleName: 'checkout',
      moduleVersion: '1.2.3',
    ),
  ),
);
```

## Architecture

Pigeon schema `pigeons/kn_core.dart` generates the Dart/Swift/Kotlin host API.
The native plugin holds a thread-safe instance store (`KnInstanceStore`) so
sibling KN packages can fetch the `Klarna` instance by id.

Regenerate: `dart run pigeon --input pigeons/kn_core.dart`

## Tests

```bash
flutter test
```

From the workspace root, run `melos run analyze` and `melos run test` before
submitting changes.

[license-image]: https://img.shields.io/badge/license-Apache%202-blue?style=flat-square
[license-url]: https://www.apache.org/licenses/LICENSE-2.0
[klarna-image]: https://img.shields.io/badge/%20-Developed%20at%20Klarna-black?labelColor=ffb3c7&style=flat-square&logo=data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAOCAYAAAAmL5yKAAAAAXNSR0IArs4c6QAAAIRlWElmTU0AKgAAAAgABQESAAMAAAABAAEAAAEaAAUAAAABAAAASgEbAAUAAAABAAAAUgEoAAMAAAABAAIAAIdpAAQAAAABAAAAWgAAAAAAAALQAAAAAQAAAtAAAAABAAOgAQADAAAAAQABAACgAgAEAAAAAQAAABCgAwAEAAAAAQAAAA4AAAAA0LMKiwAAAAlwSFlzAABuugAAbroB1t6xFwAAAVlpVFh0WE1MOmNvbS5hZG9iZS54bXAAAAAAADx4OnhtcG1ldGEgeG1sbnM6eD0iYWRvYmU6bnM6bWV0YS8iIHg6eG1wdGs9IlhNUCBDb3JlIDUuNC4wIj4KICAgPHJkZjpSREYgeG1sbnM6cmRmPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5LzAyLzIyLXJkZi1zeW50YXgtbnMjIj4KICAgICAgPHJkZjpEZXNjcmlwdGlvbiByZGY6YWJvdXQ9IiIKICAgICAgICAgICAgeG1sbnM6dGlmZj0iaHR0cDovL25zLmFkb2JlLmNvbS90aWZmLzEuMC8iPgogICAgICAgICA8dGlmZjpPcmllbnRhdGlvbj4xPC90aWZmOk9yaWVudGF0aW9uPgogICAgICA8L3JkZjpEZXNjcmlwdGlvbj4KICAgPC9yZGY6UkRGPgo8L3g6eG1wbWV0YT4KTMInWQAAAVBJREFUKBVtkz0vREEUhsdXgo5qJXohkUgQ0fgFNFpR2V5ClP6CQu9PiB6lEL1I7B9A4/treZ47c252s97k2ffMmZkz5869m1JKL/AFbzAHaiRbmsIf4BdaMAZqMFsOXNxXkroKbxCPV5l8yHOJLVipn9/vEreLa7FguSN3S2ynA/ATeQuI8tTY6OOY34DQaQnq9mPCDtxoBwuRxPfAvPMWnARlB12KAi6eLTPruOOP4gcl33O6+Sjgc83DJkRH+h2MgorLzaPy68W48BG2S+xYnmAa1L+nOxEduMH3fgjGFvZeVkANZau68B6CrgJxWosFFpF7iG+h5wKZqwt42qIJtARu/ix+gqsosEq8D35o6R3c7OL4lAnTDljEe9B3Qa2BYzmHemDCt6Diwo6JY7E+A82OnN9HuoBruAQvUQ1nSxP4GVzBDRyBfygf6RW2/gD3NmEv+K/DZgAAAABJRU5ErkJggg==
[klarna-url]: https://github.com/klarna
