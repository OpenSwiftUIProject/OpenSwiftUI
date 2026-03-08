/*    CoreFoundation.h
    Copyright (c) 1998-2019, Apple Inc. and the Swift project authors
 
    Portions Copyright (c) 2014-2019, Apple Inc. and the Swift project authors
    Licensed under Apache License v2.0 with Runtime Library Exception
    See http://swift.org/LICENSE.txt for license information
    See http://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
*/

#if !defined(__COREFOUNDATION_COREFOUNDATION__)
#define __COREFOUNDATION_COREFOUNDATION__ 1
#define __COREFOUNDATION__ 1

#if !defined(CF_EXCLUDE_CSTD_HEADERS)

#include <sys/types.h>
#include <stdarg.h>
#include <assert.h>
#include <ctype.h>
#include <errno.h>
#include <float.h>
#include <limits.h>
#include <locale.h>
#include <math.h>
#if !defined(__wasi__)
#include <setjmp.h>
#endif
#include <signal.h>
#include <stddef.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

#if defined(__STDC_VERSION__) && (199901L <= __STDC_VERSION__)

#include <inttypes.h>
#include <stdbool.h>
#include <stdint.h>

#endif

#endif

#include "CFBase.h"
#include "CFArray.h"
#include "CFCharacterSet.h"
#include "CFData.h"
#include "CFDictionary.h"
#include "CFNumber.h"
#include "CFString.h"

#if TARGET_OS_OSX || TARGET_OS_IPHONE
#endif

#endif /* ! __COREFOUNDATION_COREFOUNDATION__ */
