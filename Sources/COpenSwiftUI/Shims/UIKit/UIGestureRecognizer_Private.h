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

@protocol _UIGestureRecognizerContainer <NSObject>
@property (nonatomic, readonly) NSArray<UIGestureRecognizer *> *gestureRecognizers;
@property (nonatomic, readonly, nullable) id<_UIGestureRecognizerContainer> _parentGestureRecognizerContainer OPENSWIFTUI_SWIFT_NAME(_parentContainer);
@property (nonatomic, readonly) NSArray<id<_UIGestureRecognizerContainer>> *_childGestureRecognizerContainers OPENSWIFTUI_SWIFT_NAME(_childContainers);
@property (nonatomic, strong, nullable) id<_UIGestureRecognizerContainer> _actingParentGestureRecognizerContainer OPENSWIFTUI_SWIFT_NAME(_actingParentContainer);
@property (nonatomic, readonly, nullable) UIWindow *_eventReceivingWindow;
- (void)addGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer;
- (void)removeGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer;
- (NSComparisonResult)_compareGestureRecognizerContainer:(id<_UIGestureRecognizerContainer>)container;
@end

@interface UIView (OpenSwiftUI_GestureRecognizerContainer) <_UIGestureRecognizerContainer>
@end

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
    id<_UIGestureRecognizerContainer> gestureContainer,
    id<_UIGestureRecognizerContainer> otherContainer,
    BOOL usePresentationValues
) OPENSWIFTUI_SWIFT_NAME(_UIGestureRecognizerContainerCompare(_:_:_:));

OPENSWIFTUI_EXPORT
void OpenSwiftUIGestureRecognizerRegisterInContainer(UIGestureRecognizer *recognizer, id<_UIGestureRecognizerContainer> container) OPENSWIFTUI_SWIFT_NAME(_UIGestureRecognizerRegisterInContainer(_:_:));

OPENSWIFTUI_EXPORT
void OpenSwiftUIGestureRecognizerUnregisterFromContainer(UIGestureRecognizer *recognizer, id<_UIGestureRecognizerContainer> container) OPENSWIFTUI_SWIFT_NAME(_UIGestureRecognizerUnregisterFromContainer(_:_:));

OPENSWIFTUI_EXPORT
NSString *OpenSwiftUIGestureRecognizerContainerAncestralDescription(
    id<_UIGestureRecognizerContainer> container,
    NSString * _Nullable (^description)(id<_UIGestureRecognizerContainer>)
) OPENSWIFTUI_SWIFT_NAME(_UIGestureRecognizerContainerAncestralDescription(_:_:));

NS_HEADER_AUDIT_END(nullability, sendability)

#endif
#endif
