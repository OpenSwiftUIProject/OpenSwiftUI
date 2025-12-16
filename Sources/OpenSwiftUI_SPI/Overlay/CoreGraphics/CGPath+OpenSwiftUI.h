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

/// Parses a path string and appends the path elements to a mutable path.
///
/// The string format uses space-separated numbers followed by command characters:
/// - `m` - move to (x y)
/// - `l` - line to (x y)
/// - `c` - cubic curve (cp1x cp1y cp2x cp2y x y)
/// - `q` - quad curve (cpx cpy x y)
/// - `t` - smooth quad curve (x y), reflects previous control point
/// - `v` - smooth cubic curve (cp2x cp2y x y), uses current point as cp1
/// - `y` - shorthand cubic (cp1x cp1y x y), cp2 equals endpoint
/// - `h` - close subpath
/// - `re` - rectangle (x y width height)
///
/// - Parameters:
///   - path: The mutable path to append elements to.
///   - utf8CString: The path string to parse.
/// - Returns: `YES` if parsing succeeded, `NO` if the string is malformed.
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

/// Creates a rounded rectangle path with the specified corner radii.
///
/// The corner radii are automatically clamped to fit within the rectangle:
/// - Negative values are treated as 0
/// - Values exceeding half the width or height are reduced accordingly
///
/// - Parameters:
///   - rect: The rectangle to create the path from.
///   - cornerWidth: The horizontal radius of the rounded corners.
///   - cornerHeight: The vertical radius of the rounded corners.
///   - useRB: If `YES`, uses RenderBox for path creation (when available).
///     If `NO`, uses CoreGraphics directly.
/// - Returns: A new path representing the rounded rectangle. Returns a plain
///   rectangle path if either corner dimension is 0 or if the rect is empty.
CF_RETURNS_RETAINED
CGPathRef _CGPathCreateRoundedRect(CGRect rect, CGFloat cornerWidth, CGFloat cornerHeight, BOOL useRB);

OPENSWIFTUI_ASSUME_NONNULL_END

#endif

#endif /* CGPath_OpenSwiftUI_h */
