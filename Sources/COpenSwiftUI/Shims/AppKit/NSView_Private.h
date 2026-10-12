//
//  NSView_Private.h
//  OpenSwiftUI_SPI

#ifndef NSView_Private_h
#define NSView_Private_h

#include "OpenSwiftUIBase.h"

#if __has_include(<AppKit/AppKit.h>)

#include <AppKit/AppKit.h>
#include "_NSConstraintBasedLayoutHostingView.h"

@protocol NSContentStyle <NSObject, NSCopying>
@property (nullable, readonly) NSColor *equivalentForegroundColorForTemplateImage;
@property (readonly) int outputBlendModeForTemplateContent;
@end

@interface NSView (OpenSwiftUI_SPI)
@property (getter=isOpaque) BOOL opaque;
@property (nonatomic, assign, readonly) NSEdgeInsets computedSafeAreaInsets;
@property (nonatomic) BOOL ignoreHitTest_openswiftui_safe_wrapper OPENSWIFTUI_SWIFT_NAME(ignoreHitTest);
@property (nullable, copy) id<NSContentStyle> contentStyle;
@property NSUserInterfaceLayoutDirection userInterfaceLayoutDirection;

- (BOOL)_userInterfaceLayoutDirectionPropagatesToDescendants;
- (void)_setUserInterfaceLayoutDirectionPropagatesToDescendants:(BOOL)propagates;
- (void)_setVibrantBlendingStyleForSubtree:(NSUInteger)style;

- (BaselineOffset)_baselineOffsetsAtSize:(CGSize)size;
- (nullable NSView *)designatedFocusRingView OPENSWIFTUI_SWIFT_NAME(designatedFocusRing());

- (nullable NSResponder *)_nextResponderForEvent:(nullable NSEvent *)event;
- (nonnull id)_observerForChangesInGeometryInWindow:(void (^ _Nonnull)(NSView * _Nonnull view))block;
- (void)_updateLayerGeometryFromView;
- (void)_updateLayerShadowFromView;
- (void)_updateLayerShadowColorFromView;

- (void)measureMin:(CGSize * _Nonnull)min
               max:(CGSize * _Nonnull)max
             ideal:(CGSize * _Nonnull)ideal;
- (void)measureMin:(CGSize * _Nonnull)min
               max:(CGSize * _Nonnull)max
             ideal:(CGSize * _Nonnull)ideal
stretchingPriority:(float)stretchingPriority;
@end

#endif /* __has_include(<AppKit/AppKit.h>) */

#endif /* NSView_Private_h */
