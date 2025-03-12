//
//  OpenSwiftUITesting_Swizzles+UIKit.m
//  COpenSwiftUI
//
//  Audited for iOS 18.0
//  Status: Complete

#include "OpenSwiftUITesting_Swizzles+UIKit.h"
#include "OpenSwiftUITesting_Swizzles.h"

#if OPENSWIFTUI_TARGET_OS_IOS

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

@implementation UICollectionView (OpenSwiftUITesting_Swizzles)
+ (void)_performOpenSwiftUITestingOverrides {
    _SwizzleMethods(UIScreen.class, @selector(_viewAnimationsForCurrentUpdateWithCollectionViewAnimator:), @selector(_OpenSwiftUITesting__viewAnimationsForCurrentUpdateWithCollectionViewAnimator:));
}

- (id)_OpenSwiftUITesting__viewAnimationsForCurrentUpdateWithCollectionViewAnimator:(id)arg1 {
    return nil;
}
@end
#endif
