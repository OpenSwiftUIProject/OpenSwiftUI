//
//  CGPath+OpenSwiftUI.m
//  OpenSwiftUI_SPI

#import "CGPath+OpenSwiftUI.h"

#if OPENSWIFTUI_TARGET_OS_DARWIN

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <xlocale.h>

#if OPENRENDERBOX_RENDERBOX
@import RenderBox;
#else
@import OpenRenderBox;
#endif

// NOTE: Not audited yet. Use with caution.
BOOL _CGPathParseString(CGMutablePathRef path, const char *utf8CString) {
    if (path == NULL || utf8CString == NULL) {
        return NO;
    }

    CGFloat numbers[6];
    int numCount = 0;
    CGFloat currentX = 0.0, currentY = 0.0;
    CGFloat lastControlX = 0.0, lastControlY = 0.0;

    const char *ptr = utf8CString;

    while (YES) {
        // Skip whitespace (characters <= 0x1f or space 0x20)
        while (*ptr != '\0' && (*ptr <= 0x1f || *ptr == ' ')) {
            ptr++;
        }

        if (*ptr == '\0') {
            // End of string - success if all numbers consumed
            return numCount == 0;
        }

        char c = *ptr;

        // Check if character can start a number
        // Valid: digits 0-9 (0x30-0x39), '-', '+', '.', 'e', 'E', 'p', 'x', "inf"
        BOOL isNumberStart = NO;
        if ((c >= '0' && c <= '9') || c == '-' || c == '+' || c == '.') {
            isNumberStart = YES;
        } else if (c == 'e' || c == 'E' || c == 'p' || c == 'x') {
            isNumberStart = YES;
        } else if (c == 'i') {
            // Check for "inf"
            if (ptr[1] == 'n' && ptr[2] == 'f') {
                isNumberStart = YES;
            }
        }

        if (isNumberStart) {
            if (numCount >= 6) {
                return NO;
            }
            char *endPtr;
            numbers[numCount++] = strtod_l(ptr, &endPtr, NULL);
            ptr = endPtr;
            continue;
        }

        // Process command character
        switch (c) {
            case 'm':
                if (numCount != 2) return NO;
                CGPathMoveToPoint(path, NULL, numbers[0], numbers[1]);
                lastControlX = currentX = numbers[0];
                lastControlY = currentY = numbers[1];
                numCount = 0;
                break;

            case 'l':
                if (numCount != 2) return NO;
                CGPathAddLineToPoint(path, NULL, numbers[0], numbers[1]);
                lastControlX = currentX = numbers[0];
                lastControlY = currentY = numbers[1];
                numCount = 0;
                break;

            case 'c':
                if (numCount != 6) return NO;
                CGPathAddCurveToPoint(path, NULL,
                                      numbers[0], numbers[1],
                                      numbers[2], numbers[3],
                                      numbers[4], numbers[5]);
                lastControlX = numbers[2];
                lastControlY = numbers[3];
                currentX = numbers[4];
                currentY = numbers[5];
                numCount = 0;
                break;

            case 'q':
                if (numCount != 4) return NO;
                CGPathAddQuadCurveToPoint(path, NULL,
                                          numbers[0], numbers[1],
                                          numbers[2], numbers[3]);
                lastControlX = numbers[0];
                lastControlY = numbers[1];
                currentX = numbers[2];
                currentY = numbers[3];
                numCount = 0;
                break;

            case 't':
                // Smooth quad curve: reflect last control point
                if (numCount != 2) return NO;
                {
                    CGFloat reflectedX = currentX - 2.0 * lastControlX;
                    CGFloat reflectedY = currentY - 2.0 * lastControlY;
                    CGPathAddQuadCurveToPoint(path, NULL,
                                              reflectedX, reflectedY,
                                              numbers[0], numbers[1]);
                    lastControlX = reflectedX;
                    lastControlY = reflectedY;
                    currentX = numbers[0];
                    currentY = numbers[1];
                }
                numCount = 0;
                break;

            case 'v':
                // Smooth cubic curve: use current point as cp1
                if (numCount != 4) return NO;
                CGPathAddCurveToPoint(path, NULL,
                                      currentX, currentY,
                                      numbers[0], numbers[1],
                                      numbers[2], numbers[3]);
                lastControlX = numbers[0];
                lastControlY = numbers[1];
                currentX = numbers[2];
                currentY = numbers[3];
                numCount = 0;
                break;

            case 'y':
                // Shorthand cubic: cp2 = endpoint
                if (numCount != 4) return NO;
                CGPathAddCurveToPoint(path, NULL,
                                      numbers[0], numbers[1],
                                      numbers[2], numbers[3],
                                      numbers[2], numbers[3]);
                currentX = numbers[2];
                currentY = numbers[3];
                numCount = 0;
                break;

            case 'h':
                if (numCount != 0) return NO;
                CGPathCloseSubpath(path);
                lastControlY = 0.0;
                numCount = 0;
                break;

            case 'r':
                // Check for "re" (rectangle)
                if (ptr[1] == 'e') {
                    if (numCount != 4) return NO;
                    CGPathAddRect(path, NULL, CGRectMake(numbers[0], numbers[1],
                                                         numbers[2], numbers[3]));
                    currentX = numbers[0];
                    currentY = numbers[1];
                    numCount = 0;
                    ptr++; // Skip 'e'
                    break;
                }
                return NO;

            default:
                return NO;
        }
        ptr++;
    }
}

