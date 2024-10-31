//
//  OpenSwiftUIViewSystem.h
//  OpenSwiftUI_SPI
//
//  Audited for RELEASE_2024
//  Status: Complete

#ifndef OpenSwiftUIViewSystem_h
#define OpenSwiftUIViewSystem_h

#include "OpenSwiftUIBase.h"

typedef OPENSWIFTUI_ENUM(uint8_t, OpenSwiftUIViewSystem) {
    OpenSwiftUIViewSystemUIView,
    OpenSwiftUIViewSystemNSView,
    OpenSwiftUIViewSystemSwiftUIView,
} OPENSWIFTUI_SWIFT_NAME(ViewSystem);

#endif /* OpenSwiftUIViewSystem_h */
