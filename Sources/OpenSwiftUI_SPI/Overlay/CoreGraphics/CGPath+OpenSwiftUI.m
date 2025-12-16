//
//  CGPath+OpenSwiftUI.m
//  OpenSwiftUI_SPI

#import "CGPath+OpenSwiftUI.h"

#if OPENSWIFTUI_TARGET_OS_DARWIN

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <xlocale.h>

BOOL _CGPathParseString(CGMutablePathRef path, const char *utf8CString) {
    // TODO
    return NO;
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

//_CGPathCreateRoundedRect

#endif
