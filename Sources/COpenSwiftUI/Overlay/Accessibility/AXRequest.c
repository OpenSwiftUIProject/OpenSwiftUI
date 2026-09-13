//
//  AXRequest.c
//  COpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete

#include "Shims/HIServicesSPI.h"

#if OPENSWIFTUI_TARGET_OS_OSX

bool AXIsClientMakingRequest(void) {
    return _AXGetClientForCurrentRequestUntrusted() != kAXClientTypeNoActiveRequestFound;
}

void AXOverrideIsClientMakingRequest(bool value) {
    _AXSetClientIdentificationOverride(value ? kAXClientTypeUnknown : kAXClientTypeNoActiveRequestFound);
}

#endif /* OPENSWIFTUI_TARGET_OS_OSX */
