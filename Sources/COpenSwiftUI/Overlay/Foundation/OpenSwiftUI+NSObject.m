//
//  OpenSwiftUI+NSObject.m
//  COpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete

#import "OpenSwiftUI+NSObject.h"

#if OPENSWIFTUI_TARGET_OS_DARWIN

@implementation NSObject (OpenSwiftUI)
+ (BOOL)_isFromOpenSwiftUI {
    return NO;
}

- (void)_performSelector:(SEL)selector withObject:(id)object {
    if (object != nil) {
        void (*implementation)(id, SEL) = (void (*)(id, SEL))[object methodForSelector:selector];
        implementation(object, selector);
    }
}
@end

#endif /* OPENSWIFTUI_TARGET_OS_DARWIN */
