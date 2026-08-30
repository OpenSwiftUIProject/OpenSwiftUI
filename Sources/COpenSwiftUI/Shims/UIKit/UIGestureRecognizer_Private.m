//
//  UIGestureRecognizer_Private.m
//  COpenSwiftUI
//
//  Audited for iOS 18.5
//  Status: Complete

#include "UIGestureRecognizer_Private.h"

#if __has_include(<UIKit/UIKit.h>)

#include <dlfcn.h>

NSInteger OpenSwiftUIGestureRecognizerContainerCompare(
    id gestureContainer,
    UIView *view,
    BOOL usePresentationValues
) {
    typedef NSInteger (*CompareFunction)(id, UIView *, BOOL);
    static CompareFunction compare;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        compare = (CompareFunction)dlsym(
            RTLD_DEFAULT,
            "_UIGestureRecognizerContainerCompare"
        );
    });
    return compare == NULL
        ? 0
        : compare(gestureContainer, view, usePresentationValues);
}

#endif
