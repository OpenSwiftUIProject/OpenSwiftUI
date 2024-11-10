//
//  OpenSwiftUIBase.h
//  OpenSwiftUI
//
//  Audited for iOS 15.5
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

#define OPENSWIFTUI_ENUM CF_ENUM

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

#endif /* OpenSwiftUIBase_h */
