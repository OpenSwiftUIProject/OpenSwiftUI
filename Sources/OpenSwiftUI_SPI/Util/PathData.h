//
//  PathData.h
//  OpenSwiftUI_SPI

#ifndef PathData_h
#define PathData_h

#include "OpenSwiftUIBase.h"

#if OPENSWIFTUI_TARGET_OS_DARWIN

#include <CoreGraphics/CoreGraphics.h>
#include <OpenRenderBoxShims/OpenRenderBoxShims.h>

OPENSWIFTUI_ASSUME_NONNULL_BEGIN

OPENSWIFTUI_IMPLICIT_BRIDGING_ENABLED

typedef union PathData {
    CGPathRef _Nullable cgPath;
    ORBPath rbPath;
    uint8_t buffer[0x60];
} PathData;

static inline PathData PathDataMakeEmpty(void) OPENSWIFTUI_SWIFT_NAME(PathData.init());

static inline PathData PathDataMakeEmpty(void) {
    PathData data = {.buffer = {0}};
    return data;
}

OPENSWIFTUI_ASSUME_NONNULL_END

OPENSWIFTUI_IMPLICIT_BRIDGING_DISABLED

#endif /* OPENSWIFTUI_TARGET_OS_DARWIN */

#endif /* PathData_h */
