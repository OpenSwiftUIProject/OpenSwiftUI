//
//  CoreViewFunctions.m
//  OpenSwiftUI_SPI
//
//  Status: Complete
//  Audited for 6.5.4

#include "CoreViewFunctions.h"
#include "UIKitSubviews.h"
#include "AppKitSubviews.h"

#if OPENSWIFTUI_TARGET_OS_DARWIN

#if OPENSWIFTUI_TARGET_OS_IOS || OPENSWIFTUI_TARGET_OS_VISION
#include <UIKit/UIKit.h>
#else
#include <AppKit/AppKit.h>
#endif

// MARK: - NSObject (OpenSwiftUICore_Additions)

@interface NSObject ()
- (void)insertSubview:(id)view atIndex:(NSInteger)index;
- (void)addSubview:(id)view positioned:(NSInteger)place relativeTo:(nullable id)otherView;
@end

@implementation NSObject (OpenSwiftUICore_Additions)
- (void)openswiftui_insertRenderedSubview:(id)subview atIndex:(NSInteger)index {
    [self insertSubview:subview atIndex:index];
}
- (void)openswiftui_addRenderedSubview:(id)subview positioned:(NSInteger)place relativeTo:(id _Nullable)otherView {
    [self addSubview:subview positioned:place relativeTo:otherView];
}
@end

// MARK: - Private API Forward Declarations

#if OPENSWIFTUI_TARGET_OS_IOS || OPENSWIFTUI_TARGET_OS_VISION
@interface NSObject (OpenSwiftUICoreViewIntelligenceEffect)
+ (id)sharedLight;
+ (id)sharedReactiveLight;
- (instancetype)initWithLightSource:(id)lightSource;
- (void)setBackgroundEffects:(NSArray *)effects;
@end
#endif

#if OPENSWIFTUI_TARGET_OS_OSX
@interface NSView (OpenSwiftUICoreViewPrivate)
- (id)maskView;
- (void)setFrameTransform:(CGAffineTransform)transform;
@end
#endif

// MARK: - System Resolution

OpenSwiftUIViewSystem OpenSwiftUICoreViewResolvedSystem(OpenSwiftUIViewSystem system, id view) {
    #if OPENSWIFTUI_TARGET_OS_OSX
    if (system == OpenSwiftUIViewSystemNSView) {
        Class nsViewClass = NSClassFromString(@"NSView");
        if (nsViewClass != nil) {
            [view isKindOfClass:nsViewClass];
        }
    }
    #endif
    return system;
}

// MARK: - Layer Access

CALayer * _Nullable OpenSwiftUICoreViewSpeculativeLayer(id view) {
    if ([view isKindOfClass:[CALayer class]]) {
        return (CALayer *)view;
    }
    Class uiViewClass = NSClassFromString(@"UIView");
    if (uiViewClass != nil && [view isKindOfClass:uiViewClass]) {
        return [view layer];
    }
    Class nsViewClass = NSClassFromString(@"NSView");
    if (nsViewClass != nil && [view isKindOfClass:nsViewClass]) {
        return [view layer];
    }
    return nil;
}

CALayer * OpenSwiftUICoreViewLayer(OpenSwiftUIViewSystem system, id view) {
    if (system == OpenSwiftUIViewSystemCALayer) {
        return view;
    } else {
        return [view layer];
    }
}

// MARK: - Subview Management

void OpenSwiftUICoreViewAddSubview(OpenSwiftUIViewSystem system, id parent, id child, NSUInteger index) {
    switch (system) {
#if OPENSWIFTUI_TARGET_OS_IOS || OPENSWIFTUI_TARGET_OS_VISION
        case OpenSwiftUIViewSystemUIView:
            _UIKitAddSubview(child, parent, index);
            break;
#endif
#if OPENSWIFTUI_TARGET_OS_OSX
        case OpenSwiftUIViewSystemNSView:
            _AppKitAddSubview(child, parent, index);
            break;
#endif
        case OpenSwiftUIViewSystemCALayer:
            [(CALayer *)parent insertSublayer:(CALayer *)child atIndex:(unsigned int)index];
            break;
        default:
            break;
    }
}

void OpenSwiftUICoreViewRemoveFromSuperview(OpenSwiftUIViewSystem system, id view) {
    if (system == OpenSwiftUIViewSystemCALayer) {
        [(CALayer *)view removeFromSuperlayer];
    } else {
        [view removeFromSuperview];
    }
}

NSArray * OpenSwiftUICoreViewSubviews(OpenSwiftUIViewSystem system, id view) {
    if (system == OpenSwiftUIViewSystemCALayer) {
        return [NSArray arrayWithArray:[(CALayer *)view sublayers]];
    } else {
        return [view subviews];
    }
}

