//
//  AXChartDescriptor.m
//  OpenSwiftUI_SPI
//
//  Audited for 6.5.4
//  Status: Complete

#include "AXChartDescriptor.h"

#if OPENSWIFTUI_TARGET_OS_DARWIN

id _Nullable _AXOpenSwiftUIUnarchiveChartDescriptor(NSData *data) {
    // Preserve support for dictionaries archived without secure coding.
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    return [NSKeyedUnarchiver unarchiveTopLevelObjectWithData:data error:NULL];
#pragma clang diagnostic pop
}

#endif /* OPENSWIFTUI_TARGET_OS_DARWIN */
