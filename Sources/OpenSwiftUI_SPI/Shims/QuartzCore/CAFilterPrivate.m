//
//  CAFilterPrivate.m
//  OpenSwiftUI_SPI

#import "CAFilterPrivate.h"

#if __has_include(<QuartzCore/CoreAnimation.h>)

NSMutableArray<CAFilter *> *_CAFilterArrayCreate(void) {
    return [[NSMutableArray alloc] init];
}

void _CAFilterArrayAppend(NSMutableArray<CAFilter *> *array, CAFilter *filter) {
    [array addObject:filter];
}

CAFilter *OpenSwiftUICoreMakeGaussianBlurFilter(CGFloat radius) {
    Class filterClass = NSClassFromString(@"CAFilter");
    SEL selector = NSSelectorFromString(@"filterWithType:");
    if (filterClass == Nil || ![filterClass respondsToSelector:selector]) {
        return nil;
    }
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    CAFilter *filter = [filterClass performSelector:selector withObject:@"gaussianBlur"];
#pragma clang diagnostic pop
    [filter setValue:@(radius) forKey:@"inputRadius"];
    return filter;
}

#endif /* CoreAnimation.h */
