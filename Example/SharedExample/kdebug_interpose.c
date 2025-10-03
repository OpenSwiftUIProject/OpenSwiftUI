//
//  kdebug_interpose.c
//  SharedExample
//
//  Created by Kyle on 2025/10/3.
//

// Interpose kdebug_is_enabled to always return true to perform Signpost testing with Instruments

#include <stdbool.h>
#include <stdint.h>
#include <dlfcn.h>

// Forward declare the original
extern bool kdebug_is_enabled(uint32_t debugid);

// Our replacement
static bool my_kdebug_is_enabled(uint32_t debugid) {
    return true;
}

// Interpose using Mach-O section
typedef struct interpose_s {
    const void *replacement;
    const void *original;
} interpose_t;

__attribute__((used)) static const interpose_t interposers[]
    __attribute__((section("__DATA, __interpose"))) = {
    { (const void *)my_kdebug_is_enabled, (const void *)kdebug_is_enabled },
};
