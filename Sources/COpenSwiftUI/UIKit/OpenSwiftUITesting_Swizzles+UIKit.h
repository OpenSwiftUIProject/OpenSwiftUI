//
//  OpenSwiftUITesting_Swizzles+UIKit.h
//  COpenSwiftUI
//
//  Audited for iOS 18.0
//  Status: Complete

#ifndef OpenSwiftUITesting_Swizzles_UIKit_h
#define OpenSwiftUITesting_Swizzles_UIKit_h

#include "OpenSwiftUIBase.h"

#if OPENSWIFTUI_TARGET_OS_IOS
#include <UIKit/UIKit.h>

OPENSWIFTUI_ASSUME_NONNULL_BEGIN

@interface UIScreen (OpenSwiftUITesting_Swizzles)
+ (void)_performOpenSwiftUITestingOverrides;
- (CGFloat)_OpenSwiftUITesting_currentScreenScale;
- (BOOL)_OpenSwiftUITesting_wantsWideContentMargins;
@end

@interface UICollectionView (OpenSwiftUITesting_Swizzles)
+ (void)_performOpenSwiftUITestingOverrides;
- (id)_OpenSwiftUITesting__viewAnimationsForCurrentUpdateWithCollectionViewAnimator:(id)arg1;
@end

OPENSWIFTUI_ASSUME_NONNULL_END

#endif /* OPENSWIFTUI_TARGET_OS_IOS */

#endif /* OpenSwiftUITesting_Swizzles_UIKit_h */
