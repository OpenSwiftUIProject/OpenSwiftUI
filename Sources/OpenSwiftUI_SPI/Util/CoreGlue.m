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
void * getOpenSwiftUIGlueClassSymbolLoc();
void * getOpenSwiftUIGlue2ClassSymbolLoc();

id _initializeCoreGlue() {
    void *location = getOpenSwiftUIGlueClassSymbolLoc();
    Class (*classFunc)(void) = (Class (*)(void))location;
    Class glueClass = classFunc();
    return [[glueClass alloc] init];
}

id _initializeCoreGlue2() {
    void *location = getOpenSwiftUIGlue2ClassSymbolLoc();
    Class (*classFunc)(void) = (Class (*)(void))location;
    Class glue2Class = classFunc();
    return [[glue2Class alloc] init];
}

void *getOpenSwiftUIGlueClassSymbolLoc() {
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

void *getOpenSwiftUIGlue2ClassSymbolLoc() {
    static void *ptr;
    if (ptr == NULL) {
        @try {
            ptr = dlsym(OpenSwiftUILibrary(), "OpenSwiftUIGlue2Class");
        } @finally {
        }
    }
    if (ptr == NULL) {
        const char *error = dlerror();
        abort_report_np("%s", error);
    }
    return ptr;
}


void* OpenSwiftUILibrary() {
    // Since we are staticlly linking OpenSwiftUI and OpenSwiftUICore into the final binary,
    // we can just use dlopen(NULL, RTLD_LAZY) to get the current macho binary handle
    return dlopen(NULL, RTLD_LAZY);
}

#endif
