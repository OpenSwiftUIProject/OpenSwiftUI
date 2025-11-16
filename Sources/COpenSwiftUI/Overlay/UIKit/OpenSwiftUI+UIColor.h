//
//  OpenSwiftUI+UIColor.h
//  COpenSwiftUI
//
//  Audited for 6.0.87
//  Status: Complete

#ifndef OpenSwiftUI_UIColor_h
#define OpenSwiftUI_UIColor_h

#include "OpenSwiftUIBase.h"

#if OPENSWIFTUI_TARGET_OS_IOS || OPENSWIFTUI_TARGET_OS_VISION

#import <UIKit/UIKit.h>

OPENSWIFTUI_ASSUME_NONNULL_BEGIN

OPENSWIFTUI_EXPORT
BOOL _UIColorDependsOnTraitCollection(UIColor *color);

@interface UIColor (OpenSwiftUI)

// Workaround Swift initializer limitation
- (instancetype)initWithColor__openSwiftUI__:(UIColor *)color;

@end

OPENSWIFTUI_ASSUME_NONNULL_END

#endif /* OPENSWIFTUI_TARGET_OS_IOS || OPENSWIFTUI_TARGET_OS_VISION */

#endif /* OpenSwiftUI_UIColor_h */
