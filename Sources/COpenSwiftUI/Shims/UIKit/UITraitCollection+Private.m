//
//  UITraitCollection+Private.m
//  COpenSwiftUI
//
//  Status: Complete

#import "UITraitCollection+Private.h"
#import "Shims/OpenSwiftUIShims.h"

#if __has_include(<UIKit/UIKit.h>)
#import <objc/runtime.h>

@implementation UITraitCollection (OpenSwiftUI_Private)

- (UITraitCollection *)_traitCollectionByRemovingEnvironmentWrapper_openswiftui_safe_wrapper {
    OPENSWIFTUI_SAFE_WRAPPER_IMP(UITraitCollection *, @"_traitCollectionByRemovingEnvironmentWrapper", self);
    return func(self, selector);
}

- (_UIBacklightLuminance)_backlightLuminance_openswiftui_safe_wrapper {
    OPENSWIFTUI_SAFE_WRAPPER_IMP(_UIBacklightLuminance, @"_backlightLuminance", _UIBacklightLuminanceNormal);
    return func(self, selector);
}

- (NSInteger)_userInterfaceRenderingMode_openswiftui_safe_wrapper {
    OPENSWIFTUI_SAFE_WRAPPER_IMP(NSInteger, @"_userInterfaceRenderingMode", 0);
    return func(self, selector);
}

- (CGFloat)displayCornerRadius_openswiftui_safe_wrapper {
    OPENSWIFTUI_SAFE_WRAPPER_IMP(CGFloat, @"displayCornerRadius", 0.0);
    return func(self, selector);
}

- (_UIUserInterfaceVibrancy)_vibrancy_openswiftui_safe_wrapper {
    OPENSWIFTUI_SAFE_WRAPPER_IMP(_UIUserInterfaceVibrancy, @"_vibrancy", _UIUserInterfaceVibrancyUnspecified);
    return func(self, selector);
}

#if OPENSWIFTUI_LINK_BACKLIGHTSERVICES
- (BLSUpdateFidelity)_updateFidelity_openswiftui_safe_wrapper {
    OPENSWIFTUI_SAFE_WRAPPER_IMP(BLSUpdateFidelity, @"_updateFidelity", BLSUpdateFidelityUnspecified);
    return func(self, selector);
}
#endif

@end

#endif /* __has_include(<UIKit/UIKit.h>) */
