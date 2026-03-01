//
//  GraphicsServices.m
//  OpenSwiftUI_SPI
//
//  Status: Complete

#include "GraphicsServices.h"

#if OPENSWIFTUI_TARGET_OS_DARWIN

#include <dlfcn.h>

NSString * _SimulatorSystemRootDirectory(void) {
    typedef NSString * (*GSSystemRootDirectoryFunc)(void);
    static GSSystemRootDirectoryFunc gsFunc;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        gsFunc = (GSSystemRootDirectoryFunc)dlsym(RTLD_DEFAULT, "GSSystemRootDirectory");
    });
    return gsFunc ? gsFunc() : @"";
}

#endif /* OPENSWIFTUI_TARGET_OS_DARWIN */
