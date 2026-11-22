//
//  CGPath+OpenSwiftUI.m
//  OpenSwiftUI_SPI
//
//  Audited for 6.5.4
//  Status: Complete

#import "CGPath+OpenSwiftUI.h"

#if OPENSWIFTUI_TARGET_OS_DARWIN

#include <OpenRenderBoxShims/OpenRenderBoxShims.h>
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <xlocale.h>

bool _CGPathParseString(CGMutablePathRef path, const char *utf8CString) {
    double numbers[6];
    int numCount = 0;
    CGFloat currentX = 0.0, currentY = 0.0;
    CGFloat lastControlX = 0.0, lastControlY = 0.0;
    while (1) {
        unsigned char c;
        while ((c = (unsigned char)*utf8CString) <= 0x1f) {
            switch (c) {
            case 0:
                return true;
            case 9:
            case 10:
            case 12:
            case 13:
                utf8CString++;
                break;
            default:
                return false;
            }
        }
        bool isNumberStart = false;
        switch (c) {
        case ' ':
            break;
        case '+':
        case '-':
        case '.':
        case '0' ... '9':
        case 'E':
        case 'P':
        case 'X':
        case 'e':
        case 'p':
        case 'x':
            isNumberStart = true;
            break;
        case 'I':
            if (utf8CString[1] == 'n' && utf8CString[2] == 'f') {
                isNumberStart = true;
            }
            break;
        case 'm':
            if (numCount != 2) return false;
            CGPathMoveToPoint(path, NULL, numbers[0], numbers[1]);
            currentX = lastControlX = numbers[0];
            currentY = lastControlY = numbers[1];
            numCount = 0;
            break;
        case 'l':
            if (numCount != 2) return false;
            CGPathAddLineToPoint(path, NULL, numbers[0], numbers[1]);
            currentX = lastControlX = numbers[0];
            currentY = lastControlY = numbers[1];
            numCount = 0;
            break;
        case 'c':
            if (numCount != 6) return false;
            CGPathAddCurveToPoint(
                path, NULL,
                numbers[0], numbers[1],
                numbers[2], numbers[3],
                numbers[4], numbers[5]
            );
            lastControlX = numbers[2];
            lastControlY = numbers[3];
            currentX = numbers[4];
            currentY = numbers[5];
            numCount = 0;
            break;
        case 'q':
            if (numCount != 4) return false;
            CGPathAddQuadCurveToPoint(
                path, NULL,
                numbers[0], numbers[1],
                numbers[2], numbers[3]
            );
            lastControlX = numbers[0];
            lastControlY = numbers[1];
            currentX = numbers[2];
            currentY = numbers[3];
            numCount = 0;
            break;
        case 't': {
            if (numCount != 2) return false;
            CGFloat reflectedX = currentX * 2.0 - lastControlX;
            CGFloat reflectedY = currentY * 2.0 - lastControlY;
            CGPathAddQuadCurveToPoint(
                path, NULL,
                reflectedX, reflectedY,
                numbers[0], numbers[1]
            );
            lastControlX = reflectedX;
            lastControlY = reflectedY;
            currentX = numbers[0];
            currentY = numbers[1];
            numCount = 0;
            break;
        }
        case 'v':
            if (numCount != 4) return false;
            CGPathAddCurveToPoint(
                path, NULL,
                currentX, currentY,
                numbers[0], numbers[1],
                numbers[2], numbers[3]
            );
            lastControlX = numbers[0];
            lastControlY = numbers[1];
            currentX = numbers[2];
            currentY = numbers[3];
            numCount = 0;
            break;
        case 'y':
            if (numCount != 4) return false;
            CGPathAddCurveToPoint(
                path, NULL,
                numbers[0], numbers[1],
                numbers[2], numbers[3],
                numbers[2], numbers[3]
            );
            currentX = numbers[2];
            currentY = numbers[3];
            numCount = 0;
            break;
        case 'h':
            if (numCount != 0) return false;
            CGPathCloseSubpath(path);
            currentX = 0.0;
            currentY = 0.0;
            break;
        case 'r':
            if (utf8CString[1] != 'e') return false;
            if (numCount != 4) return false;
            CGPathAddRect(
                path, NULL,
                CGRectMake(numbers[0], numbers[1], numbers[2], numbers[3])
            );
            currentX = numbers[2];
            currentY = numbers[3];
            utf8CString++;
            numCount = 0;
            break;
        default:
            return false;
        }
        if (isNumberStart) {
            if (numCount == 6) return false;
            numbers[numCount++] = strtod_l(utf8CString, (char **)&utf8CString, NULL);
        } else {
            utf8CString++;
        }
    }
}

