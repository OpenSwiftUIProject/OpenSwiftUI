//
//  _CUIDefaultDisplayGamut.m
//  OpenSwiftUI_SPI
//
//  Audited for iOS 18.0
//  Status: Complete

#include "CUIDefaultDisplayGamut.h"

#if OPENSWIFTUI_TARGET_OS_DARWIN && OPENSWIFTUI_LINK_COREUI

#include "../../Shims/libMobileGestalt/MobileGestalt.h"

CUIDisplayGamut _CUIDefaultDisplayGamut() {
    static CUIDisplayGamut defaultGamut;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        NSString *answer = (__bridge NSString *)(MGCopyAnswer((__bridge CFStringRef)@"ArtworkTraitDisplayGamut", nil));
        if ([answer isEqualToString:@"P3"]) {
            defaultGamut = CUIDisplayGamutP3;
        } else {
            defaultGamut = CUIDisplayGamutSRGB;
        }
    });
    return defaultGamut;
}

#endif /* OPENSWIFTUI_TARGET_OS_DARWIN */
