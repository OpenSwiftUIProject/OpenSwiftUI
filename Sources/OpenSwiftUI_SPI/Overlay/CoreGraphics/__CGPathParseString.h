//
//  __CGPathParseString.h
//  OpenSwiftUI_SPI

#ifndef __CGPathParseString_h
#define __CGPathParseString_h

#include "OpenSwiftUIBase.h"

#if OPENSWIFTUI_TARGET_OS_DARWIN

#include <Foundation/Foundation.h>
#include <CoreGraphics/CoreGraphics.h>

OPENSWIFTUI_ASSUME_NONNULL_BEGIN

OPENSWIFTUI_EXPORT
BOOL __CGPathParseString(CGMutablePathRef path, const char *utf8CString);

OPENSWIFTUI_ASSUME_NONNULL_END

#endif

#endif /* __CGPathParseString_h */
