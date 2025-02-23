## OpenSwiftUI_SPI

### Shims

For private Darwin ObjectiveC API, we use shims wrapped to replace the direct private API call to avoid breaking change.

Below is an example of how to shim a private API call.

```objectivec
@interface UIApplication (OpenSwiftUI_SPI)
- (void)_performBlockAfterCATransactionCommits_openswiftui_safe_wrapper:(void (^)(void))block OPENSWIFTUI_SWIFT_NAME(_performBlockAfterCATransactionCommits(_:));
@end

@implementation UIApplication (OpenSwiftUI_SPI)
- (void)_performBlockAfterCATransactionCommits_openswiftui_safe_wrapper:(void (^)(void))block {
    typedef void (*Func)(UIApplication *, SEL, void (^)(void));
    SEL selector = NSSelectorFromString(@"_performBlockAfterCATransactionCommits:");
    Func func = nil;
    if ([self respondsToSelector:selector]) {
        IMP impl = class_getMethodImplementation([self class], selector);
        func = (Func)impl;
    }
    if (func != nil) {
        func(self, selector, block);
    }
}
@end
```

```swift
extension UIApplication {
    func _performBlockAfterCATransactionCommits(_ block: @escaping (Int) -> Void) {
        typealias Function = @convention(c) (UIApplication, Selector, @escaping (Int) -> Void) -> Void

        let selector = Selector(("_performBlockAfterCATransactionCommits:"))
        guard responds(to: selector),
              let implementation = class_getMethodImplementation(UIApplication.self, selector)
        else {
            return
        }
        let function = unsafeBitCast(implementation, to: Function.self)
        return function(self, selector, block)
    }
}
```

TODO:
- [ ] Add String concat helper macro to avoid selector name being detected.
- [ ] Add static variable to avoid selector build.
- [ ] Add static variable to avoid multiple method lookup.
