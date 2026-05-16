//
//  UIGeometry.h
//  OpenSwiftUI_SPI

#pragma once

#include "OpenSwiftUIBase.h"

#if OPENSWIFTUI_TARGET_OS_DARWIN

#import <CoreGraphics/CoreGraphics.h>
#import <Foundation/Foundation.h>

OPENSWIFTUI_ASSUME_NONNULL_BEGIN

@interface NSValue (OpenSwiftUI_UIGeometry)

+ (NSValue *)valueWithCGPoint_openswiftui_safe_wrapper:(CGPoint)point OPENSWIFTUI_SWIFT_NAME(init(cgPoint:));
+ (NSValue *)valueWithCGSize_openswiftui_safe_wrapper:(CGSize)size OPENSWIFTUI_SWIFT_NAME(init(cgSize:));
+ (NSValue *)valueWithCGRect_openswiftui_safe_wrapper:(CGRect)rect OPENSWIFTUI_SWIFT_NAME(init(cgRect:));

@end

OPENSWIFTUI_ASSUME_NONNULL_END

#endif /* OPENSWIFTUI_TARGET_OS_DARWIN */
