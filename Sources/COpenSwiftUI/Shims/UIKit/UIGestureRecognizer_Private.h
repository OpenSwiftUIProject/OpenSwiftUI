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
    shouldRequireFailureOfGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer;

- (BOOL)_gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
    shouldBeRequiredToFailByGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer;

- (BOOL)_gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer;

- (BOOL)_gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
    shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer;

- (BOOL)_gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
    shouldReceiveTouch:(UITouch *)touch;

- (BOOL)_gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
    shouldReceivePress:(UIPress *)press;

- (BOOL)_gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
    canPreventGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer;

- (BOOL)_gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
    canBePreventedByGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer;

- (BOOL)_gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
    shouldReceiveEvent:(UIEvent *)event;

- (BOOL)_gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
    canBeCancelledByGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer;

- (BOOL)_gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
    canCancelGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer;

@end

@interface UIGestureRecognizer (OpenSwiftUI_Private)

@property (nonatomic, readonly) BOOL _hasUnmetFailureRequirements;

- (BOOL)_isGestureType:(NSInteger)type;

- (NSUInteger)numberOfTapsRequired;

- (NSUInteger)numberOfTouchesRequired;

- (UIEventButtonMask)buttonMaskRequired;

- (void)_updateForActiveEvents;

- (void)_transformChangedWithEvent:(UITransformEvent *)event;

- (void)_scrollingChangedWithEvent:(UIScrollEvent *)event;

@end

OPENSWIFTUI_EXPORT
NSComparisonResult OpenSwiftUIGestureRecognizerContainerCompare(
    id gestureContainer,
    UIView *view,
    BOOL usePresentationValues
);

NS_HEADER_AUDIT_END(nullability, sendability)

#endif
#endif
