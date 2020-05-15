# Klarna In-App Flutter Plugin

Klarna&#x27;s Flutter wrapper for the In-App SDK

## Getting Started

After cloning the repository run the command below to setup the project.
```shell script
flutter packages get
```

### Android Studio

1. Execute `cd example; flutter build apk`
2. Import the `example/android/build.gradle` file or open `example/android` folder from Android Studio.

Plugin implementation will be located at `flutter_klarna_inapp_sdk/java/com.klarna.inapp.sdk.flutter_klarna_inapp_sdk/`.

### XCode

1. Execute `cd example; flutter build ios --no-codesign`
2. Import the `example/ios/Runner.xcworkspace` file from XCode.

Plugin implementation will be located at `Pods/Development Pods/flutter_klarna_inapp_sdk/../../example/ios/.symlinks/plugins/flutter_klarna_inapp_sdk/ios/Classes`.

### Official Flutter Documentations

This project is a starting point for a Flutter
[plug-in package](https://flutter.dev/developing-packages/),
a specialized package that includes platform-specific implementation code for
Android and/or iOS.

For help getting started with Flutter, view our 
[online documentation](https://flutter.dev/docs), which offers tutorials, 
samples, guidance on mobile development, and a full API reference.
