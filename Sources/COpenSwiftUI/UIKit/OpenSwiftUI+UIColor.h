//
//  OpenSwiftUI+UIColor.h
//  COpenSwiftUI
//
//  Audited for iOS 18.0
//  Status: Complete

#ifndef OpenSwiftUI_UIColor_h
#define OpenSwiftUI_UIColor_h

#include "OpenSwiftUIBase.h"

#if OPENSWIFTUI_TARGET_OS_IOS

#import <UIKit/UIKit.h>

OPENSWIFTUI_ASSUME_NONNULL_BEGIN

OPENSWIFTUI_EXPORT
BOOL _UIColorDependsOnTraitCollection(UIColor *color);

@interface UIColor (OpenSwiftUI)

// Workaround Swift initializer limitation
- (instancetype)initWithColor__openSwiftUI__:(UIColor *)color;

@end

OPENSWIFTUI_ASSUME_NONNULL_END

#endif /* OPENSWIFTUI_TARGET_OS_IOS */

#endif /* OpenSwiftUI_UIColor_h */
