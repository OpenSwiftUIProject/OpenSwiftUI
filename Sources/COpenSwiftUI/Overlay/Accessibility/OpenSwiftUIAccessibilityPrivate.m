//
//  OpenSwiftUIAccessibilityPrivate.m
//  COpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete

#import "OpenSwiftUIAccessibilityPrivate.h"
#import "../Foundation/OpenSwiftUI+NSObject.h"

#if OPENSWIFTUI_TARGET_OS_DARWIN

#import <objc/runtime.h>

@implementation NSObject (OpenSwiftUIAccessibilityPrivate)
- (BOOL (^)(void))accessibilityOpenSwiftUIDefaultActionStoredBlock {
    return objc_getAssociatedObject(self, @selector(accessibilityOpenSwiftUIDefaultActionStoredBlock));
}

- (void)setAccessibilityOpenSwiftUIDefaultActionStoredBlock:(BOOL (^)(void))block {
    objc_setAssociatedObject(self, @selector(accessibilityOpenSwiftUIDefaultActionStoredBlock), block, OBJC_ASSOCIATION_COPY);
}

- (id)accessibilityOpenSwiftUIStoredLinkRotor {
    return objc_getAssociatedObject(self, @selector(accessibilityOpenSwiftUIStoredLinkRotor));
}

- (void)setAccessibilityOpenSwiftUIStoredLinkRotor:(id)rotor {
    objc_setAssociatedObject(self, @selector(accessibilityOpenSwiftUIStoredLinkRotor), rotor, OBJC_ASSOCIATION_RETAIN);
}

#if OPENSWIFTUI_TARGET_OS_OSX
- (AXAttributeLockSource)accessibilityLockSourceForAttribute:(NSAccessibilityAttributeName)attribute {
    NSDictionary<NSAccessibilityAttributeName, NSNumber *> *sources = objc_getAssociatedObject(self, @selector(accessibilityLockSourceForAttribute:));
    return [sources[attribute] integerValue];
}

- (void)setAccessibilityLockSource:(AXAttributeLockSource)source forAttribute:(NSAccessibilityAttributeName)attribute {
    NSMutableDictionary<NSAccessibilityAttributeName, NSNumber *> *sources = objc_getAssociatedObject(self, @selector(accessibilityLockSourceForAttribute:));
    if (sources == nil) {
        sources = [[NSMutableDictionary alloc] init];
        objc_setAssociatedObject(self, @selector(accessibilityLockSourceForAttribute:), sources, OBJC_ASSOCIATION_RETAIN);
    }
    sources[attribute] = @(source);
}

- (BOOL)_accessibilityAllowsAutomationElements {
    NSNumber *value = objc_getAssociatedObject(self, @selector(_accessibilityAllowsAutomationElements));
    return value.boolValue;
}

- (void)set_accessibilityAllowsAutomationElements:(BOOL)value {
    objc_setAssociatedObject(self, @selector(_accessibilityAllowsAutomationElements), @(value), OBJC_ASSOCIATION_RETAIN);
}
#endif
@end

#endif /* OPENSWIFTUI_TARGET_OS_DARWIN */
