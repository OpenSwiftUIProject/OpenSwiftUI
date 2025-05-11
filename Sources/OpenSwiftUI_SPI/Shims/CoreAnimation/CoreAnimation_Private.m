//
//  CoreAnimation_Private.m
//  OpenSwiftUI_SPI

#import "CoreAnimation_Private.h"

#if __has_include(<QuartzCore/CoreAnimation.h>)

#import "../OpenSwiftUIShims.h"
#import <objc/runtime.h>

@implementation CALayer (OpenSwiftUI_SPI)

- (BOOL)hasBeenCommitted_openswiftui_safe_wrapper {
    OPENSWIFTUI_SAFE_WRAPPER_IMP(BOOL, @"hasBeenCommitted", NO);
    return func(self, selector);
}

- (void)setAllowsEdgeAntialiasing_openswiftui_safe_wrapper:(BOOL)allows {
    OPENSWIFTUI_SAFE_WRAPPER_IMP(void, @"setAllowsEdgeAntialiasing:", , BOOL);
    func(self, selector, allows);
}

- (void)setAllowsGroupOpacity_openswiftui_safe_wrapper:(BOOL)allows {
    OPENSWIFTUI_SAFE_WRAPPER_IMP(void, @"setAllowsGroupOpacity:", , BOOL);
    func(self, selector, allows);
}

- (void)setAllowsGroupBlending_openswiftui_safe_wrapper:(BOOL)allows {
    OPENSWIFTUI_SAFE_WRAPPER_IMP(void, @"setAllowsGroupBlending:", , BOOL);
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

#endif /* CoreAnimation.h */
