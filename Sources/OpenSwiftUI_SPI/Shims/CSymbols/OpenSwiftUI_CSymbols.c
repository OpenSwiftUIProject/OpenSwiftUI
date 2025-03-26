//
//  OpenSwiftUI_CSymbols.c
//  OpenSwiftUI_SPI

#include "OpenSwiftUI_CSymbols.h"
#include <dlfcn.h>

const char * getSymbolPathName(const void *address) {
    Dl_info info;
    int result = dladdr(address, &info);
    if (result == 0) {
        return NULL;
    }
    return info.dli_fname;
}
