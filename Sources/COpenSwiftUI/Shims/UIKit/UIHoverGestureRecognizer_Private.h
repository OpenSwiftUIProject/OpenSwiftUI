//
//  UIHoverGestureRecognizer_Private.h
//  COpenSwiftUI
//
//  Audited for iOS 18.5
//  Status: Complete

#ifndef UIHoverGestureRecognizer_Private_h
#define UIHoverGestureRecognizer_Private_h

#include "OpenSwiftUIBase.h"

#if __has_include(<UIKit/UIKit.h>)

#import <UIKit/UIKit.h>

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

@interface UIHoverGestureRecognizer (OpenSwiftUI_Private)

- (void)_hoverEntered:(NSSet<UITouch *> *)hoverEvents withEvent:(UIEvent *)event;
- (void)_hoverMoved:(NSSet<UITouch *> *)hoverEvents withEvent:(UIEvent *)event;
- (void)_hoverExited:(NSSet<UITouch *> *)hoverEvents withEvent:(UIEvent *)event;
- (void)_hoverCancelled:(NSSet<UITouch *> *)hoverEvents withEvent:(UIEvent *)event;

@end

NS_HEADER_AUDIT_END(nullability, sendability)

#endif /* __has_include(<UIKit/UIKit.h>) */

#endif /* UIHoverGestureRecognizer_Private_h */
