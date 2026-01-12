//
//  CoreGraphics_Private.h
//  OpenSwiftUI_SPI

#pragma once

#include "OpenSwiftUIBase.h"

#if __has_include(<CoreGraphics/CoreGraphics.h>)
#include <CoreGraphics/CoreGraphics.h>

OPENSWIFTUI_ASSUME_NONNULL_BEGIN

OPENSWIFTUI_EXPORT
bool CGImageGetHeadroom(CGImageRef cg_nullable image, float cg_nullable *headroom);

OPENSWIFTUI_ASSUME_NONNULL_END

#endif /* CoreGraphics.h */
