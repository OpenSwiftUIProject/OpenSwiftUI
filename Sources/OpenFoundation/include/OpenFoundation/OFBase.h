/*    OFBase.h
    Copyright (c) 1998-2019, Apple Inc. and the Swift project authors

    Portions Copyright (c) 2014-2019, Apple Inc. and the Swift project authors
    Licensed under Apache License v2.0 with Runtime Library Exception
    See http://swift.org/LICENSE.txt for license information
    See http://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
*/

#if !defined(__OPENFOUNDATION_OFBASE__)
#define __OPENFOUNDATION_OFBASE__ 1

#include "TargetConditionals.h"
#include "OFAvailability.h"

#if (defined(__CYGWIN32__) || defined(_WIN32)) && !defined(__WIN32__)
#define __WIN32__ 1
#endif

#if defined(_WIN64) && !defined(__WIN64__)
#define __WIN64__ 1
#endif

#if defined(__WIN64__) && !defined(__LLP64__)
#define __LLP64__ 1
#endif

#if defined(_MSC_VER) && defined(_M_IX86)
#define __i386__ 1
#endif

#if (defined(__i386__) || defined(__x86_64__)) && !defined(__LITTLE_ENDIAN__)
#define __LITTLE_ENDIAN__ 1
#endif

#if !defined(__BIG_ENDIAN__) && !defined(__LITTLE_ENDIAN__)
#error Do not know the endianess of this architecture
#endif

#if !__BIG_ENDIAN__ && !__LITTLE_ENDIAN__
#error Both __BIG_ENDIAN__ and __LITTLE_ENDIAN__ cannot be false
#endif

#if __BIG_ENDIAN__ && __LITTLE_ENDIAN__
#error Both __BIG_ENDIAN__ and __LITTLE_ENDIAN__ cannot be true
#endif

// Some compilers provide the capability to test if certain features are available. This macro provides a compatibility path for other compilers.
#ifndef __has_feature
#define __has_feature(x) 0
#endif

// Some compilers provide the capability to test if certain attributes are available. This macro provides a compatibility path for other compilers.
#ifndef __has_attribute
#define __has_attribute(x) 0
#endif

#ifndef __has_extension
#define __has_extension(x) 0
#endif

#if defined(__GNUC__) || TARGET_OS_WIN32
#include <stdint.h>
#endif

#if !defined(OF_EXTERN_C_BEGIN)
#if defined(__cplusplus)
#define OF_EXTERN_C_BEGIN extern "C" {
#define OF_EXTERN_C_END   }
#else
#define OF_EXTERN_C_BEGIN
#define OF_EXTERN_C_END
#endif
#endif

#if TARGET_OS_WIN32
    #if defined(__cplusplus)
        #define _OF_EXTERN extern "C"
    #else
        #define _OF_EXTERN extern
    #endif

    #if defined(_WINDLL)
        #if defined(CoreFoundation_EXPORTS) || defined(OF_BUILDING_OF)
            #define OF_EXPORT _OF_EXTERN __declspec(dllexport)
        #else
            #define OF_EXPORT _OF_EXTERN __declspec(dllimport)
        #endif
    #else
        #define OF_EXPORT _OF_EXTERN
    #endif
#else
#define OF_EXPORT extern
#endif

OF_EXTERN_C_BEGIN

#if !defined(NULL)
#if defined(__GNUG__)
    #define NULL __null
#elif defined(__cplusplus)
    #define NULL 0
#else
    #define NULL ((void *)0)
#endif
#endif

#if !defined(TRUE)
    #define TRUE    1
#endif

#if !defined(FALSE)
    #define FALSE    0
#endif

#if !defined(OF_INLINE)
    #if defined(__GNUC__) && (__GNUC__ == 4) && !defined(DEBUG)
        #define OF_INLINE static __inline__ __attribute__((always_inline))
    #elif defined(__GNUC__)
        #define OF_INLINE static __inline__
    #elif defined(__cplusplus)
    #define OF_INLINE static inline
    #elif defined(_MSC_VER)
        #define OF_INLINE static __inline
    #elif TARGET_OS_WIN32
    #define OF_INLINE static __inline__
    #endif
#endif

#if __has_feature(assume_nonnull)
#define OF_ASSUME_NONNULL_BEGIN _Pragma("clang assume_nonnull begin")
#define OF_ASSUME_NONNULL_END   _Pragma("clang assume_nonnull end")
#else
#define OF_ASSUME_NONNULL_BEGIN
#define OF_ASSUME_NONNULL_END
#endif


#if !__has_feature(nullability)
#ifndef _Nullable
#define _Nullable
#endif
#ifndef _Nonnull
#define _Nonnull
#endif
#ifndef _Null_unspecified
#define _Null_unspecified
#endif
#endif


#if __has_attribute(swift_private)
# define OF_REFINED_FOR_SWIFT __attribute__((swift_private))
#else
# define OF_REFINED_FOR_SWIFT
#endif


#if __has_attribute(swift_name)
# define OF_SWIFT_NAME(_name) __attribute__((swift_name(#_name)))
#else
# define OF_SWIFT_NAME(_name)
#endif

#if __has_attribute(__swift_attr__)
#  define OF_SWIFT_UNAVAILABLE_FROM_ASYNC(msg) __attribute__((__swift_attr__("@_unavailableFromAsync(message: \"" msg "\")")))
#else
#  define OF_SWIFT_UNAVAILABLE_FROM_ASYNC(msg)
#endif

#if __has_attribute(noescape)
#define OF_NOESCAPE __attribute__((noescape))
#else
#define OF_NOESCAPE
#endif

#if __has_attribute(not_tail_called)
#define OF_NO_TAIL_CALL __attribute__((not_tail_called))
#else
#define OF_NO_TAIL_CALL
#endif

#if __has_attribute(warn_unused_result)
#define OF_WARN_UNUSED_RESULT __attribute__((warn_unused_result))
#else
#define OF_WARN_UNUSED_RESULT
#endif

#if __has_attribute(fallthrough)
#define OF_FALLTHROUGH __attribute__((fallthrough))
#else
#define OF_FALLTHROUGH
#endif

OF_EXTERN_C_END

#endif /* ! __OPENFOUNDATION_OFBASE__ */
