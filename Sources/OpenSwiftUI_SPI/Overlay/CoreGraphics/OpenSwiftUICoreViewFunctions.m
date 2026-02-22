//
//  OpenSwiftUICoreViewFunctions.m
//  OpenSwiftUI_SPI
//
//  Status: Complete
//  Audited for 6.5.4

#include "OpenSwiftUICoreViewFunctions.h"
#include "OpenSwiftUIUIKitSubviews.h"
#include "OpenSwiftUIAppKitSubviews.h"

#if OPENSWIFTUI_TARGET_OS_DARWIN

#if OPENSWIFTUI_TARGET_OS_IOS || OPENSWIFTUI_TARGET_OS_VISION
#include <UIKit/UIKit.h>
#endif

#if OPENSWIFTUI_TARGET_OS_OSX
#include <AppKit/AppKit.h>
#endif

// MARK: - NSObject (OpenSwiftUICore_Additions)

// NOTE:
// All API should be implemented by the selector and properly include and cast.
// But some API will conflict, we currently will use platform macro check to guard the API,
// but in the future we may want to consider using a different approach to avoid potential
// issues with API availability and maintainability.
// The remaining API is now declared below so that we can call it directly on id.
@interface NSObject ()
// AppKit
- (id)maskView; // NSView
+ (id)graphicsContextWithCGContext:(CGContextRef)graphicsPort flipped:(BOOL)initialFlippedState; // NSGraphicsContext
- (void)displayRectIgnoringOpacity:(CGRect)rect inContext:(id)context; // NSView
- (void)setFrameTransform:(CGAffineTransform)transform;
@end

@implementation NSObject (OpenSwiftUICore_Additions)
- (void)openswiftui_insertRenderedSubview:(id)subview atIndex:(NSInteger)index {
    #if OPENSWIFTUI_TARGET_OS_IOS || OPENSWIFTUI_TARGET_OS_VISION
    [(UIView *)self insertSubview:subview atIndex:index];
    #endif
}
- (void)openswiftui_addRenderedSubview:(id)subview positioned:(NSInteger)place relativeTo:(id _Nullable)otherView {
    #if OPENSWIFTUI_TARGET_OS_OSX
    [(NSView *)self addSubview:subview positioned:place relativeTo:otherView];
    #endif
}
@end

// MARK: - System Resolution

OpenSwiftUIViewSystem OpenSwiftUICoreViewResolvedSystem(OpenSwiftUIViewSystem system, id view) {
    // [Q]: Unused side effect call. Also check whether caller argument should be CoreSystem or ViewSystem.
    if (system == OpenSwiftUIViewSystemNSView) {
        Class nsViewClass = NSClassFromString(@"NSView");
        if (nsViewClass != nil) {
            [view isKindOfClass:nsViewClass];
        }
    }
    return system;
}

// MARK: - Layer Access

CALayer * OpenSwiftUICoreViewLayer(OpenSwiftUIViewSystem system, id view) {
    if (system == OpenSwiftUIViewSystemCALayer) {
        return view;
    } else {
        return [view layer];
    }
}

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

// MARK: - Subview Management

void OpenSwiftUICoreViewAddSubview(OpenSwiftUIViewSystem system, id parent, id child, NSUInteger index) {
    switch (system) {
        case OpenSwiftUIViewSystemUIView:
            _OpenSwiftUIUIKitAddSubview(child, parent, index);
            break;
        case OpenSwiftUIViewSystemNSView:
            _OpenSwiftUIAppKitAddSubview(child, parent, index);
            break;
        case OpenSwiftUIViewSystemCALayer:
            [parent insertSublayer:child atIndex:(unsigned)index];
            break;
    }
}

void OpenSwiftUICoreViewRemoveFromSuperview(OpenSwiftUIViewSystem system, id view) {
    if (system == OpenSwiftUIViewSystemCALayer) {
        [view removeFromSuperlayer];
    } else {
        [view removeFromSuperview];
    }
}

