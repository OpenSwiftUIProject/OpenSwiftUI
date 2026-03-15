//
//  CGBitmapContextCreate.h
//  OpenSwiftUI_SPI
//
//  Audited for 6.5.4
//  Status: Complete

#ifndef CGBitmapContextCreate_h
#define CGBitmapContextCreate_h

#include "OpenSwiftUIBase.h"

#if OPENSWIFTUI_TARGET_OS_DARWIN

#include <CoreGraphics/CoreGraphics.h>

OPENSWIFTUI_ASSUME_NONNULL_BEGIN
OPENSWIFTUI_EXTERN_C_BEGIN
OPENSWIFTUI_IMPLICIT_BRIDGING_ENABLED

/// Convenience wrapper around CGBitmapContextCreate with fixed defaults:
/// data = NULL, bitsPerComponent = 8, bytesPerRow = 0
OPENSWIFTUI_EXPORT
CGContextRef _Nullable _CGBitmapContextCreate(
    size_t width,
    size_t height,
    CGColorSpaceRef _Nullable space,
    uint32_t bitmapInfo
);

OPENSWIFTUI_IMPLICIT_BRIDGING_DISABLED
OPENSWIFTUI_EXTERN_C_END
OPENSWIFTUI_ASSUME_NONNULL_END

#endif /* OPENSWIFTUI_TARGET_OS_DARWIN */

#endif /* CGBitmapContextCreate_h */
