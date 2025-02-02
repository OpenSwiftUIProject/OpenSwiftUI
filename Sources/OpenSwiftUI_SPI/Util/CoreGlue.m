//
//  CoreGlue.m
//  OpenSwiftUI_SPI
//
//  Audited for iOS 18.0
//  Status: Complete

#include "CoreGlue.h"
#include <dlfcn.h>

#if OPENSWIFTUI_TARGET_OS_DARWIN

void abort_report_np(const char*, ...);

void* OpenSwiftUILibrary();
void * getSwiftUIGlueClassSymbolLoc();

id _initializeCoreGlue() {
    void *location = getSwiftUIGlueClassSymbolLoc();
    Class (*classFunc)(void) = (Class (*)(void))location;
    Class glueClass = classFunc();
    return [[glueClass alloc] init];
}

void* OpenSwiftUILibrary() {
    // Since we are staticlly linking OpenSwiftUI and OpenSwiftUICore into the final binary,
    // we can just use dlopen(NULL, RTLD_LAZY) to get the current macho binary handle
    return dlopen(NULL, RTLD_LAZY);
}

void *getSwiftUIGlueClassSymbolLoc() {
    static void *ptr;
    if (ptr == NULL) {
        @try {
            ptr = dlsym(OpenSwiftUILibrary(), "OpenSwiftUIGlueClass");
        } @finally {
        }
    }
    if (ptr == NULL) {
        const char *error = dlerror();
        abort_report_np("%s", error);
    }
    return ptr;
}

#endif
