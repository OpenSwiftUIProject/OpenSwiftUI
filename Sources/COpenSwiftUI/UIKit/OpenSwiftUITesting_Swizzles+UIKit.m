//
//  OpenSwiftUITesting_Swizzles+UIKit.m
//  COpenSwiftUI
//
//  Audited for 6.0.87
//  Status: Complete

#include "OpenSwiftUITesting_Swizzles+UIKit.h"
#include "OpenSwiftUITesting_Swizzles.h"

#if OPENSWIFTUI_TARGET_OS_IOS || OPENSWIFTUI_TARGET_OS_VISION

#if !OPENSWIFTUI_TARGET_OS_VISION || OPENSWIFTUI_INTERNAL_XR_SDK
@implementation UIScreen (OpenSwiftUITesting_Swizzles)
+ (void)_performOpenSwiftUITestingOverrides {
    _SwizzleMethods(UIScreen.class, @selector(scale), @selector(_OpenSwiftUITesting_currentScreenScale));
    _SwizzleMethods(UIScreen.class, @selector(_wantsWideContentMargins), @selector(_OpenSwiftUITesting_wantsWideContentMargins));
}

- (CGFloat)_OpenSwiftUITesting_currentScreenScale {
    return 2.0;
}

- (BOOL)_OpenSwiftUITesting_wantsWideContentMargins {
    return NO;
}
@end
#endif

@implementation UICollectionView (OpenSwiftUITesting_Swizzles)
+ (void)_performOpenSwiftUITestingOverrides {
    #if !OPENSWIFTUI_TARGET_OS_VISION
    _SwizzleMethods(UIScreen.class, @selector(_viewAnimationsForCurrentUpdateWithCollectionViewAnimator:), @selector(_OpenSwiftUITesting__viewAnimationsForCurrentUpdateWithCollectionViewAnimator:));
    #endif
}

- (id)_OpenSwiftUITesting__viewAnimationsForCurrentUpdateWithCollectionViewAnimator:(id)arg1 {
    return nil;
}
@end
#endif
