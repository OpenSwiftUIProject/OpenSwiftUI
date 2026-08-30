//
//  UIGestureRecognizer_Private.h
//  COpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete

#ifndef UIGestureRecognizer_Private_h
#define UIGestureRecognizer_Private_h

#include "OpenSwiftUIBase.h"
#include "UIScrollEvent_Private.h"
#include "UITransformEvent_Private.h"

#if __has_include(<UIKit/UIKit.h>)

#import <UIKit/UIKit.h>

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

@protocol UIGestureRecognizerDelegatePrivate <UIGestureRecognizerDelegate>

@optional
- (BOOL)_gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
    canBeCancelledByGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer;

@end

@interface UIGestureRecognizer (OpenSwiftUI_Private)

@property (nonatomic, readonly) BOOL _hasUnmetFailureRequirements;

- (void)_updateForActiveEvents;

- (void)_transformChangedWithEvent:(UITransformEvent *)event;

- (void)_scrollingChangedWithEvent:(UIScrollEvent *)event;

@end

OPENSWIFTUI_EXPORT
NSInteger OpenSwiftUIGestureRecognizerContainerCompare(
    id gestureContainer,
    UIView *view,
    BOOL usePresentationValues
);

NS_HEADER_AUDIT_END(nullability, sendability)

#endif
#endif
