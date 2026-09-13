//
//  _UIHitTestContext.h
//  COpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete

#ifndef _UIHitTestContext_h
#define _UIHitTestContext_h

#include "OpenSwiftUIBase.h"
#include "UIGestureRecognizer_Private.h"

#if __has_include(<UIKit/UIKit.h>)

#import <UIKit/UIKit.h>

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

@interface _UIHitTestContext : NSObject
+ (instancetype)contextWithPoint:(CGPoint)point radius:(CGFloat)radius;
@property (nonatomic, readonly) CGFloat radius;
@end

@interface UIView (OpenSwiftUI_HitTesting)
- (nullable id<_UIGestureRecognizerContainer>)_hitTestWithContext:(_UIHitTestContext *)context;
@end

OPENSWIFTUI_EXPORT
_UIHitTestContext * _Nullable _UICurrentHitTestContext(void) OPENSWIFTUI_SWIFT_NAME(getter:_UIHitTestContext.current);

NS_HEADER_AUDIT_END(nullability, sendability)

#endif /* __has_include(<UIKit/UIKit.h>) */

#endif /* _UIHitTestContext_h */
