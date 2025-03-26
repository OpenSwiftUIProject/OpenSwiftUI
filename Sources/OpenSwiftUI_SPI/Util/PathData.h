//
//  PathData.h
//  OpenSwiftUI_SPI

#ifndef PathData_h
#define PathData_h

#include "OpenSwiftUIBase.h"

#if OPENSWIFTUI_TARGET_OS_DARWIN
#include <CoreGraphics/CoreGraphics.h>

typedef union PathData {
    CGPathRef cgPath;
    void * obPath; // FIXME
} PathData;

#else
typedef union PathData {
    void *cgPath;
    void *obPath; // FIXME
} PathData;
#endif

#endif /* PathData_h */
