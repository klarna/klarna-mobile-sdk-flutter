# Changelog

All notable changes to this package will be documented in this file.

## 2.2.0

- Updated the Klarna Mobile SDK to iOS 2.16.1 and Android 2.16.1.

## 2.1.0

- Added Klarna Network Payment APIs for initiating, fetching, and canceling
  payment requests.
- Added payment presentation APIs for fetching content and handling return links.
- Added native Klarna Payment Button platform view support for iOS and Android.
- Bound `KlarnaPaymentButton` through its shared `Klarna` instance.
- Added `KlarnaPaymentButtonConfiguration` using the shared core button types.
- Used the shared core `KlarnaSDKError` for SDK errors.
