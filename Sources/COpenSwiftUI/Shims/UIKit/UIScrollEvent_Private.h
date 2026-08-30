//
//  UIScrollEvent_Private.h
//  COpenSwiftUI
//
//  Audited for iOS 18.5
//  Status: Complete

#ifndef UIScrollEvent_Private_h
#define UIScrollEvent_Private_h

#include "OpenSwiftUIBase.h"

#if __has_include(<UIKit/UIKit.h>)

#import <UIKit/UIKit.h>

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

@interface UIScrollEvent : UIEvent

@property (nonatomic, readonly) NSUInteger phase;

- (CGPoint)locationInView:(nullable UIView *)view;
- (CGVector)_adjustedAcceleratedDeltaInView:(nullable UIView *)view;

@end

NS_HEADER_AUDIT_END(nullability, sendability)

#endif
#endif
