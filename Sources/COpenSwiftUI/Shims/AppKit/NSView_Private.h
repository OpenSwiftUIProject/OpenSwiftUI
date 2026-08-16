//
//  NSView_Private.h
//  OpenSwiftUI_SPI

#ifndef NSView_Private_h
#define NSView_Private_h

#include "OpenSwiftUIBase.h"

#if __has_include(<AppKit/AppKit.h>)

#include <AppKit/AppKit.h>

@interface NSView (OpenSwiftUI_SPI)
@property (getter=isOpaque) BOOL opaque;
@property (nonatomic, assign, readonly) NSEdgeInsets computedSafeAreaInsets;
@property (nonatomic) BOOL ignoreHitTest_openswiftui_safe_wrapper OPENSWIFTUI_SWIFT_NAME(ignoreHitTest);

- (nullable NSResponder *)_nextResponderForEvent:(nullable NSEvent *)event;
- (void)_updateLayerGeometryFromView;
- (void)_updateLayerShadowFromView;
- (void)_updateLayerShadowColorFromView;
@end

#endif /* __has_include(<AppKit/AppKit.h>) */

#endif /* NSView_Private_h */
