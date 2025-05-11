//
//  OpenSwiftUIShims.m
//  OpenSwiftUI_SPI
//

#import "OpenSwiftUIShims.h"

#if OPENSWIFTUI_TARGET_OS_DARWIN

os_log_t openSwiftUIShimsLog(void) {
    static dispatch_once_t onceToken;
    static os_log_t log = NULL;
    dispatch_once(&onceToken, ^{
        log = os_log_create("org.OpenSwiftUIProject.OpenSwiftUI", "Shims");
    });
    return log;
}

#endif /* OPENSWIFTUI_TARGET_OS_DARWIN */
