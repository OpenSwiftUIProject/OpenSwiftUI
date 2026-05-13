//
//  CALayerPrivate.m
//  OpenSwiftUI_SPI

#import "CoreAnimation_Private.h"

#if __has_include(<QuartzCore/CALayer.h>)

#import "../OpenSwiftUIShims.h"
#import <objc/runtime.h>

@implementation CALayer (OpenSwiftUI_SPI)
@dynamic contentsSwizzle;
@dynamic contentsMultiplyColor;
@dynamic contentsScaling;
@dynamic wantsExtendedDynamicRangeContent;
@dynamic contentsMaximumDesiredEDR;

- (BOOL)allowsDisplayCompositing_openswiftui_safe_wrapper {
    OPENSWIFTUI_SAFE_WRAPPER_IMP(BOOL, @"allowsDisplayCompositing", NO);
    return func(self, selector);
}

- (void)setAllowsDisplayCompositing_openswiftui_safe_wrapper:(BOOL)allows {
    OPENSWIFTUI_SAFE_WRAPPER_IMP(void, @"setAllowsDisplayCompositing:", , BOOL);
    func(self, selector, allows);
}

- (BOOL)hasBeenCommitted_openswiftui_safe_wrapper {
    OPENSWIFTUI_SAFE_WRAPPER_IMP(BOOL, @"hasBeenCommitted", NO);
    return func(self, selector);
}

- (BOOL)allowsGroupBlending_openswiftui_safe_wrapper {
    OPENSWIFTUI_SAFE_WRAPPER_IMP(BOOL, @"allowsGroupBlending", NO);
    return func(self, selector);
}

- (void)setAllowsGroupBlending_openswiftui_safe_wrapper:(BOOL)allows {
    OPENSWIFTUI_SAFE_WRAPPER_IMP(void, @"setAllowsGroupBlending:", , BOOL);
    func(self, selector, allows);
}

- (BOOL)needsLayoutOnGeometryChange_openswiftui_safe_wrapper {
    OPENSWIFTUI_SAFE_WRAPPER_IMP(BOOL, @"needsLayoutOnGeometryChange", NO);
    return func(self, selector);
}

- (void)setNeedsLayoutOnGeometryChange_openswiftui_safe_wrapper:(BOOL)needsLayout {
    OPENSWIFTUI_SAFE_WRAPPER_IMP(void, @"setNeedsLayoutOnGeometryChange:", , BOOL);
    func(self, selector, needsLayout);
}

- (uint32_t)disableUpdateMask_openswiftui_safe_wrapper {
    OPENSWIFTUI_SAFE_WRAPPER_IMP(uint32_t, @"disableUpdateMask", 0);
    return func(self, selector);
}

- (void)setDisableUpdateMask_openswiftui_safe_wrapper:(uint32_t)mask {
    OPENSWIFTUI_SAFE_WRAPPER_IMP(void, @"setDisableUpdateMask:", , uint32_t);
    func(self, selector, mask);
}

- (BOOL)shadowPathIsBounds_openswiftui_safe_wrapper {
    OPENSWIFTUI_SAFE_WRAPPER_IMP(BOOL, @"shadowPathIsBounds", NO);
    return func(self, selector);
}

- (void)setShadowPathIsBounds_openswiftui_safe_wrapper:(BOOL)value {
    OPENSWIFTUI_SAFE_WRAPPER_IMP(void, @"setShadowPathIsBounds:", , BOOL);
    func(self, selector, value);
}

- (BOOL)allowsHitTesting_openswiftui_safe_wrapper {
    OPENSWIFTUI_SAFE_WRAPPER_IMP(BOOL, @"allowsHitTesting", YES);
    return func(self, selector);
}

- (void)setAllowsHitTesting_openswiftui_safe_wrapper:(BOOL)allows {
    OPENSWIFTUI_SAFE_WRAPPER_IMP(void, @"setAllowsHitTesting:", , BOOL);
    func(self, selector, allows);
}

@end

void _CALayerSetSplatsContentsAlpha(CALayer * _Nonnull layer, BOOL splatAlpha) {
    layer.contentsSwizzle = splatAlpha ? kCALayerContentsSwizzleAAAA : kCALayerContentsSwizzleRGBA;
}

#endif /* <QuartzCore/CALayer.h> */
