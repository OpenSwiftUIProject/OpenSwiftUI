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

- (BOOL)allowsHitTesting_openswiftui_safe_wrapper {
    OPENSWIFTUI_SAFE_WRAPPER_IMP(BOOL, @"allowsHitTesting", YES);
    return func(self, selector);
}

- (void)setAllowsHitTesting_openswiftui_safe_wrapper:(BOOL)allows {
    OPENSWIFTUI_SAFE_WRAPPER_IMP(void, @"setAllowsHitTesting:", , BOOL);
    func(self, selector, allows);
}

- (uint64_t)openSwiftUI_viewTestProperties {
    NSNumber *properties = [self valueForKey:@"_viewTestProperties"];
    return properties.integerValue;
}

- (void)setOpenSwiftUI_viewTestProperties:(uint64_t)properties {
    [self setValue:[NSNumber numberWithUnsignedLongLong:properties] forKey:@"_viewTestProperties"];
}
@end

void _CALayerSetSplatsContentsAlpha(CALayer * _Nonnull layer, BOOL splatAlpha) {
    layer.contentsSwizzle = splatAlpha ? kCALayerContentsSwizzleAAAA : kCALayerContentsSwizzleRGBA;
}

#endif /* <QuartzCore/CALayer.h> */
