//
//  interpose.c
//  Shared
//
//  Created by Kyle on 2025/10/3.
//

#include <stdbool.h>
#include <stdint.h>
#include <dlfcn.h>
#include <os/log.h>

#if __has_include(<AttributeGraph/AttributeGraph.h>)
#include <AttributeGraph/AttributeGraph.h>
#elif __has_include(<Compute/Compute.h>)
#include <Compute/Compute.h>
#else
#include <OpenAttributeGraph/OpenAttributeGraph.h>
#endif

// MARK: - Type Description Shim

static inline CFStringRef _interpose_type_description(const void *type) {
#if __has_include(<AttributeGraph/AttributeGraph.h>) || __has_include(<Compute/Compute.h>)
    return AGTypeDescription((AGTypeID)type);
#else
    return OAGTypeDescription((OAGTypeID)type);
#endif
}

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
    CFStringRef targetDescription = _interpose_type_description(targetType);
    CFStringRef srcDescription = _interpose_type_description(srcType);
    if (targetDescription != NULL && srcDescription != NULL &&
        (CFStringHasPrefix(targetDescription, CFSTR("SwiftUI.")) ||
         CFStringHasPrefix(targetDescription, CFSTR("SwiftUICore."))) &&
        (CFStringHasPrefix(srcDescription, CFSTR("OpenSwiftUI.")) ||
         CFStringHasPrefix(srcDescription, CFSTR("OpenSwiftUICore.")))) {
        os_log_info(OS_LOG_DEFAULT, "[OpenSwiftUI] swift_dynamicCast failed for target: %{public}@ src: %{public}@", targetDescription, srcDescription);
    }
    // If dynamicCast check failed and the target is SwiftUI's Color.Resolved
    // retry with OpenSwiftUI's Color.Resolved
    if (targetType == &$s7SwiftUI5ColorV8ResolvedVN) {
        result = swift_dynamicCast(dest, src, srcType, _OpenSwiftUI_ColorResolvedNTD(), flags);
        if (result) {
            CFStringRef description = _interpose_type_description(srcType);
            os_log_info(OS_LOG_DEFAULT, "[OpenSwiftUI] swift_dynamicCast succeeded for %{public}@", description);
        }
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
    CFStringRef protocolDescription = _interpose_type_description(protocol);
    CFStringRef typeDescription = _interpose_type_description(type);
    if (protocolDescription != NULL && typeDescription != NULL &&
        (CFStringHasPrefix(protocolDescription, CFSTR("SwiftUI.")) ||
         CFStringHasPrefix(protocolDescription, CFSTR("SwiftUICore."))) &&
        (CFStringHasPrefix(typeDescription, CFSTR("OpenSwiftUI.")) ||
         CFStringHasPrefix(typeDescription, CFSTR("OpenSwiftUICore.")))) {
        os_log_info(OS_LOG_DEFAULT, "[OpenSwiftUI] swift_conformsToProtocol2 failed for protocol: %{public}@ type: %{public}@", protocolDescription, typeDescription);
    }
    // If conformance check failed and the protocol is SwiftUI's PlatformDrawable,
    // retry with OpenSwiftUI's PlatformDrawable
    if (protocol == &$s7SwiftUI16PlatformDrawableMp) {
        result = swift_conformsToProtocol2(type, _OpenSwiftUI_PlatformDrawablePD());
        if (result != NULL) {
            CFStringRef description = _interpose_type_description(type);
            os_log_info(OS_LOG_DEFAULT, "[OpenSwiftUI] swift_conformsToProtocol2 succeeded for %{public}@", description);
        }
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
