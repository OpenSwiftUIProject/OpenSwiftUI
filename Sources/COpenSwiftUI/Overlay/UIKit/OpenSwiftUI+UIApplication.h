//
//  OpenSwiftUI+UIApplication.h
//  COpenSwiftUI
//
//  Audited for 6.0.87
//  Status: Complete

#ifndef OpenSwiftUI_UIApplication_h
#define OpenSwiftUI_UIApplication_h

#include "OpenSwiftUIBase.h"

#if OPENSWIFTUI_TARGET_OS_IOS || OPENSWIFTUI_TARGET_OS_VISION

#import <UIKit/UIKit.h>

OPENSWIFTUI_ASSUME_NONNULL_BEGIN

OPENSWIFTUI_EXPORT
UIContentSizeCategory _UIApplicationDefaultContentSizeCategory();

OPENSWIFTUI_ASSUME_NONNULL_END

#endif /* OPENSWIFTUI_TARGET_OS_IOS || OPENSWIFTUI_TARGET_OS_VISION */

#endif /* OpenSwiftUI_UIApplication_h */
