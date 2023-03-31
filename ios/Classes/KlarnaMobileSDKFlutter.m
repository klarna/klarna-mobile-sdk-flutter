#import "KlarnaMobileSDKFlutter.h"
#if __has_include(<klarna_mobile_sdk_flutter/klarna_mobile_sdk_flutter-Swift.h>)
#import <klarna_mobile_sdk_flutter/klarna_mobile_sdk_flutter-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "klarna_mobile_sdk_flutter-Swift.h"
#endif

@implementation KlarnaMobileSDKFlutter
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftKlarnaMobileSdkFlutter registerWithRegistrar:registrar];
}
@end
