//
//  OpenSwiftUIViewSystem.h
//  OpenSwiftUI_SPI
//
//  Audited for 6.5.4
//  Status: Complete

#ifndef OpenSwiftUIViewSystem_h
#define OpenSwiftUIViewSystem_h

#include "OpenSwiftUIBase.h"

typedef OPENSWIFTUI_CLOSED_ENUM(uint8_t, OpenSwiftUIViewSystem) {
    OpenSwiftUIViewSystemUIView,
    OpenSwiftUIViewSystemNSView,
    OpenSwiftUIViewSystemCALayer,
} OPENSWIFTUI_SWIFT_NAME(ViewSystem);

#endif /* OpenSwiftUIViewSystem_h */