NSArray * OpenSwiftUICoreViewSubviews(OpenSwiftUIViewSystem system, id view) {
    if (system == OpenSwiftUIViewSystemCALayer) {
        return [NSArray arrayWithArray:[view sublayers]];
    } else {
        return [view subviews];
    }
}

id _Nullable OpenSwiftUICoreViewMaskView(OpenSwiftUIViewSystem system, id view) {
    switch (system) {
        case OpenSwiftUIViewSystemUIView:
            #if OPENSWIFTUI_TARGET_OS_IOS || OPENSWIFTUI_TARGET_OS_VISION
            return [(UIView *)view maskView];
            #else
            return nil;
            #endif
        case OpenSwiftUIViewSystemNSView:
            #if OPENSWIFTUI_TARGET_OS_OSX
            return [(NSView *)view maskView];
            #else
            return nil;
            #endif
        case OpenSwiftUIViewSystemCALayer:
            return [view mask];
    }
}

// MARK: - Display

void OpenSwiftUICoreViewSetNeedsDisplay(OpenSwiftUIViewSystem system, id view) {
    switch (system) {
        case OpenSwiftUIViewSystemUIView:
            #if OPENSWIFTUI_TARGET_OS_IOS || OPENSWIFTUI_TARGET_OS_VISION
            [(UIView *)view setNeedsDisplay];
            #endif
            break;
        case OpenSwiftUIViewSystemNSView:
            #if OPENSWIFTUI_TARGET_OS_OSX
            [view setNeedsDisplay:YES];
            #endif
            break;
        case OpenSwiftUIViewSystemCALayer:
            [view setNeedsDisplay];
            break;
    }
}

void OpenSwiftUICoreViewDisplayIgnoringOpacity(OpenSwiftUIViewSystem system, id view, CGContextRef context) {
    if (system != OpenSwiftUIViewSystemNSView) {
        return;
    }
    Class cls = NSClassFromString(@"NSGraphicsContext");
    if (cls != nil) {
        id gc = [cls graphicsContextWithCGContext:context flipped:YES];
        [view displayRectIgnoringOpacity:[view bounds] inContext:gc];
    }
}

// MARK: - Appearance

void OpenSwiftUICoreViewSetOpacity(OpenSwiftUIViewSystem system, id view, CGFloat opacity) {
    switch (system) {
        case OpenSwiftUIViewSystemUIView:
            #if OPENSWIFTUI_TARGET_OS_IOS || OPENSWIFTUI_TARGET_OS_VISION
            [(UIView *)view setAlpha:opacity];
            #endif
            break;
        case OpenSwiftUIViewSystemNSView:
            #if OPENSWIFTUI_TARGET_OS_OSX
            [(NSView *)view setAlphaValue:opacity];
            #endif
            break;
        case OpenSwiftUIViewSystemCALayer:
            [(CALayer *)view setOpacity:(float)opacity];
            break;
    }
}

void OpenSwiftUICoreViewSetClipsToBounds(OpenSwiftUIViewSystem system, id view, BOOL clips, BOOL onLayer) {
    if (system != OpenSwiftUIViewSystemCALayer && !onLayer) {
        [view setClipsToBounds:clips];
        return;
    }
    if (system != OpenSwiftUIViewSystemCALayer) {
        view = [view layer];
    }
    [view setMasksToBounds:clips];
}

void OpenSwiftUICoreViewSetTransform(OpenSwiftUIViewSystem system, id view, CGAffineTransform transform) {
    switch (system) {
        case OpenSwiftUIViewSystemUIView:
            #if OPENSWIFTUI_TARGET_OS_IOS || OPENSWIFTUI_TARGET_OS_VISION
            [(UIView *)view setTransform:transform];
            #endif
            break;
        case OpenSwiftUIViewSystemNSView:
            #if OPENSWIFTUI_TARGET_OS_OSX
            [(NSView *)view setFrameTransform:transform];
            #endif
            break;
        case OpenSwiftUIViewSystemCALayer:
            [(CALayer *)view setAffineTransform:transform];
            break;
    }
}

// MARK: - Geometry

