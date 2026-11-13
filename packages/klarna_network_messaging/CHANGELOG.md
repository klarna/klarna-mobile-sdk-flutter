# Changelog

All notable changes to this package will be documented in this file.

## 2.2.0

- Added `klarna.messaging.prequalification.initiate` to start the Klarna Network
  prequalification flow on iOS and Android. It returns
  `KlarnaMessagingPrequalificationApproved` (with `expiresAt`) or
  `KlarnaMessagingPrequalificationAborted`.
- Updated the Klarna Mobile SDK to iOS 2.16.1 and Android 2.16.1.

## 2.1.0

- Added the `KlarnaMessagingPlacementView` platform view for rendering Klarna
  Network messaging placements (credit-promotion auto-size and badge) on iOS and
  Android.
- Added automatic content-height sizing driven by native resize events, with a
  minimum-height fallback and collapse-to-zero when there is no content.
- Added the `KlarnaMessagingPlacementConfiguration` named constructors and
  shared core `KlarnaTheme`.
