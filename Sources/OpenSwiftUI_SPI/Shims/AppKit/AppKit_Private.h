//
//  AppKit_Private.h
//  OpenSwiftUI_SPI
//
//  Status: WIP

#ifndef AppKit_Private_h
#define AppKit_Private_h

#include "OpenSwiftUIBase.h"

#if __has_include(<AppKit/AppKit.h>)

#import <AppKit/AppKit.h>

OPENSWIFTUI_ASSUME_NONNULL_BEGIN

@interface NSApplication (OpenSwiftUI_SPI)
- (void)startedTest_openswiftui_safe_wrapper:(nullable NSString *)name OPENSWIFTUI_SWIFT_NAME(startedTest(_:));
- (void)finishedTest_openswiftui_safe_wrapper:(nullable NSString *)name OPENSWIFTUI_SWIFT_NAME(finishedTest(_:));
- (void)failedTest_openswiftui_safe_wrapper:(nullable NSString *)name withFailure:(nullable NSError*)failure OPENSWIFTUI_SWIFT_NAME(failedTest(_:withFailure:));
@end

typedef OPENSWIFTUI_ENUM(NSInteger, NSViewVibrantBlendingStyle) {
    NSViewVibrantBlendingStyle_0 = 0,
    NSViewVibrantBlendingStyle_1 = 1,
};

@interface NSView ()
- (void)_updateLayerGeometryFromView;
@end

OPENSWIFTUI_ASSUME_NONNULL_END

#endif /* __has_include(<AppKit/AppKit.h>) */

#endif /* AppKit_Private_h */