void OpenSwiftUICoreViewSetSize(OpenSwiftUIViewSystem system, id view, CGSize size) {
    switch (system) {
        case OpenSwiftUIViewSystemUIView:
        {
            #if OPENSWIFTUI_TARGET_OS_IOS || OPENSWIFTUI_TARGET_OS_VISION
            CGRect bounds = [(UIView *)view bounds];
            bounds.size = size;
            [(UIView *)view setBounds:bounds];
            #endif
            break;
        }
        case OpenSwiftUIViewSystemNSView:
            #if OPENSWIFTUI_TARGET_OS_OSX
             [(NSView *)view setFrameSize:size];
            #endif
            break;
        case OpenSwiftUIViewSystemCALayer:
        {
            CGRect bounds = [(CALayer *)view bounds];
            bounds.size = size;
            [(CALayer *)view setBounds:bounds];
            break;
        }
    }
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
    BOOL originChanged, BOOL sizeChanged,
    CGPoint position, CGRect bounds
) {
    switch (system) {
        case OpenSwiftUIViewSystemUIView:
        {
            #if OPENSWIFTUI_TARGET_OS_IOS || OPENSWIFTUI_TARGET_OS_VISION
            if (useViewAPIs) {
                UIView *uiView = (UIView *)view;
                assert(!originChanged);
                if (positionChanged) {
                    [uiView setCenter:position];
                }
                if (sizeChanged) {
                    bounds.origin = [uiView bounds].origin;
                    [uiView setBounds:bounds];
                }
            } else {
                CALayer *layer = [(UIView *)view layer];
                if (positionChanged) {
                    [layer setPosition:position];
                }
                if (originChanged || sizeChanged) {
                    [layer setBounds:bounds];
                }
            }
            #endif
            break;
        }
        case OpenSwiftUIViewSystemNSView:
        {
            #if OPENSWIFTUI_TARGET_OS_OSX
            NSView *nsView = (NSView *)view;
            if (positionChanged && sizeChanged) {
                [nsView setFrame:CGRectMake(position.x, position.y, bounds.size.width, bounds.size.height)];
            } else {
                if (positionChanged) {
                    [nsView setFrameOrigin:position];
                }
                if (sizeChanged) {
                    [nsView setFrameSize:bounds.size];
                }
            }
            if (originChanged) {
                [nsView setBoundsOrigin:bounds.origin];
            }
            #endif
            break;
        }
        case OpenSwiftUIViewSystemCALayer:
            if (positionChanged) {
                [(CALayer *)view setPosition:position];
            }
            if (originChanged || sizeChanged) {
                [(CALayer *)view setBounds:bounds];
            }
            break;
    }
}

void OpenSwiftUICoreViewSetMaskGeometry(
    OpenSwiftUIViewSystem system, id view,
    CGRect bounds
) {
    id maskView = OpenSwiftUICoreViewMaskView(system, view);
    if (maskView == nil) {
        return;
    }
    switch (system) {
        case OpenSwiftUIViewSystemUIView:
        {
            #if OPENSWIFTUI_TARGET_OS_IOS || OPENSWIFTUI_TARGET_OS_VISION
            UIView *uiMaskView = (UIView *)maskView;
            [uiMaskView setCenter:bounds.origin];
            [uiMaskView setBounds:bounds];
            #endif
            break;
        }
        case OpenSwiftUIViewSystemNSView:
        {
            #if OPENSWIFTUI_TARGET_OS_OSX
            NSView *nsMaskView = (NSView *)maskView;
            [nsMaskView setFrame:bounds];
            [nsMaskView setBoundsOrigin:bounds.origin];
            #endif
            break;
        }
        case OpenSwiftUIViewSystemCALayer:
        {
            CALayer *maskLayer = (CALayer *)maskView;
            [maskLayer setFrame:[view frame]];
            [maskLayer setBounds:bounds];
            break;
        }
    }
}

// MARK: - Filters and Shadow

