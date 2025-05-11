//
//  UIKit_Private.m
//  OpenSwiftUI_SPI
//
//  Status: WIP

#import "UIKit_Private.h"
#import "../OpenSwiftUIShims.h"

#if __has_include(<UIKit/UIKit.h>)

#import <objc/runtime.h>

@implementation UIApplication (OpenSwiftUI_SPI)
- (void)_performBlockAfterCATransactionCommits_openswiftui_safe_wrapper:(void (^)(void))block {
    OPENSWIFTUI_SAFE_WRAPPER_IMP(void, @"_performBlockAfterCATransactionCommits:", block(),void (^)(void));
    func(self, selector, block);
}

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

- (NSString *)_launchTestName_openswiftui_safe_wrapper {
    OPENSWIFTUI_SAFE_WRAPPER_IMP(NSString *, @"_launchTestName", nil);
    return func(self, selector);
}
@end

@implementation UIView (OpenSwiftUI_SPI)
- (BOOL)_shouldAnimatePropertyWithKey_openswiftui_safe_wrapper:(NSString *)key {
    OPENSWIFTUI_SAFE_WRAPPER_IMP(BOOL, @"_shouldAnimatePropertyWithKey:", NO, NSString *);
    return func(self, selector, key);
}
@end

@implementation UIViewController (OpenSwiftUI_SPI)
- (BOOL)_canShowWhileLocked_openswiftui_safe_wrapper {
    OPENSWIFTUI_SAFE_WRAPPER_IMP(BOOL, @"_canShowWhileLocked", NO);
    return func(self, selector);
}
@end

#endif /* UIKit.h */
