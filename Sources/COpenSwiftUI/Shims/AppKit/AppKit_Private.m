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

- (void)markAppLaunchComplete_openswiftui_safe_wrapper {
    OPENSWIFTUI_SAFE_WRAPPER_IMP(void, @"markAppLaunchComplete",);
    func(self, selector);
}

- (void)startedTest_openswiftui_safe_wrapper:(NSString *)name {
    OPENSWIFTUI_SAFE_WRAPPER_IMP(void, @"startedTest:", , NSString *);
    func(self, selector, name);
}

- (void)finishedTest_openswiftui_safe_wrapper:(NSString *)name extraResults:(nullable id)extraResults {
    OPENSWIFTUI_SAFE_WRAPPER_IMP(void, @"finishedTest:extraResults:", , NSString *, id);
    func(self, selector, name, extraResults);
}

- (void)failedTest_openswiftui_safe_wrapper:(NSString *)name withFailure:(NSError *)failure {
    OPENSWIFTUI_SAFE_WRAPPER_IMP(void, @"failedTest:withFailure:", , NSString *, NSError *);
    func(self, selector, name, failure);
}
@end

@implementation NSMenu (OpenSwiftUI_SPI)
+ (void)_setAlwaysCallDelegateBeforeSidebandUpdaters_openswiftui_safe_wrapper:(BOOL)value {
    OPENSWIFTUI_SAFE_WRAPPER_IMP(void, @"_setAlwaysCallDelegateBeforeSidebandUpdaters:", , BOOL);
    func(self, selector, value);
}

+ (void)_setAlwaysInstallWindowTabItems_openswiftui_safe_wrapper:(BOOL)value {
    OPENSWIFTUI_SAFE_WRAPPER_IMP(void, @"_setAlwaysInstallWindowTabItems:", , BOOL);
    func(self, selector, value);
}
@end

@implementation NSDocumentController (OpenSwiftUI_SPI)
+ (void)_setUsingModernDocuments_openswiftui_safe_wrapper:(BOOL)value {
    OPENSWIFTUI_SAFE_WRAPPER_IMP(void, @"_setUsingModernDocuments:", , BOOL);
    func(self, selector, value);
}
@end

#endif /* __has_include(<AppKit/AppKit.h>) */