void OpenSwiftUICoreViewSetCompositingFilter(OpenSwiftUIViewSystem system, id view, id _Nullable filter) {
    switch (system) {
        case OpenSwiftUIViewSystemUIView:
            #if OPENSWIFTUI_TARGET_OS_IOS || OPENSWIFTUI_TARGET_OS_VISION
            [[(UIView *)view layer] setCompositingFilter:filter];
            #endif
            break;
        case OpenSwiftUIViewSystemNSView:
            #if OPENSWIFTUI_TARGET_OS_OSX
            [(NSView *)view setCompositingFilter:filter];
            #endif
            break;
        case OpenSwiftUIViewSystemCALayer:
            [(CALayer *)view setCompositingFilter:filter];
            break;
    }
}

void OpenSwiftUICoreViewSetFilters(OpenSwiftUIViewSystem system, id view, NSArray * _Nullable filters) {
    switch (system) {
        case OpenSwiftUIViewSystemUIView:
            #if OPENSWIFTUI_TARGET_OS_IOS || OPENSWIFTUI_TARGET_OS_VISION
            [[(UIView *)view layer] setFilters:filters];
            #endif
            break;
        case OpenSwiftUIViewSystemNSView:
            #if OPENSWIFTUI_TARGET_OS_OSX
            [(NSView *)view setContentFilters:filters];
            #endif
            break;
        case OpenSwiftUIViewSystemCALayer:
            [(CALayer *)view setFilters:filters];
            break;
    }
}

#if OPENSWIFTUI_TARGET_OS_OSX
static NSShadow * _Nullable makeNSShadow(CGColorRef color, CGFloat radius, CGSize offset) {
    static Class nsShadowClass = nil;
    static Class nsColorClass = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        nsShadowClass = NSClassFromString(@"NSShadow");
        nsColorClass = NSClassFromString(@"NSColor");
    });
    if (nsShadowClass == nil || nsColorClass == nil) {
        return nil;
    }
    NSShadow *shadow = [[nsShadowClass alloc] init];
    [shadow setShadowColor:[nsColorClass colorWithCGColor:color]];
    [shadow setShadowBlurRadius:radius];
    [shadow setShadowOffset:offset];
    return shadow;
}
#endif

void OpenSwiftUICoreViewSetShadow(
    OpenSwiftUIViewSystem system, id view,
    CGColorRef _Nullable color, CGFloat radius,
    CGSize offset
) {
    switch (system) {
        case OpenSwiftUIViewSystemUIView:
        {
            #if OPENSWIFTUI_TARGET_OS_IOS || OPENSWIFTUI_TARGET_OS_VISION
            CALayer *layer = [(UIView *)view layer];
            if (color != NULL) {
                [layer setShadowOpacity:1.0f];
                [layer setShadowColor:color];
                [layer setShadowRadius:radius];
                [layer setShadowOffset:offset];
            } else {
                [layer setShadowOpacity:0.0f];
            }
            #endif
            break;
        }
        case OpenSwiftUIViewSystemNSView:
        {
            #if OPENSWIFTUI_TARGET_OS_OSX
            if (color != NULL) {
                [(NSView *)view setShadow:makeNSShadow(color, radius, offset)];
            } else {
                [(NSView *)view setShadow:nil];
            }
            #endif
            break;
        }
        case OpenSwiftUIViewSystemCALayer:
        {
            CALayer *layer = (CALayer *)view;
            if (color != NULL) {
                [layer setShadowOpacity:1.0f];
                [layer setShadowColor:color];
                [layer setShadowRadius:radius];
                [layer setShadowOffset:offset];
            } else {
                [layer setShadowOpacity:0.0f];
            }
            break;
        }
    }
}

#if OPENSWIFTUI_TARGET_OS_IOS || OPENSWIFTUI_TARGET_OS_VISION

// MARK: - Private API Forward Declarations

@interface NSObject (OpenSwiftUICoreViewIntelligenceEffect)
+ (id)sharedLight;
+ (id)sharedReactiveLight;
- (instancetype)initWithLightSource:(id)lightSource;
- (void)setBackgroundEffects:(NSArray *)effects;
@end

// MARK: - Intelligence Light Source

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
#endif

#endif /* OPENSWIFTUI_TARGET_OS_DARWIN */
