//
//  OpenSwiftUI_CSymbols.c
//  OpenSwiftUI_SPI

#include "OpenSwiftUI_CSymbols.h"
#if !OPENSWIFTUI_TARGET_OS_WASI
#include <dlfcn.h>
#endif

const char * getSymbolPathName(const void *address) {
    #if OPENSWIFTUI_TARGET_OS_WASI
    return NULL;
    #else
    Dl_info info;
    int result = dladdr(address, &info);
    if (result == 0) {
        return NULL;
    }
    return info.dli_fname;
    #endif
}

#if OPENSWIFTUI_TARGET_OS_WASI
extern const void *swift_conformsToProtocol(
    const void *type,
    const void *protocolDescriptor
);

const void *_OpenSwiftUI_conformsToProtocol(
    const void *type,
    const void *protocolDescriptor
) {
    return swift_conformsToProtocol(type, protocolDescriptor);
}
#endif
