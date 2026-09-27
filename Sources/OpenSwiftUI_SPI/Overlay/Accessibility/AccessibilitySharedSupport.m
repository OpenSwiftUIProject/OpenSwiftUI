//
//  AccessibilitySharedSupport.m
//  OpenSwiftUI_SPI
//
//  Audited for 6.5.4
//  Status: Complete

#include "AccessibilitySharedSupport.h"

#if OPENSWIFTUI_TARGET_OS_DARWIN

#include <dlfcn.h>
#include <stdlib.h>
#include <string.h>

void abort_report_np(const char *format, ...) __attribute__((noreturn, format(printf, 1, 2)));

static void *AccessibilitySharedSupportLibraryCore(char **error) {
    static void *frameworkLibrary;
    if (frameworkLibrary == NULL) {
        frameworkLibrary = dlopen(
            "/System/Library/PrivateFrameworks/AccessibilitySharedSupport.framework/AccessibilitySharedSupport",
            RTLD_LAZY | RTLD_LOCAL
        );
        if (frameworkLibrary == NULL) {
            *error = strdup(dlerror());
        }
    }
    return frameworkLibrary;
}

static void *AccessibilitySharedSupportLibrary(void) {
    char *error = NULL;
    void *frameworkLibrary = AccessibilitySharedSupportLibraryCore(&error);
    if (frameworkLibrary == NULL) {
        abort_report_np("%s", error);
    }
    if (error != NULL) {
        free(error);
    }
    return frameworkLibrary;
}

static void *getAXSSAccessibilityDescriptionForSymbolNameSymbolLoc(void) {
    static void *ptr;
    if (ptr == NULL) {
        ptr = dlsym(
            AccessibilitySharedSupportLibrary(),
            "AXSSAccessibilityDescriptionForSymbolName"
        );
    }
    return ptr;
}

NSString *soft_AXSSAccessibilityDescriptionForSymbolName(NSString *symbolName, NSString *localeIdentifier) {
    NSString *(*function)(NSString *, NSString *) =
        (NSString *(*)(NSString *, NSString *))getAXSSAccessibilityDescriptionForSymbolNameSymbolLoc();
    if (function == NULL) {
        abort_report_np("%s", dlerror());
    }
    return function(symbolName, localeIdentifier);
}

#endif /* OPENSWIFTUI_TARGET_OS_DARWIN */
