//
//  CoreAnimation_Private.m
//  OpenSwiftUI_SPI

#import "CoreAnimation_Private.h"

#if __has_include(<QuartzCore/CoreAnimation.h>)

#import "../OpenSwiftUIShims.h"
#import <objc/runtime.h>

@implementation NSValue (OpenSwiftUI_SPI)
+ (NSValue *)valueWithCAColorMatrix_openswiftui_safe_wrapper:(CAColorMatrix)t {
    OPENSWIFTUI_SAFE_WRAPPER_IMP(NSValue *, @"valueWithCAColorMatrix:", nil, CAColorMatrix);
    return func(self, selector, t);
}
@end

@implementation CADisplayLink (OpenSwiftUI_SPI)

+ (instancetype)displayLinkWithDisplay_openswiftui_safe_wrapper:(CADisplay *)display target:(id)target selector:(SEL)targetSelector {
    OPENSWIFTUI_SAFE_WRAPPER_IMP(CADisplayLink *, @"displayLinkWithDisplay:target:selector:", nil, CADisplay *, id, SEL);
    return func(self, selector, display, target, targetSelector);
}

- (CADisplay *)display_openswiftui_safe_wrapper {
    OPENSWIFTUI_SAFE_WRAPPER_IMP(CADisplay *, @"display", nil);
    return func(self, selector);
}

- (void)setHighFrameRateReasons_openswiftui_safe_wrapper:(const uint32_t *)reasons count:(NSInteger)count {
    OPENSWIFTUI_SAFE_WRAPPER_IMP(void, @"setHighFrameRateReasons:count:", , const uint32_t *, NSInteger);
    return func(self, selector, reasons, count);
}
@end

#endif /* CoreAnimation.h */
