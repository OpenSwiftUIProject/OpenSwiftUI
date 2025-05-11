//
//  CoreAnimation_Private.m
//  OpenSwiftUI_SPI

#import "CoreAnimation_Private.h"
#import "../OpenSwiftUIShims.h"

#if __has_include(<QuartzCore/CoreAnimation.h>)

#import <objc/runtime.h>

@implementation CALayer (OpenSwiftUI_SPI)

- (BOOL)hasBeenCommitted_openswiftui_safe_wrapper {
    OPENSWIFTUI_SAFE_WRAPPER_IMP(BOOL, @"_performBlockAfterCATransactionCommits:", NO);
    return func(self, selector);
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