id _Nullable OpenSwiftUICoreViewMaskView(OpenSwiftUIViewSystem system, id view) {
    if (system == OpenSwiftUIViewSystemCALayer) {
        return [(CALayer *)view mask];
    }
#if OPENSWIFTUI_TARGET_OS_IOS || OPENSWIFTUI_TARGET_OS_VISION
    if (system == OpenSwiftUIViewSystemUIView) {
        return [(UIView *)view maskView];
    }
#endif
#if OPENSWIFTUI_TARGET_OS_OSX
    if (system == OpenSwiftUIViewSystemNSView) {
        return [(NSView *)view maskView];
    }
#endif
    return nil;
}

// MARK: - Display

void OpenSwiftUICoreViewSetNeedsDisplay(OpenSwiftUIViewSystem system, id view) {
#if OPENSWIFTUI_TARGET_OS_OSX
    if (system == OpenSwiftUIViewSystemNSView) {
        [(NSView *)view setNeedsDisplay:YES];
    } else if (system == OpenSwiftUIViewSystemCALayer) {
        [view setNeedsDisplay];
    }
#else
    if (system != OpenSwiftUIViewSystemNSView) {
        [view setNeedsDisplay];
    }
#endif
}

void OpenSwiftUICoreViewDisplayIgnoringOpacity(OpenSwiftUIViewSystem system, id view, CGContextRef context) {
#if OPENSWIFTUI_TARGET_OS_OSX
    if (system == OpenSwiftUIViewSystemNSView) {
        Class cls = NSClassFromString(@"NSGraphicsContext");
        if (cls != nil) {
            NSGraphicsContext *gc = [cls graphicsContextWithCGContext:context flipped:YES];
            NSRect bounds = [(NSView *)view bounds];
            [(NSView *)view displayRectIgnoringOpacity:bounds inContext:gc];
        }
    }
#endif
}

// MARK: - Appearance

void OpenSwiftUICoreViewSetOpacity(OpenSwiftUIViewSystem system, id view, CGFloat opacity) {
    if (system == OpenSwiftUIViewSystemCALayer) {
        [(CALayer *)view setOpacity:(float)opacity];
    }
#if OPENSWIFTUI_TARGET_OS_IOS || OPENSWIFTUI_TARGET_OS_VISION
    else if (system == OpenSwiftUIViewSystemUIView) {
        [(UIView *)view setAlpha:opacity];
    }
#endif
#if OPENSWIFTUI_TARGET_OS_OSX
    else if (system == OpenSwiftUIViewSystemNSView) {
        [(NSView *)view setAlphaValue:opacity];
    }
#endif
}

void OpenSwiftUICoreViewSetClipsToBounds(OpenSwiftUIViewSystem system, id view, BOOL clips, BOOL onLayer) {
#if OPENSWIFTUI_TARGET_OS_IOS || OPENSWIFTUI_TARGET_OS_VISION
    if (system == OpenSwiftUIViewSystemUIView && !onLayer) {
        [(UIView *)view setClipsToBounds:clips];
        return;
    }
#endif
    if (system == OpenSwiftUIViewSystemCALayer) {
        [(CALayer *)view setMasksToBounds:clips];
    } else {
        [[view layer] setMasksToBounds:clips];
    }
}

void OpenSwiftUICoreViewSetTransform(OpenSwiftUIViewSystem system, id view, CGAffineTransform transform) {
    if (system == OpenSwiftUIViewSystemCALayer) {
        [(CALayer *)view setAffineTransform:transform];
    }
#if OPENSWIFTUI_TARGET_OS_IOS || OPENSWIFTUI_TARGET_OS_VISION
    else if (system == OpenSwiftUIViewSystemUIView) {
        [(UIView *)view setTransform:transform];
    }
#endif
#if OPENSWIFTUI_TARGET_OS_OSX
    else if (system == OpenSwiftUIViewSystemNSView) {
        [(NSView *)view setFrameTransform:transform];
    }
#endif
}

// MARK: - Geometry

void OpenSwiftUICoreViewSetSize(OpenSwiftUIViewSystem system, id view, CGFloat width, CGFloat height) {
#if OPENSWIFTUI_TARGET_OS_OSX
    if (system == OpenSwiftUIViewSystemNSView) {
        [(NSView *)view setFrameSize:NSMakeSize(width, height)];
    } else if (system == OpenSwiftUIViewSystemCALayer || system == OpenSwiftUIViewSystemUIView) {
        CGRect bounds = [view bounds];
        bounds.size.width = width;
        bounds.size.height = height;
        [view setBounds:bounds];
    }
#else
    if (system != OpenSwiftUIViewSystemNSView) {
        CGRect bounds = [view bounds];
        bounds.size.width = width;
        bounds.size.height = height;
        [view setBounds:bounds];
    }
#endif
}

