//
//  OpenSwiftUI+UIView.m
//  COpenSwiftUI

#import "OpenSwiftUI+UIView.h"

#if OPENSWIFTUI_TARGET_OS_IOS || OPENSWIFTUI_TARGET_OS_VISION

#include "Shims/UIKit/UIKit_Private.h"

UIView * _UIKitCreateCustomView(Class class, CALayer *layer) {
    return [[class alloc] _initWithLayer:layer];
}

#endif /* OPENSWIFTUI_TARGET_OS_IOS || OPENSWIFTUI_TARGET_OS_VISION */

