//
//  OpenSwiftUIBase.h
//  OpenSwiftUI
//
//  Audited for 3.5.2
//  Status: Complete

#ifndef OpenSwiftUIBase_h
#define OpenSwiftUIBase_h

#include <CoreFoundation/CoreFoundation.h>
#include <stdint.h>
#include <stdbool.h>
#include <stdio.h>
#include "OpenSwiftUITargetConditionals.h"

#if defined(__cplusplus)
#define OPENSWIFTUI_INLINE inline
#else
#define OPENSWIFTUI_INLINE
#endif

#if defined(__cplusplus)
#define OPENSWIFTUI_EXTERN_C_BEGIN extern "C" {
#define OPENSWIFTUI_EXTERN_C_END   }
#else
#define OPENSWIFTUI_EXTERN_C_BEGIN
#define OPENSWIFTUI_EXTERN_C_END
#endif

#if __has_feature(assume_nonnull)
#define OPENSWIFTUI_ASSUME_NONNULL_BEGIN _Pragma("clang assume_nonnull begin")
#define OPENSWIFTUI_ASSUME_NONNULL_END   _Pragma("clang assume_nonnull end")
#else
#define OPENSWIFTUI_ASSUME_NONNULL_BEGIN
#define OPENSWIFTUI_ASSUME_NONNULL_END
#endif

#if OPENSWIFTUI_TARGET_OS_WIN32
    #if defined(__cplusplus)
        #define _OPENSWIFTUI_EXTERN extern "C"
    #else
        #define _OPENSWIFTUI_EXTERN extern
    #endif

    #if defined(_WINDLL)
        #if defined(OPENSWIFTUI_EXPORTS)
            #define OPENSWIFTUI_EXPORT _OPENSWIFTUI_EXTERN __declspec(dllexport)
        #else
            #define OPENSWIFTUI_EXPORT _OPENSWIFTUI_EXTERN __declspec(dllimport)
        #endif
    #else
        #define OPENSWIFTUI_EXPORT _OPENSWIFTUI_EXTERN
    #endif
#else
#define OPENSWIFTUI_EXPORT extern
#endif

#if __has_attribute(swift_private)
# define OPENSWIFTUI_REFINED_FOR_SWIFT __attribute__((swift_private))
#else
# define OPENSWIFTUI_REFINED_FOR_SWIFT
#endif

#if __has_attribute(swift_name)
# define OPENSWIFTUI_SWIFT_NAME(_name) __attribute__((swift_name(#_name)))
#else
# define OPENSWIFTUI_SWIFT_NAME(_name)
#endif

#if __has_attribute(swift_wrapper)
#define OPENSWIFTUI_SWIFT_STRUCT __attribute__((swift_wrapper(struct)))
#else
#define OPENSWIFTUI_SWIFT_STRUCT
#endif

#define OPENSWIFTUI_ENUM CF_ENUM
#define OPENSWIFTUI_CLOSED_ENUM CF_CLOSED_ENUM
#define OPENSWIFTUI_OPTIONS CF_OPTIONS

#ifndef OPENSWIFTUI_IMPLICIT_BRIDGING_ENABLED
#if __has_feature(arc_cf_code_audited)
#define OPENSWIFTUI_IMPLICIT_BRIDGING_ENABLED _Pragma("clang arc_cf_code_audited begin")
#else
#define OPENSWIFTUI_IMPLICIT_BRIDGING_ENABLED
#endif
#endif

#ifndef OPENSWIFTUI_IMPLICIT_BRIDGING_DISABLED
#if __has_feature(arc_cf_code_audited)
#define OPENSWIFTUI_IMPLICIT_BRIDGING_DISABLED _Pragma("clang arc_cf_code_audited end")
#else
#define OPENSWIFTUI_IMPLICIT_BRIDGING_DISABLED
#endif
#endif

// Marks functions which return a CF type that needs to be released by the caller but whose names are not consistent with CoreFoundation naming rules. The recommended fix to this is to rename the functions, but this macro can be used to let the clang static analyzer know of any exceptions that cannot be fixed.
// This macro is ONLY to be used in exceptional circumstances, not to annotate functions which conform to the CoreFoundation naming rules.
#ifndef OPENSWIFTUI_RETURNS_RETAINED
#if __has_feature(attribute_cf_returns_retained)
#define OPENSWIFTUI_RETURNS_RETAINED __attribute__((cf_returns_retained))
#else
#define OPENSWIFTUI_RETURNS_RETAINED
#endif
#endif

// Marks functions which return a CF type that may need to be retained by the caller but whose names are not consistent with CoreFoundation naming rules. The recommended fix to this is to rename the functions, but this macro can be used to let the clang static analyzer know of any exceptions that cannot be fixed.
// This macro is ONLY to be used in exceptional circumstances, not to annotate functions which conform to the CoreFoundation naming rules.
#ifndef OPENSWIFTUI_RETURNS_NOT_RETAINED
#if __has_feature(attribute_cf_returns_not_retained)
#define OPENSWIFTUI_RETURNS_NOT_RETAINED __attribute__((cf_returns_not_retained))
#else
#define OPENSWIFTUI_RETURNS_NOT_RETAINED
#endif
#endif

#endif /* OpenSwiftUIBase_h */
