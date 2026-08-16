#import "NSView_Private.h"
#import "Shims/OpenSwiftUIShims.h"

#if __has_include(<AppKit/AppKit.h>)

#import <objc/runtime.h>

@implementation NSView (OpenSwiftUI_SPI)

- (BOOL)ignoreHitTest_openswiftui_safe_wrapper {
	OPENSWIFTUI_SAFE_WRAPPER_IMP(BOOL, @"ignoreHitTest", NO);
	return func(self, selector);
}

- (void)setIgnoreHitTest_openswiftui_safe_wrapper:(BOOL)ignoreHitTest {
	OPENSWIFTUI_SAFE_WRAPPER_IMP(void, @"setIgnoreHitTest:", , BOOL);
	func(self, selector, ignoreHitTest);
}

@end

#endif /* __has_include(<AppKit/AppKit.h>) */
