//
//  UITraitCollection+Private.h
//  COpenSwiftUI
//
//  Status: Complete

#ifndef UITraitCollection_Private_h
#define UITraitCollection_Private_h

#include "OpenSwiftUIBase.h"

#if __has_include(<UIKit/UIKit.h>)

#import <UIKit/UIKit.h>
#include "Shims/UIKit/UIUserInterfaceVibrancy.h"
#include "Shims/UIKit/UIBacklightLuminance.h"

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

@interface UITraitCollection (OpenSwiftUI_Private)

@property (nonatomic, readonly) UITraitCollection *_traitCollectionByRemovingEnvironmentWrapper_openswiftui_safe_wrapper OPENSWIFTUI_SWIFT_NAME(_traitCollectionByRemovingEnvironmentWrapper);
@property (nonatomic, readonly) _UIBacklightLuminance _backlightLuminance_openswiftui_safe_wrapper OPENSWIFTUI_SWIFT_NAME(_backlightLuminance);
@property (nonatomic, readonly) NSInteger _userInterfaceRenderingMode_openswiftui_safe_wrapper OPENSWIFTUI_SWIFT_NAME(_userInterfaceRenderingMode);
@property (nonatomic, readonly) CGFloat _displayCornerRadius_openswiftui_safe_wrapper OPENSWIFTUI_SWIFT_NAME(_displayCornerRadius);
@property (nonatomic, readonly) _UIUserInterfaceVibrancy _vibrancy_openswiftui_safe_wrapper OPENSWIFTUI_SWIFT_NAME(_vibrancy);

@end

NS_HEADER_AUDIT_END(nullability, sendability)

#endif /* __has_include(<UIKit/UIKit.h>) */

#endif /* UITraitCollection_Private_h */
