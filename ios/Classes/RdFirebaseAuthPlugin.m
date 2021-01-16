#import "RdFirebaseAuthPlugin.h"
#if __has_include(<rd_firebase_auth/rd_firebase_auth-Swift.h>)
#import <rd_firebase_auth/rd_firebase_auth-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "rd_firebase_auth-Swift.h"
#endif

@implementation RdFirebaseAuthPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftRdFirebaseAuthPlugin registerWithRegistrar:registrar];
}
@end
