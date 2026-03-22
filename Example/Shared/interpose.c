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
#include <CoreFoundation/CoreFoundation.h>

// MARK: - Type Description Shim

// swift_getTypeName returns the module-qualified name (e.g. "OpenSwiftUI.CGDrawingView")
// unlike AGTypeDescription which only returns the short name (e.g. "CGDrawingView").
struct _interpose_type_name_pair {
    const char *data;
    uintptr_t length;
};
extern __attribute__((swiftcall))
struct _interpose_type_name_pair swift_getTypeName(const void *type, bool qualified);

static inline CFStringRef _interpose_type_description(const void *type) {
    struct _interpose_type_name_pair name = swift_getTypeName(type, true);
    if (name.data == NULL || name.length == 0) {
        return NULL;
    }
    CFStringRef result = CFStringCreateWithBytes(
        kCFAllocatorDefault, (const UInt8 *)name.data, (CFIndex)name.length,
        kCFStringEncodingUTF8, false);
    CFAutorelease(result);
    return result;
}

// MARK: - Protocol Description Shim

// ProtocolDescriptor is a ContextDescriptor, not type metadata,
// so AGTypeDescription/OAGTypeDescription cannot be used on it.
// Read the name directly from the ContextDescriptor binary layout:
//   offset 0: uint32_t Flags
//   offset 4: int32_t  Parent (relative indirectable pointer)
//   offset 8: int32_t  Name   (relative direct pointer to const char*)
static inline CFStringRef _interpose_protocol_description(const void *protocol) {
    const uint8_t *base = (const uint8_t *)protocol;

    // Resolve Name (relative direct pointer at offset 8)
    int32_t name_offset = *(const int32_t *)(base + 8);
    const char *name = (const char *)(base + 8 + (intptr_t)name_offset);

    // Resolve Parent (relative indirectable pointer at offset 4)
    int32_t parent_raw = *(const int32_t *)(base + 4);
    if (parent_raw != 0) {
        const void *parent;
        if (parent_raw & 1) {
            // Indirect: low bit set, mask it out and dereference
            const void **indirect = (const void **)(base + 4 + (intptr_t)(parent_raw & ~1));
            parent = *indirect;
        } else {
            // Direct: offset as-is
            parent = (const void *)(base + 4 + (intptr_t)parent_raw);
        }
        if (parent != NULL) {
            // ModuleContextDescriptor.Name is also at offset 8
            const uint8_t *parent_base = (const uint8_t *)parent;
            int32_t module_name_offset = *(const int32_t *)(parent_base + 8);
            const char *module_name = (const char *)(parent_base + 8 + (intptr_t)module_name_offset);
            CFStringRef result = CFStringCreateWithFormat(kCFAllocatorDefault, NULL, CFSTR("%s.%s"), module_name, name);
            CFAutorelease(result);
            return result;
        }
    }

    CFStringRef result = CFStringCreateWithCString(kCFAllocatorDefault, name, kCFStringEncodingUTF8);
    CFAutorelease(result);
    return result;
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
    CFStringRef protocolDescription = _interpose_protocol_description(protocol);
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
            os_log_info(OS_LOG_DEFAULT, "[OpenSwiftUI] swift_conformsToProtocol2 succeeded via OpenSwiftUI fallback for %{public}@", description);
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
