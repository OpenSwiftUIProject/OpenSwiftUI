//
//  UIUserInterfaceVibrancy.h
//  COpenSwiftUI

#include "OpenSwiftUIBase.h"

#if __has_include(<UIKit/UIKit.h>) && !__has_include(<UIKitPrivate/UIUserInterfaceVibrancy.h>)

#import <UIKit/UIKit.h>

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

typedef NS_ENUM(NSInteger, _UIUserInterfaceVibrancy) {
    _UIUserInterfaceVibrancyUnspecified = -1,
    _UIUserInterfaceVibrancyNone = 0,
    _UIUserInterfaceVibrancyVibrant = 1,
};

NS_HEADER_AUDIT_END(nullability, sendability)

#endif
