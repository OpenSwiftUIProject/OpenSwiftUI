//
//  UIBacklightLuminance.h
//  COpenSwiftUI

#include "OpenSwiftUIBase.h"

#if __has_include(<UIKit/UIKit.h>) & !__has_include(<UIKitPrivate/UIBacklightLuminance.h>)

#import <UIKit/UIKit.h>

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

typedef NS_ENUM(NSInteger, _UIBacklightLuminance) {
    _UIBacklightLuminanceNormal = 0,
    _UIBacklightLuminanceReduced = 1,
};

NS_HEADER_AUDIT_END(nullability, sendability)

#endif
