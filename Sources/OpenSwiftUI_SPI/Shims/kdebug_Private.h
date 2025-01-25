//
//  kdebug_Private.h
//  OpenSwiftUI_SPI
//
//  Audited for iOS 18.0
//  Status: Complete

#ifndef kdebug_Private_h
#define kdebug_Private_h

#include "OpenSwiftUIBase.h"

#if OPENSWIFTUI_TARGET_OS_DARWIN

/*
 * Copyright (c) 2000-2018 Apple Inc. All rights reserved.
 *
 * @APPLE_OSREFERENCE_LICENSE_HEADER_START@
 *
 * This file contains Original Code and/or Modifications of Original Code
 * as defined in and that are subject to the Apple Public Source License
 * Version 2.0 (the 'License'). You may not use this file except in
 * compliance with the License. The rights granted to you under the License
 * may not be used to create, or enable the creation or redistribution of,
 * unlawful or unlicensed copies of an Apple operating system, or to
 * circumvent, violate, or enable the circumvention or violation of, any
 * terms of an Apple operating system software license agreement.
 *
 * Please obtain a copy of the License at
 * http://www.opensource.apple.com/apsl/ and read it before using this file.
 *
 * The Original Code and all software distributed under the License are
 * distributed on an 'AS IS' basis, WITHOUT WARRANTY OF ANY KIND, EITHER
 * EXPRESS OR IMPLIED, AND APPLE HEREBY DISCLAIMS ALL SUCH WARRANTIES,
 * INCLUDING WITHOUT LIMITATION, ANY WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE, QUIET ENJOYMENT OR NON-INFRINGEMENT.
 * Please see the License for the specific language governing rights and
 * limitations under the License.
 *
 * @APPLE_OSREFERENCE_LICENSE_HEADER_END@
 */

#include <stdint.h>
#include <stdbool.h>
#include <sys/cdefs.h>

#if OPENSWIFTUI_TARGET_OS_OSX
#include <sys/kdebug.h>
#else

// iOS SDK does not have kdebug.h header, so we define the necessary constants here.

#define KDBG_CLASS_MASK   (0xff000000)
#define KDBG_CLASS_OFFSET (24)
#define KDBG_CLASS_MAX    (0xff)
#define KDBG_SUBCLASS_MASK   (0x00ff0000)
#define KDBG_SUBCLASS_OFFSET (16)
#define KDBG_SUBCLASS_MAX    (0xff)
#define KDBG_CSC_MASK   (0xffff0000)
#define KDBG_CSC_OFFSET (KDBG_SUBCLASS_OFFSET)
#define KDBG_CSC_MAX    (0xffff)
#define KDBG_CODE_MASK   (0x0000fffc)
#define KDBG_CODE_OFFSET (2)
#define KDBG_CODE_MAX    (0x3fff)
#define KDBG_EVENTID_MASK (0xfffffffc)
#define KDBG_FUNC_MASK    (0x00000003)

#pragma mark - Class and subclass definitions

#define DBG_MISC        20

/* The Kernel Debug Sub Classes for DBG_MISC */

#define DBG_MISC_INSTRUMENTS     0x11

#endif

#include <Availability.h>

#pragma mark - user space SPI

/*
* OS components can use the full precision of the "code" field
* (Class, SubClass, Code) to inject events using kdebug_trace() by
* using:
*
* kdebug_trace(KDBG_CODE(DBG_XPC, 15, 1) | DBG_FUNC_NONE, 1, 2, 3, 4);
*
* These trace points can be included in production code, since they
* use reserved, non-overlapping ranges.  The performance impact when
* kernel tracing is not enabled is minimal.  However, when tracing is enabled,
* each tracepoint becomes a syscall.  For this reason, os_signpost(3) is
* recommended instead of kdebug_trace(2).
*
* Classes can be reserved by filing a Radar in xnu | ktrace.
*
* 64-bit arguments may be truncated if the system is using a 32-bit
* kernel.
*
* On error, -1 will be returned and errno will indicate the error.
*/
OPENSWIFTUI_EXPORT int kdebug_trace(uint32_t code, uint64_t arg1, uint64_t arg2, uint64_t arg3,
   uint64_t arg4)
__OSX_AVAILABLE(10.10) __IOS_AVAILABLE(8.2);

/*!
* @function kdebug_trace_string
*
* @discussion
* This function emits strings to kdebug trace along with an ID and allows
* for previously-traced strings to be overwritten and invalidated.
*
* To start tracing a string and generate an ID to use to refer to it:
*
*      string_id = kdebug_trace_string(debugid, 0, "string");
*
* To replace a string previously traced:
*
*      string_id = kdebug_trace_string(debugid, string_id, "new string");
*
* To invalidate a string ID:
*
*      string_id = kdebug_trace_string(debugid, string_id, NULL);
*
* To check for errors:
*
*      if ((int64_t)string_id == -1) { perror("string error") }
*
* @param debugid
* The `debugid` to check if its enabled before tracing and include as
* an argument in the event containing the string.
*
* Some classes or subclasses are reserved for specific uses and are not
* allowed to be used with this function.  No function qualifiers are
* allowed on `debugid`.
*
* @param str_id
* When 0, a new ID will be generated and returned if tracing is
* enabled.
*
* Otherwise `str_id` must contain an ID that was previously generated
* with this function.  Clents should pass NULL in `str` if `str_id`
* is no longer in use.  Otherwise, the string previously mapped to
* `str_id` will be overwritten with the contents of `str`.
*
* @param str
* A NUL-terminated 'C' string containing the characters that should be
* traced alongside `str_id`.
*
* If necessary, the string will be truncated at an
* implementation-defined length.  The string must not be the empty
* string, but can be NULL if a valid `str_id` is provided.
*
* @return
* 0 if tracing is disabled or `debugid` is being filtered out of trace.
* It can also return (int64_t)-1 if an error occured. Otherwise,
* it returns the ID to use to refer to the string in future
* kdebug_trace(2) calls.
*
* The errors that can occur are:
*
* EINVAL
*      There are function qualifiers on `debugid`, `str` is empty, or
*      `str_id` was not generated by this function.
* EPERM
*      The `debugid`'s class or subclass is reserved for internal use.
* EFAULT
*      `str` is an invalid address or NULL when `str_id` is 0.
*/
OPENSWIFTUI_EXPORT uint64_t kdebug_trace_string(uint32_t debugid, uint64_t str_id,
   const char * _Nullable str)
__OSX_AVAILABLE(10.11) __IOS_AVAILABLE(9.0);

/*
* Although the performance impact of kdebug_trace() when kernel
* tracing is not enabled is minimal, it may require the caller to
* perform an expensive calculation/summarization. This cost can be
* skipped by checking the kdebug_is_enabled() predicate:
*
* if (kdebug_is_enabled(KDBG_CODE(DBG_XPC, 15, 1))) {
*     uint64_t arg1 = ...;
*     uint64_t arg2 = ...;
*     kdebug_trace(KDBG_CODE(DBG_XPC, 15, 1) | DBG_FUNC_NONE, arg1, arg2, 0, 0);
* }
*
* If tracing is enabled for the code at the time of the check, 1
* will be returned. Otherwise, 0 will be returned.
*/
OPENSWIFTUI_EXPORT bool kdebug_is_enabled(uint32_t code)
__OSX_AVAILABLE(10.12) __IOS_AVAILABLE(10.0)
__WATCHOS_AVAILABLE(3.0) __TVOS_AVAILABLE(10.0);

#endif

#endif /* kdebug_Private_h */
