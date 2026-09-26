//
//  PathData.h
//  OpenSwiftUI_SPI

#if OPENSWIFTUI_CF_CGTYPES

#ifndef PathData_h
#define PathData_h

#include "OpenSwiftUIBase.h"

#if OPENSWIFTUI_TARGET_OS_DARWIN
#include <CoreGraphics/CoreGraphics.h>
#endif

#if OPENSWIFTUI_RENDERBOX
#include <RenderBox/RenderBox.h>
#else
#include <OpenRenderBox/OpenRenderBox.h>
#endif

OPENSWIFTUI_ASSUME_NONNULL_BEGIN

OPENSWIFTUI_IMPLICIT_BRIDGING_ENABLED

typedef union PathData {
    #if OPENSWIFTUI_TARGET_OS_DARWIN
    CGPathRef cgPath;
    #endif
    #if OPENSWIFTUI_RENDERBOX
    RBPath rbPath;
    #else
    ORBPath rbPath;
    #endif
    uint8_t buffer[0x60];
} PathData;

static inline PathData PathDataMakeEmpty(void) OPENSWIFTUI_SWIFT_NAME(PathData.init());

static inline PathData PathDataMakeEmpty(void) {
    PathData data = {.buffer = {0}};
    return data;
}

OPENSWIFTUI_ASSUME_NONNULL_END

OPENSWIFTUI_IMPLICIT_BRIDGING_DISABLED

#endif /* PathData_h */

#endif /* OPENSWIFTUI_CF_CGTYPES */
