//
//  OpenSwiftUIBase.h
//  
//
//

#ifndef OpenSwiftUIBase_h
#define OpenSwiftUIBase_h

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

#endif /* OpenSwiftUIBase_h */
