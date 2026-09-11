//
//  UIGestureRecognizer_Private.m
//  COpenSwiftUI
//
//  Audited for iOS 18.5
//  Status: Complete

#include "UIGestureRecognizer_Private.h"

#if __has_include(<UIKit/UIKit.h>)

#include <dlfcn.h>

NSComparisonResult OpenSwiftUIGestureRecognizerContainerCompare(
    id<_UIGestureRecognizerContainer> gestureContainer,
    id<_UIGestureRecognizerContainer> otherContainer,
    BOOL usePresentationValues
) {
    typedef NSComparisonResult (*CompareFunction)(id<_UIGestureRecognizerContainer>, id<_UIGestureRecognizerContainer>, BOOL);
    static CompareFunction compare;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        compare = (CompareFunction)dlsym(
            RTLD_DEFAULT,
            "_UIGestureRecognizerContainerCompare"
        );
    });
    return compare == NULL
        ? NSOrderedSame
        : compare(gestureContainer, otherContainer, usePresentationValues);
}

void OpenSwiftUIGestureRecognizerRegisterInContainer(UIGestureRecognizer *recognizer, id<_UIGestureRecognizerContainer> container) {
    typedef void (*RegisterFunction)(UIGestureRecognizer *, id<_UIGestureRecognizerContainer>);
    static RegisterFunction registerRecognizer;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        registerRecognizer = (RegisterFunction)dlsym(RTLD_DEFAULT, "_UIGestureRecognizerRegisterInContainer");
    });
    if (registerRecognizer != NULL) {
        registerRecognizer(recognizer, container);
    }
}

void OpenSwiftUIGestureRecognizerUnregisterFromContainer(UIGestureRecognizer *recognizer, id<_UIGestureRecognizerContainer> container) {
    typedef void (*UnregisterFunction)(UIGestureRecognizer *, id<_UIGestureRecognizerContainer>);
    static UnregisterFunction unregisterRecognizer;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        unregisterRecognizer = (UnregisterFunction)dlsym(RTLD_DEFAULT, "_UIGestureRecognizerUnregisterFromContainer");
    });
    if (unregisterRecognizer != NULL) {
        unregisterRecognizer(recognizer, container);
    }
}

NSString *OpenSwiftUIGestureRecognizerContainerAncestralDescription(
    id<_UIGestureRecognizerContainer> container,
    NSString * _Nullable (^description)(id<_UIGestureRecognizerContainer>)
) {
    typedef NSString *(*DescriptionFunction)(id<_UIGestureRecognizerContainer>, NSString * _Nullable (^)(id<_UIGestureRecognizerContainer>));
    static DescriptionFunction ancestralDescription;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ancestralDescription = (DescriptionFunction)dlsym(RTLD_DEFAULT, "_UIGestureRecognizerContainerAncestralDescription");
    });
    return ancestralDescription == NULL ? @"" : ancestralDescription(container, description);
}

#endif
