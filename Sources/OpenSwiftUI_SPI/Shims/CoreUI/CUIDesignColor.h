//
//  CUIDesignColor.h
//  OpenSwiftUI_SPI
//
//  Audited for iOS 18.0
//  Status: Complete

#ifndef CUIDesignColor_h
#define CUIDesignColor_h

#include "OpenSwiftUIBase.h"

#if OPENSWIFTUI_TARGET_OS_DARWIN

#include "CUIDisplayGamut.h"
#import <CoreGraphics/CoreGraphics.h>

@interface CUIDesignColor : NSObject

@property (readonly, nonatomic) CGColorRef cgColor;
@property (readonly, nonatomic) CGBlendMode blendMode;
@property (readonly, nonatomic) CUIDisplayGamut displayGamut;

- (void)dealloc;
- (CGColorRef)cgColor;
- (CUIDisplayGamut)displayGamut;
- (CGBlendMode)blendMode;
- (instancetype)initWithColor:(CGColorRef)color blendMode:(CGBlendMode)blendMode displayGamut:(CUIDisplayGamut)displayGamut;

@end

#endif /* OPENSWIFTUI_TARGET_OS_DARWIN */

#endif /* CUIDesignColor_h */