typedef struct PathInfo {
    CFMutableStringRef description;
    CGFloat step;
    CGFloat inverseStep;
} PathInfo;

static void copy_path_iter(void * _Nullable info, const CGPathElement *element) {
    PathInfo *path_info = (PathInfo *)info;
    if (CFStringGetLength(path_info->description) != 0) {
        CFStringAppend(path_info->description, CFSTR(" "));
    }
    UniChar ch;
    int count;
    switch (element->type) {
    case kCGPathElementMoveToPoint:
        ch = 'm';
        count = 2;
        break;
    case kCGPathElementAddLineToPoint:
        ch = 'l';
        count = 2;
        break;
    case kCGPathElementAddQuadCurveToPoint:
        ch = 'q';
        count = 4;
        break;
    case kCGPathElementAddCurveToPoint:
        ch = 'c';
        count = 6;
        break;
    case kCGPathElementCloseSubpath:
        ch = 'h';
        count = 0;
        break;
    default:
        return;
    }
    #pragma clang loop unroll(disable)
    for (int i = 0; i < count; i++) {
        CGFloat value = ((const CGFloat *)element->points)[i];
        if (path_info->step != 0.0) {
            value = path_info->step * round(value * path_info->inverseStep);
        }
        char buffer[64];
        snprintf_l(buffer, sizeof(buffer), NULL, "%g ", value);
        CFStringAppendCString(path_info->description, buffer, kCFStringEncodingUTF8);
    }
    CFStringAppendCharacters(path_info->description, &ch, 1);
}

CFStringRef _CGPathCopyDescription(CGPathRef path, CGFloat step) {
    PathInfo info = {
        CFStringCreateMutable(NULL, 0),
        step,
        1.0 / step
    };
    CGPathApply(path, &info, copy_path_iter);
    return info.description;
}

CGPathRef _CGPathCreateRoundedRect(CGRect rect, CGFloat cornerWidth, CGFloat cornerHeight, bool continuous) {
    if (cornerWidth < 0.0) {
        cornerWidth = 0.0;
    }
    if (cornerHeight < 0.0) {
        cornerHeight = 0.0;
    }
    if (cornerWidth == 0.0 || cornerHeight == 0.0 || CGRectIsEmpty(rect)) {
        return CGPathCreateWithRect(rect, NULL);
    }
    if (continuous) {
        ORBPath rbPath = ORBPathMakeRoundedRect(rect, cornerWidth, cornerHeight, ORBPathRoundedCornerStyleContinuous, NULL);
        CGPathRef cgPath = ORBPathCopyCGPath(rbPath);
        ORBPathRelease(rbPath);
        return cgPath;
    }
    CGFloat width = CGRectGetWidth(rect);
    CGFloat height = CGRectGetHeight(rect);
    if (cornerWidth * 2.0 > width) {
        cornerWidth = nextafter(width * 0.5, 0.0);
    }
    if (cornerHeight * 2.0 > height) {
        cornerHeight = nextafter(height * 0.5, 0.0);
    }
    if (cornerWidth < 0.0 || cornerWidth * 2.0 > width || cornerHeight < 0.0 || cornerHeight * 2.0 > height) {
        return CGPathCreateWithRect(rect, NULL);
    }
    return CGPathCreateWithRoundedRect(rect, cornerWidth, cornerHeight, NULL);
}

#endif
