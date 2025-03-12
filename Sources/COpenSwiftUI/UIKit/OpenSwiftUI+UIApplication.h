//
//  OpenSwiftUI+UIApplication.h
//  COpenSwiftUI
//
//  Audited for iOS 18.0
//  Status: Complete

#ifndef OpenSwiftUI_UIApplication_h
#define OpenSwiftUI_UIApplication_h

#include "OpenSwiftUIBase.h"

#if OPENSWIFTUI_TARGET_OS_IOS

#import <UIKit/UIKit.h>

OPENSWIFTUI_ASSUME_NONNULL_BEGIN

OPENSWIFTUI_EXPORT
UIContentSizeCategory _UIApplicationDefaultContentSizeCategory();

OPENSWIFTUI_ASSUME_NONNULL_END

#endif /* OPENSWIFTUI_TARGET_OS_IOS */

#endif /* OpenSwiftUI_UIApplication_h */
