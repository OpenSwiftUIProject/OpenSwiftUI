//
//  OpenSwiftUI_CSymbols.h
//  OpenSwiftUI_SPI

#ifndef OpenSwiftUI_CSymbols_h
#define OpenSwiftUI_CSymbols_h

#include "OpenSwiftUIBase.h"

OPENSWIFTUI_ASSUME_NONNULL_BEGIN

const char * _Nullable getSymbolPathName(const void *address);

#if OPENSWIFTUI_TARGET_OS_WASI
const void * _Nullable _OpenSwiftUI_conformsToProtocol(
    const void *type,
    const void *protocolDescriptor
);
#endif

OPENSWIFTUI_ASSUME_NONNULL_END

#endif /* OpenSwiftUI_CSymbols_h */