typedef struct PathInfo {
    CFMutableStringRef description;
    CGFloat step;
    CGFloat inverseStep;
} PathInfo;

#define APPEND_COORD(coord) do { \
    CGFloat value = (coord); \
    if (path_info->step != 0.0) { \
        value = path_info->step * round(value * path_info->inverseStep); \
    } \
    char buffer[64]; \
    snprintf_l(buffer, 64, NULL, "%g ", value); \
    CFStringAppendCString(path_info->description, buffer, kCFStringEncodingUTF8); \
} while (0)

#define APPEND_POINTS(count) do { \
    for (int i = 0; i < (count); i++) { \
        APPEND_COORD(element->points[i].x); \
        APPEND_COORD(element->points[i].y); \
    } \
} while (0)

void copy_path_iter(void * __nullable info, const CGPathElement * element) {
    PathInfo *path_info = (PathInfo *)info;
    if (path_info->description != NULL) {
        CFStringAppend(path_info->description, CFSTR(" "));
    }
    UniChar ch;
    switch (element->type) {
        case kCGPathElementMoveToPoint:
            APPEND_POINTS(1);
            ch = 'm';
            break;
        case kCGPathElementAddLineToPoint:
            APPEND_POINTS(1);
            ch = 'l';
            break;
        case kCGPathElementAddQuadCurveToPoint:
            APPEND_POINTS(2);
            ch = 'q';
            break;
        case kCGPathElementAddCurveToPoint:
            APPEND_POINTS(3);
            ch = 'c';
            break;
        case kCGPathElementCloseSubpath:
            ch = 'h';
            break;
        default:
            return;
    }
    CFStringAppendCharacters(path_info->description, &ch, 1);
}

#undef APPEND_COORD
#undef APPEND_POINTS

NSString * _CGPathCopyDescription(CGPathRef path, CGFloat step) {
    PathInfo info = {
        CFStringCreateMutable(kCFAllocatorDefault, 0),
        step,
        1.0 / step
    };
    CGPathApply(path, &info, &copy_path_iter);
    return (__bridge_transfer NSString *)(info.description);
}

CGPathRef _CGPathCreateRoundedRect(CGRect rect, CGFloat cornerWidth, CGFloat cornerHeight, BOOL useRB) {
    // Clamp corner dimensions to be non-negative
    if (cornerWidth < 0.0) {
        cornerWidth = 0.0;
    }
    if (cornerHeight < 0.0) {
        cornerHeight = 0.0;
    }

    // If either corner dimension is 0, or rect is empty, return a plain rectangle
    if (cornerWidth == 0.0 || cornerHeight == 0.0 || CGRectIsEmpty(rect)) {
        return CGPathCreateWithRect(rect, NULL);
    }

    if (useRB) {
        #if OPENRENDERBOX_RENDERBOX
        // RBPath rbPath = RBPathMakeRoundedRect(NULL, rect, cornerWidth, cornerHeight, YES);
        // CGPathRef cgPath = RBPathCopyCGPath(rbPath);
        // RBPathRelease(rbPath);
        // return cgPath;
        #else
        // ORBPath rbPath = ORBPathMakeRoundedRect(NULL, rect, cornerWidth, cornerHeight, YES);
        // CGPathRef cgPath = ORBPathCopyCGPath(rbPath);
        // ORBPathRelease(rbPath);
        // return cgPath;
        #endif
    }

    // Use CoreGraphics path creation
    CGFloat width = CGRectGetWidth(rect);
    CGFloat height = CGRectGetHeight(rect);

    // Clamp cornerWidth to at most half the width
    if (cornerWidth * 2.0 > width) {
        cornerWidth = nextafter(width * 0.5, 0.0);
    }

    // Clamp cornerHeight to at most half the height
    if (cornerHeight * 2.0 > height) {
        cornerHeight = nextafter(height * 0.5, 0.0);
    }

    // Final validation
    if (cornerWidth < 0.0 || cornerWidth * 2.0 > width) {
        return CGPathCreateWithRect(rect, NULL);
    }
    if (cornerHeight < 0.0 || cornerHeight * 2.0 > height) {
        return CGPathCreateWithRect(rect, NULL);
    }

    return CGPathCreateWithRoundedRect(rect, cornerWidth, cornerHeight, NULL);
}

#endif
