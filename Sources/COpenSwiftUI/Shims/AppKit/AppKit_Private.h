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

OPENSWIFTUI_EXTERN_C_BEGIN

OPENSWIFTUI_EXPORT
Class _Nullable AXNSTableViewCellMockElementClass(void);

OPENSWIFTUI_EXPORT
Class _Nullable AXNSTableRowClass(void);

OPENSWIFTUI_EXPORT
void NSAccessibilityBeginInternalAccessors(void);

OPENSWIFTUI_EXPORT
void NSAccessibilityEndInternalAccessors(void);

OPENSWIFTUI_EXPORT
id _Nullable NSAccessibilityEntryPointValueForAttribute(id element, NSAccessibilityAttributeName attribute);

OPENSWIFTUI_EXPORT
NSArray * _Nullable NSAccessibilityEntryPointActionNames(id element);

OPENSWIFTUI_EXPORT
NSString * _Nullable NSAccessibilityEntryPointActionDescription(id element, NSAccessibilityActionName action);

OPENSWIFTUI_EXPORT
BOOL NSAccessibilityEntryPointPerformAction(id element, NSAccessibilityActionName action);

OPENSWIFTUI_EXPORT
NSAccessibilityAttributeName const NSAccessibilityIsAccessibilityElementAttribute;

OPENSWIFTUI_EXPORT
NSAccessibilityAttributeName const NSAccessibilityAttributedUserInputLabelsAttribute;

OPENSWIFTUI_EXTERN_C_END

@interface NSObject (OpenSwiftUI_SPI)
- (BOOL)_accessibilitySetOverrideValue:(nullable id)value forAttribute:(NSAccessibilityAttributeName)attribute OPENSWIFTUI_SWIFT_NAME(_accessibilitySetOverrideValue(_:for:));
- (BOOL)_accessibilitySetOverrideHandler:(id _Nullable (^ _Nullable)(void))handler forAttribute:(NSAccessibilityAttributeName)attribute OPENSWIFTUI_SWIFT_NAME(_accessibilitySetOverrideHandler(_:for:));
@end

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

@interface NSAppearance (OpenSwiftUI_SPI)
- (nullable NSAppearance *)appearanceByApplyingTintColor:(NSColor *)tintColor;
@end

@interface NSProgressIndicator (OpenSwiftUI_SPI)
@property (nullable, strong) NSFont *font;
@end

@interface NSMenu (OpenSwiftUI_SPI)
+ (void)_setAlwaysCallDelegateBeforeSidebandUpdaters_openswiftui_safe_wrapper:(BOOL)value OPENSWIFTUI_SWIFT_NAME(_setAlwaysCallDelegateBeforeSidebandUpdaters(_:));
+ (void)_setAlwaysInstallWindowTabItems_openswiftui_safe_wrapper:(BOOL)value OPENSWIFTUI_SWIFT_NAME(_setAlwaysInstallWindowTabItems(_:));
@end

@interface NSDocumentController (OpenSwiftUI_SPI)
+ (void)_setUsingModernDocuments_openswiftui_safe_wrapper:(BOOL)value OPENSWIFTUI_SWIFT_NAME(_setUsingModernDocuments(_:));
@end

@interface NSImage (OpenSwiftUI_SPI)
@property (nullable, copy) NSString *_defaultAccessibilityDescription;
@end

@interface NSWorkspace (OpenSwiftUI_SPI)
@property (readonly, getter=isAccessibilityFullKeyboardAccessEnabled) BOOL accessibilityFullKeyboardAccessEnabled;
@end

@interface NSView (OpenSwiftUI_SPI)
- (nullable id)accessibilityFocusedUIElement;
@end

@interface NSAccessibilityRemoteUIElement : NSObject
+ (BOOL)isRemoteUIApp;
@end

@protocol NSWindowSwiftUIDelegate <NSObject>
@optional
- (nullable id)_accessibilityWindow:(NSWindow *)window focusedUIElementOverrideWithCurrentValue:(nullable id)currentValue;
@end

OPENSWIFTUI_ASSUME_NONNULL_END

#endif /* __has_include(<AppKit/AppKit.h>) */

#endif /* AppKit_Private_h */
