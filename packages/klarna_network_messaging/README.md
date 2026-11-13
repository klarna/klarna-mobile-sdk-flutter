# klarna_network_messaging

Flutter plugin for Klarna Network **messaging placements** on iOS and Android.
It renders on-device messaging (for example credit-promotion banners and
badges) through a native platform view that automatically sizes itself to its
content and reports errors back to Dart.

This package binds to a Klarna Network session created by
`klarna_network_core`.

## Installation

Add both packages to your Flutter app:

```bash
flutter pub add klarna_network_core
flutter pub add klarna_network_messaging
```

## Requirements

- Flutter 3.22 or later.
- Dart 3.6 or later.
- iOS 13 or later.
- Android API 24 or later.
- A Klarna Network client id and session token from Klarna.

## Usage

Initialize a Klarna Network session with `klarna_network_core`, then pass the
`Klarna` instance to the placement view along with a configuration:

```dart
import 'package:flutter/foundation.dart';
import 'package:klarna_network_core/klarna_network_core.dart';
import 'package:klarna_network_messaging/klarna_network_messaging.dart';

final klarna = await Klarna.initialize(
  KlarnaConfiguration(
    clientId: 'your-client-id',
    appReturnUrl: 'merchant-app://klarna-return',
    klarnaNetworkSessionToken: 'session-token',
  ),
);

KlarnaMessagingPlacementView(
  instance: klarna,
  configuration:
      const KlarnaMessagingPlacementConfiguration.creditPromotionAutoSize(
    amount: 19900,
    currency: 'EUR',
    theme: KlarnaTheme.automatic,
  ),
);
```

### Props

| Prop            | Notes                                                                                                                                         |
| --------------- | --------------------------------------------------------------------------------------------------------------------------------------------- |
| `instance`      | Required. The `Klarna` instance obtained from `Klarna.initialize`. The internal `instanceId` is read by the package, so consumers never need to touch it. |
| `configuration` | Required. Use `creditPromotionAutoSize` or `creditPromotionBadge` with `amount`, `currency`, and optional `theme`. |

### Sizing

The view starts at a small fallback height and then adopts the height the
native SDK reports for the loaded content. When the SDK reports no content the
view collapses to zero height. You do not need to set a height yourself.

## Placement configurations

| Constructor | Description |
|---|---|
| `KlarnaMessagingPlacementConfiguration.creditPromotionAutoSize` | A placement that auto-sizes to fit its content. |
| `KlarnaMessagingPlacementConfiguration.creditPromotionBadge` | A compact badge-style placement. |

## Prequalification

Messaging placements are the recommended way to surface Klarna messaging and
prequalification to your customers. Use `klarna.messaging.prequalification.initiate`
only when a placement cannot be rendered in the relevant part of your app.

```dart
final result = await klarna.messaging.prequalification.initiate(
  const KlarnaMessagingPrequalificationData(amount: 9999, currency: 'USD'),
);

switch (result) {
  case KlarnaMessagingPrequalificationApproved(:final expiresAt):
    // The customer was prequalified until `expiresAt` (UTC).
    break;
  case KlarnaMessagingPrequalificationAborted():
    // Not prequalified, or the customer closed the flow. Leave app state as is.
    break;
}
```

- `amount` is in minor units and must be greater than 0; `currency` is a
  non-empty ISO 4217 code. Otherwise `initiate` throws an `ArgumentError`.
- Every customer outcome (approved, not prequalified, closed or abandoned) is a
  successful result. Only a flow that could not be started throws a
  `KlarnaSDKError`, with name `OPERATION_FAILED` or
  `INITIATE_ALREADY_IN_PROGRESS`.
- On Android the app needs a foreground `Activity`; otherwise `initiate` throws a
  `KlarnaSDKError` named `KlarnaNetworkMessaging` ("Main Activity not found.").

## Architecture

The package uses:

1. **Platform views** for the native `KlarnaMessagingPlacementView` on iOS
   (`UiKitView`) and Android (hybrid-composition `AndroidView`).
2. **Pigeon** for the typed native → Dart event channel
   (`pigeons/kn_messaging.dart`), which carries per-view height and error
   events keyed by a unique view id, and for the Dart → native
   prequalification host API.

## Regenerating the Pigeon code

```bash
dart run pigeon --input pigeons/kn_messaging.dart
```

## Tests

```bash
flutter test
```

From the workspace root, run `melos run analyze` and `melos run test` before
submitting changes.
