//
//  OpenSwiftUIShims.h
//  OpenSwiftUI_SPI
//

#ifndef OpenSwiftUIShims_h
#define OpenSwiftUIShims_h

#include "OpenSwiftUIBase.h"

#if OPENSWIFTUI_TARGET_OS_DARWIN

#include <os/log.h>

OPENSWIFTUI_ASSUME_NONNULL_BEGIN

OPENSWIFTUI_EXPORT
os_log_t openSwiftUIShimsLog(void);

#define OPENSWIFTUI_SHIMS_LOG_ERROR(fmt, ...) os_log_error(openSwiftUIShimsLog(), fmt, ##__VA_ARGS__)

#define OPENSWIFTUI_SAFE_WRAPPER_IMP(ReturnType, SelectorName, DefaultReturnValue, ...) \
    typedef ReturnType (*Func)(id, SEL, ##__VA_ARGS__); \
    SEL selector = NSSelectorFromString(SelectorName); \
    Func func = nil; \
    if ([self respondsToSelector:selector]) { \
        IMP impl = class_getMethodImplementation([self class], selector); \
        func = (Func)impl; \
    } else { \
        OPENSWIFTUI_SHIMS_LOG_ERROR("%@ can't respond to selector %@", NSStringFromClass([self class]), NSStringFromSelector(selector)); \
    } \
    if (func == nil) { \
        OPENSWIFTUI_SHIMS_LOG_ERROR("%@ can't get method implementation for selector %@", NSStringFromClass([self class]), NSStringFromSelector(selector)); \
        return DefaultReturnValue; \
    }


OPENSWIFTUI_ASSUME_NONNULL_END

#endif /* OPENSWIFTUI_TARGET_OS_DARWIN */

#endif /* OpenSwiftUIShims_h */
