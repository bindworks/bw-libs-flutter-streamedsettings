#import "BwStreamedSettingsPlugin.h"
#if __has_include(<bw_streamed_settings/bw_streamed_settings-Swift.h>)
#import <bw_streamed_settings/bw_streamed_settings-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "bw_streamed_settings-Swift.h"
#endif

@implementation BwStreamedSettingsPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftBwStreamedSettingsPlugin registerWithRegistrar:registrar];
}
@end
