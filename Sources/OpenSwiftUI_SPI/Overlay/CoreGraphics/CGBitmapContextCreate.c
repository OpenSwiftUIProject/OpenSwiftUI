//
//  CGBitmapContextCreate.c
//  OpenSwiftUI_SPI
//
//  Audited for 6.5.4
//  Status: Complete

#include "CGBitmapContextCreate.h"

#if OPENSWIFTUI_TARGET_OS_DARWIN

CGContextRef _Nullable _CGBitmapContextCreate(
    size_t width,
    size_t height,
    CGColorSpaceRef _Nullable space,
    uint32_t bitmapInfo
) {
    return CGBitmapContextCreate(NULL, width, height, 8, 0, space, bitmapInfo);
}

#endif
