//
//  RenderUtil.c
//  OpenSwiftUI_SPI

#include "RenderUtil.h"

uint32_t _HighFrameRateReasonMake(uint32_t value) {
    return value | 0x270000;
}

bool _VariableFrameDurationIsSupported() {
    #if OPENSWIFTUI_TARGET_OS_IPHONE && !OPENSWIFTUI_TARGET_OS_SIMULATOR
    static bool supported;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        supported = false; // MGIsDeviceOneOfType
    });
    return supported;
    #else
    return false;
    #endif
}
