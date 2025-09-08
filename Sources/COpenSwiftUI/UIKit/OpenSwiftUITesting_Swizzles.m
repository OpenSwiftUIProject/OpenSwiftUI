//
//  OpenSwiftUITesting_Swizzles.m
//  COpenSwiftUI
//
//  Audited for iOS 18.0
//  Status: Complete

#include "OpenSwiftUITesting_Swizzles.h"

#if OPENSWIFTUI_TARGET_OS_IOS || OPENSWIFTUI_TARGET_OS_VISION
#include <objc/runtime.h>
#include "UIKit/OpenSwiftUITesting_Swizzles+UIKit.h"

void _PerformTestingSwizzles() {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        #if !OPENSWIFTUI_TARGET_OS_VISION
        [UIScreen _performOpenSwiftUITestingOverrides];
        #endif
        [UICollectionView _performOpenSwiftUITestingOverrides];
    });
}

void _SwizzleMethods(Class class, SEL originalSelector, SEL swizzledSelector) {
    Method originalMethod = class_getInstanceMethod(class, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
    IMP swizzledImp = method_getImplementation(swizzledMethod);
    const char *swizzledTypeEncoding = method_getTypeEncoding(swizzledMethod);
    BOOL success = class_addMethod(class, originalSelector, swizzledImp, swizzledTypeEncoding);
    if (success) {
        IMP originalImp = method_getImplementation(originalMethod);
        const char *originalTypeEncoding = method_getTypeEncoding(originalMethod);
        class_replaceMethod(class, swizzledSelector, originalImp, originalTypeEncoding);
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

#endif /* OPENSWIFTUI_TARGET_OS_IOS || OPENSWIFTUI_TARGET_OS_VISION */
