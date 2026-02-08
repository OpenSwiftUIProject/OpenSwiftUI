//
//  interpose.c
//  SharedExample
//
//  Created by Kyle on 2025/10/3.
//

#include <stdbool.h>
#include <stdint.h>
#include <dlfcn.h>
#include <AttributeGraph/AttributeGraph-umbrella.h>

// Forward declare the original
extern bool kdebug_is_enabled(uint32_t debugid);

// Our replacement
static bool my_kdebug_is_enabled(uint32_t debugid) {
    return true;
}

extern const void *$s15OpenSwiftUICore5ColorV8ResolvedVN;

const void *_OpenSwiftUI_ColorResolvedNTD(void) {
    return &$s15OpenSwiftUICore5ColorV8ResolvedVN;
}

extern bool swift_dynamicCast(void *dest, void *src,
                  const void *srcType,
                  const void *targetType,
                  uint64_t flags);

static bool my_swift_dynamicCast(void *dest, void *src, const void *srcType, const void *targetType, uint64_t flags) {
    CFStringRef target_description = AGTypeDescription((AGTypeID)targetType);
    // Check if target_description contains "Color.Resolved"
    if (target_description != NULL) {
        CFRange range = CFStringFind(target_description, CFSTR("Color.Resolved"), 0);
        if (range.location != kCFNotFound) {
            // First try the original cast, if it fails try with OpenSwiftUI's Color.Resolved
            return swift_dynamicCast(dest, src, srcType, targetType, flags) ||
                   swift_dynamicCast(dest, src, srcType, _OpenSwiftUI_ColorResolvedNTD(), flags);
        }
    }
    return swift_dynamicCast(dest, src, srcType, targetType, flags);
}

// Interpose using Mach-O section
typedef struct interpose_s {
    const void *replacement;
    const void *original;
} interpose_t;

__attribute__((used)) static const interpose_t interposers[]
    __attribute__((section("__DATA, __interpose"))) = {
    // Interpose kdebug_is_enabled to always return true to perform Signpost testing with Instruments
    { (const void *)my_kdebug_is_enabled, (const void *)kdebug_is_enabled },
    // Interpose swift_dynamicCast to handle casts to SwiftUI's internal Color.Resolved type to fix SwiftUI.ShapeLayerHelper visit check for Shape.fill API
    { (const void *)my_swift_dynamicCast, (const void *)swift_dynamicCast },
};
