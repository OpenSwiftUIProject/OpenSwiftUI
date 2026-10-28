//
//  ColorSpace.h
//  OpenSwiftUI_SPI
//
//  Audited for 6.5.4
//  Status: Complete

#ifndef ColorSpace_h
#define ColorSpace_h

#include "OpenSwiftUIBase.h"

#if __has_include(<CoreGraphics/CGColorSpace.h>)

#include <CoreGraphics/CGColorSpace.h>

OPENSWIFTUI_EXTERN_C_BEGIN
OPENSWIFTUI_IMPLICIT_BRIDGING_ENABLED

OPENSWIFTUI_EXPORT
CGColorSpaceRef _Nullable _CGColorSpaceGetPerceptual(void);

OPENSWIFTUI_IMPLICIT_BRIDGING_DISABLED
OPENSWIFTUI_EXTERN_C_END

#endif /* CoreGraphics/CGColorSpace.h */

#endif /* ColorSpace_h */
