//
//  CGPath+OpenSwiftUI.h
//  OpenSwiftUI_SPI

#ifndef CGPath_OpenSwiftUI_h
#define CGPath_OpenSwiftUI_h

#include "OpenSwiftUIBase.h"

#if OPENSWIFTUI_TARGET_OS_DARWIN

#include <Foundation/Foundation.h>
#include <CoreGraphics/CoreGraphics.h>

OPENSWIFTUI_ASSUME_NONNULL_BEGIN

BOOL _CGPathParseString(CGMutablePathRef path, const char *utf8CString);

/// Creates a string description of a path with optional coordinate rounding.
///
/// - Parameters:
///   - path: The path to describe.
///   - step: The rounding step for coordinates. When non-zero, coordinates
///     are rounded to the nearest multiple of this value. Pass 0 for no rounding.
/// - Returns: A string representation of the path using SVG-like commands
///   (m for move, l for line, h for close).
NSString * _CGPathCopyDescription(CGPathRef path, CGFloat step);

OPENSWIFTUI_ASSUME_NONNULL_END

#endif

#endif /* CGPath_OpenSwiftUI_h */
