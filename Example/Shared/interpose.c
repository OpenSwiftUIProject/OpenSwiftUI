//
//  interpose.c
//  Shared
//
//  Created by Kyle on 2025/10/3.
//

#include <stdbool.h>
#include <stdint.h>
#include <dlfcn.h>

// Forward declare the original
extern bool kdebug_is_enabled(uint32_t debugid);

// Our replacement
static bool my_kdebug_is_enabled(uint32_t debugid) {
    return true;
}

// MARK: - Color.Resolved Nominal Type Descriptor

extern const void $s7SwiftUI5ColorV8ResolvedVN;
extern const void *$s15OpenSwiftUICore5ColorV8ResolvedVN;

const void *_OpenSwiftUI_ColorResolvedNTD(void) {
    return &$s15OpenSwiftUICore5ColorV8ResolvedVN;
}

// MARK: - swift_dynamicCast

extern bool swift_dynamicCast(void *dest, void *src,
                  const void *srcType,
                  const void *targetType,
                  uint64_t flags);

static bool my_swift_dynamicCast(void *dest, void *src, const void *srcType, const void *targetType, uint64_t flags) {
    bool result = swift_dynamicCast(dest, src, srcType, targetType, flags);
    if (result) {
        return result;
    }
    // If dynamicCast check failed and the target is SwiftUI's Color.Resolved
    // retry with OpenSwiftUI's Color.Resolved
    if (targetType == &$s7SwiftUI5ColorV8ResolvedVN) {
        result = swift_dynamicCast(dest, src, srcType, _OpenSwiftUI_ColorResolvedNTD(), flags);
    }
    return result;
}

// MARK: - PlatformDrawable Protocol Descriptor

extern const void $s7SwiftUI16PlatformDrawableMp;
extern const void $s15OpenSwiftUICore16PlatformDrawableMp;

const void *_OpenSwiftUI_PlatformDrawablePD(void) {
    return &$s15OpenSwiftUICore16PlatformDrawableMp;
}

// MARK: - swift_conformsToProtocol2

extern const void *swift_conformsToProtocol2(const void *type, const void *protocol);

static const void *my_swift_conformsToProtocol2(const void *type, const void *protocol) {
    
    const void *result = swift_conformsToProtocol2(type, protocol);
    if (result != NULL) {
        return result;
    }
    // If conformance check failed and the protocol is SwiftUI's PlatformDrawable,
    // retry with OpenSwiftUI's PlatformDrawable
    if (protocol == &$s7SwiftUI16PlatformDrawableMp) {
        result = swift_conformsToProtocol2(type, _OpenSwiftUI_PlatformDrawablePD());
    }
    return result;
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
    // Interpose swift_conformsToProtocol2 to redirect SwiftUI.PlatformDrawable conformance checks to OpenSwiftUI.PlatformDrawable
    { (const void *)my_swift_conformsToProtocol2, (const void *)swift_conformsToProtocol2 },
};
