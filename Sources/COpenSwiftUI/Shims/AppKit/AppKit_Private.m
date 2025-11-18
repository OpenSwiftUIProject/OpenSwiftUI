//
//  AppKit_Private.m
//  OpenSwiftUI_SPI
//
//  Status: WIP

#import "AppKit_Private.h"
#import "Shims/OpenSwiftUIShims.h"

#if __has_include(<AppKit/AppKit.h>)

#import <objc/runtime.h>

@implementation NSApplication (OpenSwiftUI_SPI)
- (void)startedTest_openswiftui_safe_wrapper:(NSString *)name {
    OPENSWIFTUI_SAFE_WRAPPER_IMP(void, @"startedTest:", , NSString *);
    func(self, selector, name);
}

- (void)finishedTest_openswiftui_safe_wrapper:(NSString *)name {
    OPENSWIFTUI_SAFE_WRAPPER_IMP(void, @"finishedTest:", , NSString *);
    func(self, selector, name);
}

- (void)failedTest_openswiftui_safe_wrapper:(NSString *)name withFailure:(NSError *)failure {
    OPENSWIFTUI_SAFE_WRAPPER_IMP(void, @"failedTest:withFailure:", , NSString *, NSError *);
    func(self, selector, name, failure);
}
@end

#endif /* __has_include(<AppKit/AppKit.h>) */

