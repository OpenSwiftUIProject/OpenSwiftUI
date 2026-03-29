//
//  CALayer+OpenSwiftUIAdditions.m
//  OpenSwiftUI_SPI
//
//  Audited for 6.5.4
//  Status: Complete

#import "CALayer+OpenSwiftUIAdditions.h"
#import "CANullAction.h"

#if __has_include(<QuartzCore/QuartzCore.h>)

// MARK: - _OpenSwiftUI_NoAnimationDelegate

/// A class whose sole purpose is to act as a CALayer delegate that
/// suppresses all implicit animations by returning kCFNull.
/// Used as a class object (not an instance) — the class method
/// +actionForLayer:forKey: is dispatched via the metaclass.
@interface _OpenSwiftUI_NoAnimationDelegate : NSObject
@end

@implementation _OpenSwiftUI_NoAnimationDelegate

+ (id<CAAction>)actionForLayer:(CALayer *)layer forKey:(NSString *)event {
    return _CANullAction();
}

@end

// MARK: - CALayer (OpenSwiftUIAdditions)

@implementation CALayer (OpenSwiftUIAdditions)

- (uint64_t)openSwiftUI_viewTestProperties {
    NSNumber *properties = [self valueForKey:@"_openSwiftUI_viewTestProperties"];
    return properties.integerValue;
}

- (void)setOpenSwiftUI_viewTestProperties:(uint64_t)properties {
    [self setValue:[NSNumber numberWithUnsignedLongLong:properties] forKey:@"_openSwiftUI_viewTestProperties"];
}

- (int64_t)openSwiftUI_displayListID {
    NSNumber *value = [self valueForKey:@"_openSwiftUI_displayListID"];
    if (value == nil) {
        return INT64_MAX;
    }
    return value.integerValue;
}

- (void)setOpenSwiftUI_displayListID:(int64_t)displayListID {
    [self setValue:[NSNumber numberWithInteger:displayListID] forKey:@"_openSwiftUI_displayListID"];
}

- (void)openSwiftUI_setNoAnimationDelegate {
    self.delegate = (id)[_OpenSwiftUI_NoAnimationDelegate class];
}

@end

#endif /* __has_include(<QuartzCore/QuartzCore.h>) */
