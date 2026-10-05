//
//  OpenSwiftUI+NSKeyedUnarchiver.m
//  COpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete

#import "OpenSwiftUI+NSKeyedUnarchiver.h"

#if OPENSWIFTUI_TARGET_OS_DARWIN

@implementation NSKeyedUnarchiver (OpenSwiftUI)
+ (NSObject * _Nullable)openswiftui_unarchiveTopLevelLNActionWithData:(NSData *)data
                                                             error:(NSError * _Nullable * _Nullable)error {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    return [self unarchiveTopLevelObjectWithData:data error:error];
#pragma clang diagnostic pop
}
@end

#endif /* OPENSWIFTUI_TARGET_OS_DARWIN */
