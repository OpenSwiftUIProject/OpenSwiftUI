//
//  CoreUI+UIUserInterfaceIdiom.c
//  OpenSwiftUI_SPI
//
//  Audited for 6.4.41
//  Status: Complete

#include "CoreUI+UIUserInterfaceIdiom.h"

#if OPENSWIFTUI_TARGET_OS_IOS && OPENSWIFTUI_LINK_COREUI
#include "../../Shims/UIKit/UIKit_Private.h"

CUIDeviceIdiom _CUIIdiomForIdiom(UIUserInterfaceIdiom idiom) {
    switch (idiom) {
        case UIUserInterfaceIdiomPhone: return CUIDeviceIdiomIPhone;
        case UIUserInterfaceIdiomPad: return CUIDeviceIdiomIPad;
        case UIUserInterfaceIdiomTV: return CUIDeviceIdiomAppleTV;
        case UIUserInterfaceIdiomCarPlay: return CUIDeviceIdiomCarPlay;
        case /* UIUserInterfaceIdiomWatch */ 4: return CUIDeviceIdiomAppleWatch;
        case UIUserInterfaceIdiomMac: return CUIDeviceIdiomMac;
        case UIUserInterfaceIdiomVision: return CUIDeviceIdiomVision;
        default: return 0;
    }
}

CUISubtype _CUISubtypeForIdiom(UIUserInterfaceIdiom idiom) {
    switch (idiom) {
        case UIUserInterfaceIdiomPhone: {
            CGRect bounds = UIScreen.mainScreen._referenceBounds_openswiftui_safe_wrapper;
            double height = CGRectGetHeight(bounds);
            if (height > 667.0) {
                return CUISubtypeIPhonePlus;
            } else if (height > 568.0) {
                return CUISubtypeIPhone47Inch;
            } else if (height > 480.0) {
                return CUISubtypeIPhone4Inch;
            } else {
                return CUISubtypeNormal;
            }
        }
        case UIUserInterfaceIdiomPad: {
            CGFloat pointsPerInch = UIScreen.mainScreen._pointsPerInch_openswiftui_safe_wrapper;
            return pointsPerInch == 163.0 ? CUISubtypeIPadMini : CUISubtypeNormal;
        }
        case UIUserInterfaceIdiomTV: {
            CGRect bounds = UIScreen.mainScreen._referenceBounds_openswiftui_safe_wrapper;
            double height = CGRectGetHeight(bounds) * UIScreen.mainScreen.scale;
            return height < 1080.0 ? CUISubtypeAppleTVHD : CUISubtypeNormal;
        }
        case /* UIUserInterfaceIdiomWatch */ 4: return CUISubtypeAppleWatch38;
        case UIUserInterfaceIdiomVision: return CUISubtypeAppleVision;
        default: return CUISubtypeNormal;
    }
}

#endif /* OPENSWIFTUI_TARGET_OS_IOS && OPENSWIFTUI_LINK_COREUI */
