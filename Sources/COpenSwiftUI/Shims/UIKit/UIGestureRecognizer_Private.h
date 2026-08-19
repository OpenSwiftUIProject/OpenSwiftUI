//
//  UIGestureRecognizer_Private.h
//  COpenSwiftUI
//
//  Audited for iOS 18.5
//  Status: Complete

#ifndef UIGestureRecognizer_Private_h
#define UIGestureRecognizer_Private_h

#include "OpenSwiftUIBase.h"

#if __has_include(<UIKit/UIKit.h>)

#import <UIKit/UIKit.h>

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

@interface UIGestureRecognizer (OpenSwiftUI_Private)

@property (nonatomic, readonly) BOOL _hasUnmetFailureRequirements;

@end

NS_HEADER_AUDIT_END(nullability, sendability)

#endif
#endif
