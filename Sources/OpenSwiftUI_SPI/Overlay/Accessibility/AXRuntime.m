//
//  AXRuntime.m
//  OpenSwiftUI_SPI
//
//  Audited for 6.5.4
//  Status: Complete

#include "AXRuntime.h"

#if OPENSWIFTUI_TARGET_OS_DARWIN

#include <dlfcn.h>
#include <dispatch/dispatch.h>

void abort_report_np(const char *format, ...) __attribute__((noreturn, format(printf, 1, 2)));

void *AXRuntimeLibrary(void) {
    static void *frameworkLibrary;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        frameworkLibrary = dlopen(
            "/System/Library/PrivateFrameworks/AXRuntime.framework/AXRuntime",
            RTLD_LAZY | RTLD_LOCAL
        );
        if (frameworkLibrary == NULL) {
            abort_report_np("%s", dlerror());
        }
    });
    return frameworkLibrary;
}

NSString *AXOpenSwiftUIInteractionLocationDescriptorDefaultName(void) {
    static NSString * __unsafe_unretained const *symbol;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        symbol = (NSString * __unsafe_unretained const *)dlsym(
            AXRuntimeLibrary(),
            "AXInteractionLocationDescriptorDefaultName"
        );
        if (symbol == NULL) {
            abort_report_np("%s", dlerror());
        }
    });
    return *symbol;
}

#endif /* OPENSWIFTUI_TARGET_OS_DARWIN */
