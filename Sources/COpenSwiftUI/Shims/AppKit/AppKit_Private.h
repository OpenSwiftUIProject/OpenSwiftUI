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

- (BOOL)_shouldLoadMainNibNamed:(nullable NSString *)name;
- (BOOL)_shouldLoadMainStoryboardNamed:(nullable NSString *)name;

- (void)markAppLaunchComplete_openswiftui_safe_wrapper OPENSWIFTUI_SWIFT_NAME(markAppLaunchComplete());

- (void)startedTest_openswiftui_safe_wrapper:(nullable NSString *)name OPENSWIFTUI_SWIFT_NAME(startedTest(_:));
- (void)finishedTest_openswiftui_safe_wrapper:(nullable NSString *)name extraResults:(nullable id)extraResults OPENSWIFTUI_SWIFT_NAME(finishedTest(_:extraResults:));
- (void)failedTest_openswiftui_safe_wrapper:(nullable NSString *)name withFailure:(nullable NSError*)failure OPENSWIFTUI_SWIFT_NAME(failedTest(_:withFailure:));
@end

typedef OPENSWIFTUI_ENUM(NSInteger, NSViewVibrantBlendingStyle) {
    NSViewVibrantBlendingStyle_0 = 0,
    NSViewVibrantBlendingStyle_1 = 1,
};

@interface NSView ()
@property (getter=isOpaque) BOOL opaque;
@property (nonatomic) BOOL ignoreHitTest;
- (void)_updateLayerGeometryFromView;
- (void)_updateLayerShadowFromView;
- (void)_updateLayerShadowColorFromView;
@end

@interface NSAppearance (OpenSwiftUI_SPI)
- (nullable NSAppearance *)appearanceByApplyingTintColor:(NSColor *)tintColor;
@end

@interface NSMenu (OpenSwiftUI_SPI)
+ (void)_setAlwaysCallDelegateBeforeSidebandUpdaters_openswiftui_safe_wrapper:(BOOL)value OPENSWIFTUI_SWIFT_NAME(_setAlwaysCallDelegateBeforeSidebandUpdaters(_:));
+ (void)_setAlwaysInstallWindowTabItems_openswiftui_safe_wrapper:(BOOL)value OPENSWIFTUI_SWIFT_NAME(_setAlwaysInstallWindowTabItems(_:));
@end

@interface NSDocumentController (OpenSwiftUI_SPI)
+ (void)_setUsingModernDocuments_openswiftui_safe_wrapper:(BOOL)value OPENSWIFTUI_SWIFT_NAME(_setUsingModernDocuments(_:));
@end

OPENSWIFTUI_ASSUME_NONNULL_END

#endif /* __has_include(<AppKit/AppKit.h>) */

#endif /* AppKit_Private_h */