CGRect OpenSwiftUICoreViewGetFrame(OpenSwiftUIViewSystem system, id view) {
    return [view frame];
}

void OpenSwiftUICoreViewSetFrame(OpenSwiftUIViewSystem system, id view, CGRect frame) {
    [view setFrame:frame];
}

void OpenSwiftUICoreViewSetGeometry(
    OpenSwiftUIViewSystem system, id view,
    BOOL useViewAPIs, BOOL positionChanged,
    BOOL boundsOriginChanged, BOOL boundsSizeChanged,
    CGPoint position, CGRect bounds
) {
    if (system == OpenSwiftUIViewSystemCALayer) {
        if (positionChanged) {
            [(CALayer *)view setPosition:position];
        }
        if (boundsOriginChanged || boundsSizeChanged) {
            [(CALayer *)view setBounds:bounds];
        }
        return;
    }

#if OPENSWIFTUI_TARGET_OS_OSX
    if (system == OpenSwiftUIViewSystemNSView) {
        if (positionChanged && boundsSizeChanged) {
            [(NSView *)view setFrame:CGRectMake(position.x, position.y, bounds.size.width, bounds.size.height)];
        } else {
            if (positionChanged) {
                [(NSView *)view setFrameOrigin:position];
            }
            if (boundsSizeChanged) {
                [(NSView *)view setFrameSize:bounds.size];
            }
        }
        if (boundsOriginChanged) {
            [(NSView *)view setBoundsOrigin:bounds.origin];
        }
        return;
    }
#endif

#if OPENSWIFTUI_TARGET_OS_IOS || OPENSWIFTUI_TARGET_OS_VISION
    if (system == OpenSwiftUIViewSystemUIView) {
        if (useViewAPIs) {
            if (boundsOriginChanged) {
                __builtin_trap();
            }
            if (positionChanged) {
                [(UIView *)view setCenter:position];
            }
            if (boundsSizeChanged) {
                CGRect currentBounds = [(UIView *)view bounds];
                currentBounds.size = bounds.size;
                [(UIView *)view setBounds:currentBounds];
            }
        } else {
            CALayer *layer = [(UIView *)view layer];
            if (positionChanged) {
                [layer setPosition:position];
            }
            if (boundsOriginChanged || boundsSizeChanged) {
                [layer setBounds:bounds];
            }
        }
    }
#endif
}

void OpenSwiftUICoreViewSetMaskGeometry(
    OpenSwiftUIViewSystem system, id view,
    CGRect bounds
) {
    id maskObj = nil;
    if (system == OpenSwiftUIViewSystemCALayer) {
        maskObj = [(CALayer *)view mask];
    }
#if OPENSWIFTUI_TARGET_OS_IOS || OPENSWIFTUI_TARGET_OS_VISION
    else if (system == OpenSwiftUIViewSystemUIView) {
        maskObj = [(UIView *)view maskView];
    }
#endif
#if OPENSWIFTUI_TARGET_OS_OSX
    else if (system == OpenSwiftUIViewSystemNSView) {
        maskObj = [(NSView *)view maskView];
    }
#endif

    if (maskObj == nil) {
        return;
    }

    if (system == OpenSwiftUIViewSystemCALayer) {
        CGRect parentFrame = [view frame];
        [(CALayer *)maskObj setFrame:parentFrame];
    }
#if OPENSWIFTUI_TARGET_OS_IOS || OPENSWIFTUI_TARGET_OS_VISION
    else if (system == OpenSwiftUIViewSystemUIView) {
        [(UIView *)maskObj setCenter:bounds.origin];
    }
#endif
#if OPENSWIFTUI_TARGET_OS_OSX
    else if (system == OpenSwiftUIViewSystemNSView) {
        [(NSView *)maskObj setFrame:CGRectMake(bounds.origin.x, bounds.origin.y, bounds.size.width, bounds.size.height)];
        [(NSView *)maskObj setBoundsOrigin:bounds.origin];
    }
#endif

    [maskObj setBounds:bounds];
}

// MARK: - Filters and Shadow

