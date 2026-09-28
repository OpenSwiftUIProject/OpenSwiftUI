//
//  OpenSwiftUIAccessibilityPrivate.h
//  COpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete

#ifndef OpenSwiftUIAccessibilityPrivate_h
#define OpenSwiftUIAccessibilityPrivate_h

#include "OpenSwiftUIBase.h"

#if OPENSWIFTUI_TARGET_OS_DARWIN

#import <Foundation/Foundation.h>
#if OPENSWIFTUI_TARGET_OS_OSX
#import <AppKit/AppKit.h>
#endif

OPENSWIFTUI_ASSUME_NONNULL_BEGIN

#if OPENSWIFTUI_TARGET_OS_OSX
typedef OPENSWIFTUI_ENUM(NSInteger, AXAttributeLockSource) {
    AXAttributeLockSourceNone = 0,
};
#endif

@interface NSObject (OpenSwiftUIAccessibilityPrivate)
+ (BOOL)_isFromOpenSwiftUI;
- (void)_performSelector:(SEL)selector withObject:(nullable id)object;

@property (nonatomic, nullable, copy) BOOL (^accessibilityOpenSwiftUIDefaultActionStoredBlock)(void);
@property (nonatomic, nullable, strong) id accessibilityOpenSwiftUIStoredLinkRotor;
@property (nonatomic, nullable, strong) id accessibilityNodeForPlatformElement;

#if OPENSWIFTUI_TARGET_OS_OSX
@property (nonatomic) BOOL _accessibilityAllowsAutomationElements;
- (AXAttributeLockSource)accessibilityLockSourceForAttribute:(NSAccessibilityAttributeName)attribute OPENSWIFTUI_SWIFT_NAME(accessibilityLockSource(for:));
- (void)setAccessibilityLockSource:(AXAttributeLockSource)source forAttribute:(NSAccessibilityAttributeName)attribute OPENSWIFTUI_SWIFT_NAME(setAccessibilityLockSource(_:for:));
#endif
@end

OPENSWIFTUI_ASSUME_NONNULL_END

#endif /* OPENSWIFTUI_TARGET_OS_DARWIN */

#endif /* OpenSwiftUIAccessibilityPrivate_h */
