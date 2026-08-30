//
//  UITransformEvent_Private.h
//  COpenSwiftUI
//
//  Audited for iOS 18.5
//  Status: Complete

#ifndef UITransformEvent_Private_h
#define UITransformEvent_Private_h

#include "OpenSwiftUIBase.h"

#if __has_include(<UIKit/UIKit.h>)

#import <UIKit/UIKit.h>

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

typedef NS_ENUM(NSInteger, UITransformPhase) {
    UITransformPhaseBegan = 1,
    UITransformPhaseActive = 2,
    UITransformPhaseEnded = 3,
    UITransformPhaseFailed = 4,
};

@interface UITransformEvent : UIEvent

@property (nonatomic, readonly) UITransformPhase phase;
@property (nonatomic, readonly) CGFloat scale;
@property (nonatomic, readonly) CGFloat rotation;

- (CGPoint)locationInView:(nullable UIView *)view;

@end

NS_HEADER_AUDIT_END(nullability, sendability)

#endif
#endif
