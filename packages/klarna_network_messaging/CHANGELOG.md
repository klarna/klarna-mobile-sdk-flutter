# Changelog

All notable changes to this package will be documented in this file.

## 2.1.0

- Initial release.
- Added the `KlarnaMessagingPlacementView` platform view for rendering Klarna
  Network messaging placements (credit-promotion auto-size and badge) on iOS and
  Android.
- Added automatic content-height sizing driven by native resize events, with a
  minimum-height fallback and collapse-to-zero when there is no content.
- Added the `KlarnaMessagingPlacementConfiguration` named constructors and
  shared core `KlarnaTheme`.
