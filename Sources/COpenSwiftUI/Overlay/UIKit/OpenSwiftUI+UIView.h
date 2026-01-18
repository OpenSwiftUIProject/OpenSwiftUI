//
//  OpenSwiftUI+UIView.h
//  COpenSwiftUI

#ifndef OpenSwiftUI_UIView_h
#define OpenSwiftUI_UIView_h

#include "OpenSwiftUIBase.h"

#if OPENSWIFTUI_TARGET_OS_IOS || OPENSWIFTUI_TARGET_OS_VISION

#import <UIKit/UIKit.h>

OPENSWIFTUI_ASSUME_NONNULL_BEGIN

UIView * _UIKitCreateCustomView(Class class, CALayer *layer);

OPENSWIFTUI_ASSUME_NONNULL_END

#endif /* OPENSWIFTUI_TARGET_OS_IOS || OPENSWIFTUI_TARGET_OS_VISION */

#endif /* OpenSwiftUI_UIView_h */

