//
//  OpenSwiftUICoreViewFunctions.h
//  OpenSwiftUI_SPI
//
//  Status: Complete
//  Audited for 6.5.4

#ifndef OpenSwiftUICoreViewFunctions_h
#define OpenSwiftUICoreViewFunctions_h

#include "OpenSwiftUIBase.h"

#if OPENSWIFTUI_TARGET_OS_DARWIN

#include "OpenSwiftUIViewSystem.h"
#include <QuartzCore/QuartzCore.h>

OPENSWIFTUI_ASSUME_NONNULL_BEGIN

@interface NSObject (OpenSwiftUICore_Additions)
- (void)openswiftui_insertRenderedSubview:(id)subview atIndex:(NSInteger)index;
- (void)openswiftui_addRenderedSubview:(id)subview positioned:(NSInteger)place relativeTo:(nullable id)otherView;
@end

// MARK: - System Resolution

OpenSwiftUIViewSystem OpenSwiftUICoreViewResolvedSystem(OpenSwiftUIViewSystem system, id view) OPENSWIFTUI_SWIFT_NAME(CoreViewResolvedSystem(system:view:));

// MARK: - Layer Access

CALayer * OpenSwiftUICoreViewLayer(OpenSwiftUIViewSystem system, id view) OPENSWIFTUI_SWIFT_NAME(CoreViewLayer(system:view:));

CALayer * _Nullable OpenSwiftUICoreViewSpeculativeLayer(id view) OPENSWIFTUI_SWIFT_NAME(CoreViewSpeculativeLayer(view:));

// MARK: - Subview Management

void OpenSwiftUICoreViewAddSubview(OpenSwiftUIViewSystem system, id parent, id child, NSUInteger index) OPENSWIFTUI_SWIFT_NAME(CoreViewAddSubview(system:parent:child:index:));

void OpenSwiftUICoreViewRemoveFromSuperview(OpenSwiftUIViewSystem system, id view) OPENSWIFTUI_SWIFT_NAME(CoreViewRemoveFromSuperview(system:view:));

NSArray * OpenSwiftUICoreViewSubviews(OpenSwiftUIViewSystem system, id view) OPENSWIFTUI_SWIFT_NAME(CoreViewSubviews(system:view:));

id _Nullable OpenSwiftUICoreViewMaskView(OpenSwiftUIViewSystem system, id view) OPENSWIFTUI_SWIFT_NAME(CoreViewMaskView(system:view:));

// MARK: - Display

void OpenSwiftUICoreViewSetNeedsDisplay(OpenSwiftUIViewSystem system, id view) OPENSWIFTUI_SWIFT_NAME(CoreViewSetNeedsDisplay(system:view:));

void OpenSwiftUICoreViewDisplayIgnoringOpacity(OpenSwiftUIViewSystem system, id view, CGContextRef context) OPENSWIFTUI_SWIFT_NAME(CoreViewDisplayIgnoringOpacity(system:view:context:));

// MARK: - Appearance

void OpenSwiftUICoreViewSetOpacity(OpenSwiftUIViewSystem system, id view, CGFloat opacity) OPENSWIFTUI_SWIFT_NAME(CoreViewSetOpacity(system:view:opacity:));

void OpenSwiftUICoreViewSetClipsToBounds(OpenSwiftUIViewSystem system, id view, BOOL clips, BOOL onLayer) OPENSWIFTUI_SWIFT_NAME(CoreViewSetClipsToBounds(system:view:clips:onLayer:));

void OpenSwiftUICoreViewSetTransform(OpenSwiftUIViewSystem system, id view, CGAffineTransform transform) OPENSWIFTUI_SWIFT_NAME(CoreViewSetTransform(system:view:transform:));

// MARK: - Geometry

void OpenSwiftUICoreViewSetSize(OpenSwiftUIViewSystem system, id view, CGSize size) OPENSWIFTUI_SWIFT_NAME(CoreViewSetSize(system:view:size:));

CGRect OpenSwiftUICoreViewGetFrame(OpenSwiftUIViewSystem system, id view) OPENSWIFTUI_SWIFT_NAME(CoreViewGetFrame(system:view:));

void OpenSwiftUICoreViewSetFrame(OpenSwiftUIViewSystem system, id view, CGRect frame) OPENSWIFTUI_SWIFT_NAME(CoreViewSetFrame(system:view:frame:));

void OpenSwiftUICoreViewSetGeometry(
    OpenSwiftUIViewSystem system, id view,
    BOOL useViewAPIs, BOOL positionChanged,
    BOOL boundsOriginChanged, BOOL boundsSizeChanged,
    CGPoint position, CGRect bounds
) OPENSWIFTUI_SWIFT_NAME(CoreViewSetGeometry(system:view:useViewAPIs:positionChanged:boundsOriginChanged:boundsSizeChanged:position:bounds:));

void OpenSwiftUICoreViewSetMaskGeometry(
    OpenSwiftUIViewSystem system, id view,
    CGRect bounds
) OPENSWIFTUI_SWIFT_NAME(CoreViewSetMaskGeometry(system:view:bounds:));

// MARK: - Filters and Shadow

void OpenSwiftUICoreViewSetCompositingFilter(OpenSwiftUIViewSystem system, id view, id _Nullable filter) OPENSWIFTUI_SWIFT_NAME(CoreViewSetCompositingFilter(system:view:filter:));

void OpenSwiftUICoreViewSetFilters(OpenSwiftUIViewSystem system, id view, NSArray * _Nullable filters) OPENSWIFTUI_SWIFT_NAME(CoreViewSetFilters(system:view:filters:));

void OpenSwiftUICoreViewSetShadow(
    OpenSwiftUIViewSystem system, id view,
    CGColorRef _Nullable color, CGFloat radius,
    CGSize offset
) OPENSWIFTUI_SWIFT_NAME(CoreViewSetShadow(system:view:color:radius:offset:));

#if OPENSWIFTUI_TARGET_OS_IOS || OPENSWIFTUI_TARGET_OS_VISION

// MARK: - Intelligence Light Source

id _Nullable OpenSwiftUICoreViewMakeIntelligenceLightSourceView(BOOL reactive) OPENSWIFTUI_SWIFT_NAME(CoreViewMakeIntelligenceLightSourceView(reactive:));

void OpenSwiftUICoreViewUpdateIntelligenceLightSourceView(id view, BOOL reactive) OPENSWIFTUI_SWIFT_NAME(CoreViewUpdateIntelligenceLightSourceView(view:reactive:));

#endif /* OPENSWIFTUI_TARGET_OS_IOS || OPENSWIFTUI_TARGET_OS_VISION */

OPENSWIFTUI_ASSUME_NONNULL_END

#endif /* OPENSWIFTUI_TARGET_OS_DARWIN */

#endif /* OpenSwiftUICoreViewFunctions_h */
