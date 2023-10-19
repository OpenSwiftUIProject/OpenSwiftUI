/*    OFAvailability.h
    Copyright (c) 2013-2019, Apple Inc. and the Swift project authors

    Portions Copyright (c) 2014-2019, Apple Inc. and the Swift project authors
    Licensed under Apache License v2.0 with Runtime Library Exception
    See http://swift.org/LICENSE.txt for license information
    See http://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
*/

#if !defined(__OPENFOUNDATION_OFAVAILABILITY__)
#define __OPENFOUNDATION_OFAVAILABILITY__ 1

#include "TargetConditionals.h"

// Enums and Options
#if __has_attribute(enum_extensibility)
#define __OF_ENUM_ATTRIBUTES __attribute__((enum_extensibility(open)))
#define __OF_CLOSED_ENUM_ATTRIBUTES __attribute__((enum_extensibility(closed)))
#define __OF_OPTIONS_ATTRIBUTES __attribute__((flag_enum,enum_extensibility(open)))
#else
#define __OF_ENUM_ATTRIBUTES
#define __OF_CLOSED_ENUM_ATTRIBUTES
#define __OF_OPTIONS_ATTRIBUTES
#endif

#define __OF_NAMED_ENUM(_type, _name)     enum __OF_ENUM_ATTRIBUTES _name : _type _name; enum _name : _type
#define __OF_ANON_ENUM(_type)             enum __OF_ENUM_ATTRIBUTES : _type
#define OF_CLOSED_ENUM(_type, _name)      enum __OF_CLOSED_ENUM_ATTRIBUTES _name : _type _name; enum _name : _type
#if (__cplusplus)
#define OF_OPTIONS(_type, _name) __attribute__((availability(swift,unavailable))) _type _name; enum __OF_OPTIONS_ATTRIBUTES : _name
#else
#define OF_OPTIONS(_type, _name) enum __OF_OPTIONS_ATTRIBUTES _name : _type _name; enum _name : _type
#endif


#if __has_attribute(swift_wrapper)
#define _OF_TYPED_ENUM __attribute__((swift_wrapper(enum)))
#else
#define _OF_TYPED_ENUM
#endif

#if __has_attribute(swift_wrapper)
#define _OF_TYPED_EXTENSIBLE_ENUM __attribute__((swift_wrapper(struct)))
#else
#define _OF_TYPED_EXTENSIBLE_ENUM
#endif

#define OF_STRING_ENUM _OF_TYPED_ENUM
#define OF_EXTENSIBLE_STRING_ENUM _OF_TYPED_EXTENSIBLE_ENUM

#define OF_TYPED_ENUM _OF_TYPED_ENUM
#define OF_TYPED_EXTENSIBLE_ENUM _OF_TYPED_EXTENSIBLE_ENUM


#ifndef OF_SWIFT_BRIDGED_TYPEDEF
#if __has_attribute(swift_bridged_typedef)
#define OF_SWIFT_BRIDGED_TYPEDEF __attribute__((swift_bridged_typedef))
#else
#define OF_SWIFT_BRIDGED_TYPEDEF
#endif
#endif

#endif // __OPENFOUNDATION_OFAVAILABILITY__
