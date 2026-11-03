//
//  HostingViewInvocationTarget.m
//  COpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete

#import "HostingViewInvocationTarget.h"

#if OPENSWIFTUI_TARGET_OS_OSX

@implementation _OpenSwiftUITSHostingViewInvocationTarget {
    void (^_handler)(SEL);
}

- (instancetype)initWithHandler:(void (^)(SEL))handler {
    _handler = [handler copy];
    return self;
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)selector {
    return [NSMethodSignature signatureWithObjCTypes:"v@:@"];
}

- (void)forwardInvocation:(NSInvocation *)invocation {
    _handler(invocation.selector);
}

@end

#endif /* OPENSWIFTUI_TARGET_OS_OSX */