void OpenSwiftUICoreViewSetCompositingFilter(OpenSwiftUIViewSystem system, id view, id _Nullable filter) {
    if (system == OpenSwiftUIViewSystemCALayer) {
        [(CALayer *)view setCompositingFilter:filter];
    }
#if OPENSWIFTUI_TARGET_OS_IOS || OPENSWIFTUI_TARGET_OS_VISION
    else if (system == OpenSwiftUIViewSystemUIView) {
        [[(UIView *)view layer] setCompositingFilter:filter];
    }
#endif
#if OPENSWIFTUI_TARGET_OS_OSX
    else if (system == OpenSwiftUIViewSystemNSView) {
        [[(NSView *)view layer] setCompositingFilter:filter];
    }
#endif
}

void OpenSwiftUICoreViewSetFilters(OpenSwiftUIViewSystem system, id view, NSArray * _Nullable filters) {
    if (system == OpenSwiftUIViewSystemCALayer) {
        [(CALayer *)view setFilters:filters];
    }
#if OPENSWIFTUI_TARGET_OS_IOS || OPENSWIFTUI_TARGET_OS_VISION
    else if (system == OpenSwiftUIViewSystemUIView) {
        [[(UIView *)view layer] setFilters:filters];
    }
#endif
#if OPENSWIFTUI_TARGET_OS_OSX
    else if (system == OpenSwiftUIViewSystemNSView) {
        [(NSView *)view setContentFilters:filters];
    }
#endif
}

void OpenSwiftUICoreViewSetShadow(
    OpenSwiftUIViewSystem system, id view,
    CGColorRef _Nullable color, CGFloat radius,
    CGFloat offsetWidth, CGFloat offsetHeight
) {
#if OPENSWIFTUI_TARGET_OS_OSX
    if (system == OpenSwiftUIViewSystemNSView) {
        if (color != NULL) {
            static Class nsShadowClass = nil;
            static Class nsColorClass = nil;
            static dispatch_once_t once;
            dispatch_once(&once, ^{
                nsShadowClass = NSClassFromString(@"NSShadow");
                nsColorClass = NSClassFromString(@"NSColor");
            });
            NSShadow *shadow = nil;
            if (nsShadowClass != nil && nsColorClass != nil) {
                shadow = [[nsShadowClass alloc] init];
                [shadow setShadowColor:[nsColorClass colorWithCGColor:color]];
                [shadow setShadowBlurRadius:radius];
                [shadow setShadowOffset:CGSizeMake(offsetWidth, offsetHeight)];
            }
            [(NSView *)view setShadow:shadow];
        } else {
            [(NSView *)view setShadow:nil];
        }
        return;
    }
#endif

    CALayer *layer;
    if (system == OpenSwiftUIViewSystemCALayer) {
        layer = (CALayer *)view;
    }
#if OPENSWIFTUI_TARGET_OS_IOS || OPENSWIFTUI_TARGET_OS_VISION
    else if (system == OpenSwiftUIViewSystemUIView) {
        layer = [(UIView *)view layer];
    }
#endif
    else {
        return;
    }

    if (color != NULL) {
        [layer setShadowOpacity:1.0f];
        [layer setShadowColor:color];
        [layer setShadowRadius:radius];
        [layer setShadowOffset:CGSizeMake(offsetWidth, offsetHeight)];
    } else {
        [layer setShadowOpacity:0.0f];
    }
}

// MARK: - Intelligence Light Source

#if OPENSWIFTUI_TARGET_OS_IOS || OPENSWIFTUI_TARGET_OS_VISION

id _Nullable OpenSwiftUICoreViewMakeIntelligenceLightSourceView(BOOL reactive) {
    Class cls = NSClassFromString(@"UIVisualEffectView");
    if (cls == nil) {
        return nil;
    }
    id view = [[cls alloc] initWithEffect:nil];
    OpenSwiftUICoreViewUpdateIntelligenceLightSourceView(view, reactive);
    return view;
}

void OpenSwiftUICoreViewUpdateIntelligenceLightSourceView(id view, BOOL reactive) {
    Class descriptorClass = NSClassFromString(@"_UIIntelligenceLightSourceDescriptor");
    Class effectClass = NSClassFromString(@"_UIIntelligenceContentLightEffect");
    if (effectClass == nil) {
        return;
    }
    id lightSource;
    if (reactive) {
        lightSource = [(id)descriptorClass sharedReactiveLight];
    } else {
        lightSource = [(id)descriptorClass sharedLight];
    }
    id effect = [[effectClass alloc] initWithLightSource:lightSource];
    NSArray *effects = @[effect];
    [(id)view setBackgroundEffects:effects];
}

#else

id _Nullable OpenSwiftUICoreViewMakeIntelligenceLightSourceView(BOOL reactive) {
    return nil;
}

void OpenSwiftUICoreViewUpdateIntelligenceLightSourceView(id view, BOOL reactive) {
}

#endif

#endif /* OPENSWIFTUI_TARGET_OS_DARWIN */
