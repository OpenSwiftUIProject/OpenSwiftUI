//
//  CoreUI+UIUserInterfaceIdiom.c
//  OpenSwiftUI_SPI
//
//  Audited for 6.4.41
//  Status: Complete

#include "CoreUI+UIUserInterfaceIdiom.h"

#if __has_include(<UIKit/UIKit.h>)
#include "../../Shims/UIKit/UIKit_Private.h"

NSInteger _CUIIdiomForIdiom(UIUserInterfaceIdiom idiom) {
    switch (idiom) {
        case UIUserInterfaceIdiomPhone: return 1;
        case UIUserInterfaceIdiomPad: return 2;
        case UIUserInterfaceIdiomTV: return 3;
        case UIUserInterfaceIdiomCarPlay: return 4;
        case 4: return 5;
        case UIUserInterfaceIdiomMac: return 7;
        case UIUserInterfaceIdiomVision: return 8;
        default: return 0;
    }
}

NSInteger _CUISubtypeForIdiom(UIUserInterfaceIdiom idiom) {
    switch (idiom) {
        case UIUserInterfaceIdiomPhone: {
            CGRect bounds = UIScreen.mainScreen._referenceBounds_openswiftui_safe_wrapper;
            double height = CGRectGetHeight(bounds);
            if (height > 667.0) {
                return 570; // 0x23a
            } else if (height > 568.0) {
                return 569; // 0x239
            } else if (height > 480.0) {
                return 568; // 0x238
            } else {
                return 0;
            }
        }
        case UIUserInterfaceIdiomPad: {
            CGFloat pointsPerInch = UIScreen.mainScreen._pointsPerInch_openswiftui_safe_wrapper;
            return pointsPerInch == 163.0 ? 163 : 0;
        }
        case UIUserInterfaceIdiomTV: {
            CGRect bounds = UIScreen.mainScreen._referenceBounds_openswiftui_safe_wrapper;
            double height = CGRectGetHeight(bounds) * UIScreen.mainScreen.scale;
            return height < 1080.0 ? 720 : 0;
        }
        case 4: return 320;
        case UIUserInterfaceIdiomVision: return 3648;
        default: return 0;
    }
}

#endif /* __has_include(<UIKit/UIKit.h>) */
