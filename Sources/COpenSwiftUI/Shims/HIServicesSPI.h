//
//  HIServicesSPI.h
//  COpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete

#ifndef HIServicesSPI_h
#define HIServicesSPI_h

#include "OpenSwiftUIBase.h"

#if OPENSWIFTUI_TARGET_OS_OSX

typedef CF_ENUM(int32_t, AXClientType) {
    kAXClientTypeNoActiveRequestFound = 0,
    kAXClientTypeUnknown,
    kAXClientTypeRaft,
    kAXClientTypeXCUITest,
    kAXClientTypeXCTest,
    kAXClientTypeScripter2,
    kAXClientTypeSystemEvents,
    kAXClientTypeVoiceOver,
    kAXClientTypeAssistiveControl,
    kAXClientTypeFullKeyboardAccess,
    kAXClientTypeDictation,
};

OPENSWIFTUI_EXTERN_C_BEGIN

AXClientType _AXGetClientForCurrentRequestUntrusted(void);
void _AXSetClientIdentificationOverride(AXClientType clientType);

OPENSWIFTUI_EXPORT
bool AXIsClientMakingRequest(void);

OPENSWIFTUI_EXPORT
void AXOverrideIsClientMakingRequest(bool value);

OPENSWIFTUI_EXTERN_C_END

#endif /* OPENSWIFTUI_TARGET_OS_OSX */

#endif /* HIServicesSPI_h */
