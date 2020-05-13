#import "KlarnaInappFlutterPlugin.h"
#if __has_include(<klarna_inapp_flutter_plugin/klarna_inapp_flutter_plugin-Swift.h>)
#import <klarna_inapp_flutter_plugin/klarna_inapp_flutter_plugin-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "klarna_inapp_flutter_plugin-Swift.h"
#endif

@implementation KlarnaInappFlutterPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftKlarnaInappFlutterPlugin registerWithRegistrar:registrar];
}
@end
