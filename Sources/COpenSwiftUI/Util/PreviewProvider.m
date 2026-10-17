//
//  PreviewProvider.m
//  COpenSwiftUI

#include "OpenSwiftUIBase.h"

#if OPENSWIFTUI_TARGET_OS_DARWIN
#include <TargetConditionals.h>
#if TARGET_OS_OSX || TARGET_OS_IOS || TARGET_OS_VISION

#import <Foundation/Foundation.h>
#include <dlfcn.h>
#include <mach/mach.h>
#include <mach-o/loader.h>
#include <os/log.h>
#include <ptrauth.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>

#if defined(__arm64__) || defined(__x86_64__)
#include <os/lock.h>

// Supply native provider conformances without changing type lookup results.
// Runtime compatibility hooks also cover providers loaded after this library.
extern const char $s7SwiftUI16_PreviewProviderMp;
extern const char $s7SwiftUI15PreviewProviderMp;
extern const char $s11OpenSwiftUI16_PreviewProviderMp;
extern const void *swift_getTypeContextDescriptor(const void *type);
extern void swift_registerProtocolConformances(const int32_t *begin, const int32_t *end);
extern __attribute__((swiftcall))
const void *_OpenSwiftUI_LegacyPreviewProviderWitnessType(void);

typedef const void *(*preview_lookup_fn)(const void *, const void *);
typedef const void *(*preview_override_fn)(const void *, const void *, preview_lookup_fn);

// Swift ABI: protocol and conformance descriptors use relative references.
typedef struct {
    uint32_t flags;
    int32_t parent, name;
    uint32_t signature_count, requirement_count;
    int32_t associated_types;
} preview_protocol;

typedef struct {
    int32_t protocol, type, witnesses;
    uint32_t flags;
    const void *protocol_pointer, *type_pointer;
} preview_conformance;

typedef struct preview_registration {
    struct preview_registration *next;
    const void *type;
    int32_t records[2];
    preview_conformance conformances[2];
    const void *witnesses[];
} preview_registration;

static const preview_protocol *const preview_protocols[] = {
    (const void *)&$s7SwiftUI16_PreviewProviderMp,
    (const void *)&$s7SwiftUI15PreviewProviderMp,
};
static preview_lookup_fn preview_lookups[2];
static preview_override_fn preview_previous_overrides[2];
static const void *const *preview_witnesses[2];
static preview_registration *preview_registrations;
static os_unfair_lock preview_registration_lock = OS_UNFAIR_LOCK_INIT;
static bool preview_authenticated_runtime;

#if defined(__arm64__)
#define PREVIEW_PTRAUTH __attribute__((target("pauth")))
#else
#define PREVIEW_PTRAUTH
#endif

PREVIEW_PTRAUTH
static void *preview_strip_code(void *pointer) {
    if (preview_authenticated_runtime) {
#if defined(__arm64__)
        __asm__("xpaci %0" : "+r"(pointer));
#endif
    }
    return pointer;
}

PREVIEW_PTRAUTH
static const void *preview_strip_data(const void *pointer) {
    if (preview_authenticated_runtime) {
#if defined(__arm64__)
        __asm__("xpacd %0" : "+r"(pointer));
#endif
    }
    return pointer;
}

static void *preview_callable(void *pointer) {
    return ptrauth_sign_unauthenticated(preview_strip_code(pointer), ptrauth_key_function_pointer, 0);
}

PREVIEW_PTRAUTH
static const void *preview_protocol_argument(unsigned index, const void *protocol) {
    if (index == 1 && preview_authenticated_runtime) {
#if defined(__arm64__)
        uintptr_t discriminator = 0xe909; // Swift protocol descriptor.
        __asm__("pacda %0, %1" : "+r"(protocol) : "r"(discriminator));
#endif
    }
    return protocol;
}

static const void *preview_original_lookup(unsigned index, const void *type,
                                          const void *protocol, preview_lookup_fn original) {
    // Preserve the original function pointer's signature when chaining hooks.
    if (preview_previous_overrides[index]) {
        return preview_previous_overrides[index](type, protocol, original);
    }
    return ((preview_lookup_fn)preview_callable((void *)original))(type, protocol);
}

static void register_preview_provider(const void *type, unsigned index, preview_lookup_fn original) {
    if (!preview_lookups[0](type, &$s11OpenSwiftUI16_PreviewProviderMp)) {
        return;
    }
    const uint32_t *descriptor = preview_strip_data(swift_getTypeContextDescriptor(type));
    // A nominal generic type can have conditional OSUI conformances. Do not
    // publish an unconditional native conformance for all its specializations.
    if (!descriptor || (descriptor[0] & 0x80)) {
        return;
    }
    os_unfair_lock_lock(&preview_registration_lock);
    for (preview_registration *entry = preview_registrations; entry; entry = entry->next) {
        if (entry->type == descriptor) {
            os_unfair_lock_unlock(&preview_registration_lock);
            return;
        }
    }
    for (unsigned i = 0; i < 2; ++i) {
        if (preview_original_lookup(index, type, preview_protocol_argument(index, preview_protocols[i]), original)) {
            os_unfair_lock_unlock(&preview_registration_lock);
            return;
        }
    }
    size_t words = 2 + preview_protocols[0]->requirement_count + preview_protocols[1]->requirement_count;
    preview_registration *entry = calloc(1, sizeof(*entry) + words * sizeof(void *));
    if (!entry) {
        os_unfair_lock_unlock(&preview_registration_lock);
        return;
    }
    entry->type = descriptor;
    const void **table = entry->witnesses;
    for (unsigned i = 0; i < 2; ++i) {
        preview_conformance *conformance = &entry->conformances[i];
        entry->records[i] = (int32_t)((char *)conformance - (char *)&entry->records[i]);
        conformance->protocol = (int32_t)((char *)&conformance->protocol_pointer - (char *)&conformance->protocol) | 1;
        conformance->type = (int32_t)((char *)&conformance->type_pointer - (char *)&conformance->type);
        conformance->witnesses = (int32_t)((char *)table - (char *)&conformance->witnesses);
        conformance->flags = 1 << 3; // IndirectTypeDescriptor; completed witness table.
        conformance->protocol_pointer = preview_protocols[i];
        conformance->type_pointer = descriptor;
        size_t count = 1 + preview_protocols[i]->requirement_count;
        memcpy(table, preview_witnesses[i], count * sizeof(void *));
        table[0] = conformance;
        if (i == 1) {
            for (size_t j = 1; j < count; ++j) {
                if (table[j] == preview_witnesses[0]) {
                    table[j] = entry->witnesses;
                }
            }
        }
        table += count;
    }
    // The runtime retains these records and tables for the process lifetime.
    swift_registerProtocolConformances(entry->records, entry->records + 2);
    entry->next = preview_registrations;
    preview_registrations = entry;
    os_unfair_lock_unlock(&preview_registration_lock);
}

static const void *preview_runtime_lookup(unsigned index, const void *type,
                                         const void *protocol, preview_lookup_fn original) {
    const void *result = preview_original_lookup(index, type, protocol, original);
    if (result) {
        return result;
    }
    const void *raw_protocol = preview_strip_data(protocol);
    if (raw_protocol != preview_protocols[0] && raw_protocol != preview_protocols[1]) {
        return result;
    }
    const char *enabled = getenv("XCODE_RUNNING_FOR_PREVIEWS");
    if (!enabled || strcmp(enabled, "1") != 0) {
        return result;
    }
    register_preview_provider(type, index, original);
    return preview_original_lookup(index, type, protocol, original);
}

static const void *preview_runtime_lookup_legacy(const void *type, const void *protocol, preview_lookup_fn original) {
    return preview_runtime_lookup(0, type, protocol, original);
}

static const void *preview_runtime_lookup_authenticated(const void *type, const void *protocol, preview_lookup_fn original) {
    return preview_runtime_lookup(1, type, protocol, original);
}

static uintptr_t *preview_override_reference(const uint8_t *instruction) {
#if defined(__arm64__)
    const uint32_t *code = (const uint32_t *)instruction;
    uint32_t adrp = code[0], ldr = code[1], cmp = code[2];
    // Compatibility thunk: adrp; ldr callback; cmp callback, #1.
    if ((adrp & 0x9f000000) != 0x90000000 || (ldr & 0xffc00000) != 0xf9400000 ||
        ((ldr >> 5) & 31) != (adrp & 31) || (cmp & ~0x3e0u) != 0xf100041f ||
        ((cmp >> 5) & 31) != (ldr & 31)) {
        return NULL;
    }
    int64_t pages = ((adrp >> 29) & 3) | ((adrp >> 3) & 0x1ffffc);
    if (pages & 0x100000) pages -= 0x200000;
    uintptr_t page = ((uintptr_t)instruction & ~(uintptr_t)0xfff) + pages * 4096;
    return (uintptr_t *)(page + ((ldr >> 10) & 0xfff) * sizeof(void *));
#elif defined(__x86_64__)
    // Compatibility thunk: movq callback(%rip), %rax; cmpq $1, %rax.
    if (instruction[0] != 0x48 || instruction[1] != 0x8b || instruction[2] != 0x05 ||
        instruction[7] != 0x48 || instruction[8] != 0x83 ||
        instruction[9] != 0xf8 || instruction[10] != 0x01) {
        return NULL;
    }
    int32_t offset;
    memcpy(&offset, instruction + 3, sizeof(offset));
    return (uintptr_t *)((uintptr_t)instruction + 7 + offset);
#endif
}

static uintptr_t *preview_override_slot(preview_lookup_fn function) {
    const uint8_t *code = preview_strip_code((void *)function);
    Dl_info image;
    if (!dladdr(code, &image)) {
        return NULL;
    }
#if defined(__arm64__)
    const unsigned stride = 4;
#else
    const unsigned stride = 1;
#endif
    for (unsigned i = 0; i < 64; i += stride) {
        uintptr_t *slot = preview_override_reference(code + i);
        Dl_info owner;
        if (!slot || !dladdr(slot, &owner) || owner.dli_fbase != image.dli_fbase) {
            continue;
        }
        vm_address_t address = (vm_address_t)slot;
        vm_size_t size = 0;
        vm_region_basic_info_data_64_t info;
        mach_msg_type_number_t count = VM_REGION_BASIC_INFO_COUNT_64;
        mach_port_t object = MACH_PORT_NULL;
        kern_return_t result = vm_region_64(mach_task_self(), &address, &size,
            VM_REGION_BASIC_INFO_64, (vm_region_info_t)&info, &count, &object);
        if (object != MACH_PORT_NULL) mach_port_deallocate(mach_task_self(), object);
        if (result == KERN_SUCCESS && address <= (vm_address_t)slot &&
            size >= sizeof(*slot) && (vm_address_t)slot - address <= size - sizeof(*slot) &&
            (info.protection & VM_PROT_WRITE) && !(info.protection & VM_PROT_EXECUTE)) {
            return slot;
        }
    }
    return NULL;
}

static bool preview_witness_layout_supported(const void *const *table) {
    const uint32_t *descriptor = preview_strip_data(table[0]);
    uint32_t flags = descriptor[3];
    if (flags & ~0x30000u) return false;
    const uint32_t *trailing = descriptor + 4;
    if (flags & 0x10000) trailing += 1 + trailing[0] * 2;
    // The template has no dependent associated types or per-type cache slots.
    return !(flags & 0x20000) || (((const uint16_t *)trailing)[1] >> 1) == 0;
}

PREVIEW_PTRAUTH
static void install_preview_support(void) {
    const char *names[] = {"swift_conformsToProtocol", "swift_conformsToProtocol2"};
    preview_override_fn callbacks[] = {preview_runtime_lookup_legacy, preview_runtime_lookup_authenticated};
    Dl_info image;
    void *lookup = dlsym(RTLD_DEFAULT, names[0]);
    if (!lookup || !dladdr(lookup, &image)) return;
    const struct mach_header *header = image.dli_fbase;
    preview_authenticated_runtime = header->cputype == CPU_TYPE_ARM64 &&
        (header->cpusubtype & ~CPU_SUBTYPE_MASK) == CPU_SUBTYPE_ARM64E;
    preview_lookups[0] = (preview_lookup_fn)preview_callable(lookup);
    const void *type = _OpenSwiftUI_LegacyPreviewProviderWitnessType();
    for (unsigned i = 0; i < 2; ++i) {
        preview_witnesses[i] = preview_lookups[0](type, preview_protocols[i]);
        if (!preview_witnesses[i] || !preview_witness_layout_supported(preview_witnesses[i])) {
            os_log_error(OS_LOG_DEFAULT, "OpenSwiftUI could not prepare legacy preview witnesses.");
            return;
        }
    }
    for (unsigned i = 0; i < 2; ++i) {
        lookup = dlsym(RTLD_DEFAULT, names[i]);
        if (!lookup) continue;
        preview_lookups[i] = (preview_lookup_fn)preview_callable(lookup);
        uintptr_t *slot = preview_override_slot(preview_lookups[i]);
        if (!slot || !preview_lookups[i](type, preview_protocol_argument(i, preview_protocols[0]))) {
            os_log_error(OS_LOG_DEFAULT, "OpenSwiftUI could not find the %{public}s compatibility hook.", names[i]);
            continue;
        }
        // Initialize the runtime's cache first and retain an existing override.
        uintptr_t previous = __atomic_load_n(slot, __ATOMIC_ACQUIRE);
        if (!previous) continue;
        preview_previous_overrides[i] = previous == 1 ? NULL : (preview_override_fn)preview_callable((void *)previous);
        void *replacement = preview_strip_code((void *)callbacks[i]);
        if (preview_authenticated_runtime) {
#if defined(__arm64__)
            __asm__("paciza %0" : "+r"(replacement));
#endif
        }
        __atomic_store_n(slot, (uintptr_t)replacement, __ATOMIC_RELEASE);
    }
}

// -ObjC retains this class when COpenSwiftUI is linked as a static library.
@interface _OpenSwiftUIPreviewProviderSupport : NSObject
@end
@implementation _OpenSwiftUIPreviewProviderSupport
+ (void)load {
    const char *enabled = getenv("XCODE_RUNNING_FOR_PREVIEWS");
    if (enabled && strcmp(enabled, "1") == 0) {
        install_preview_support();
    }
}
@end

#undef PREVIEW_PTRAUTH
#endif /* __arm64__ || __x86_64__ */
#endif /* TARGET_OS_OSX || TARGET_OS_IOS || TARGET_OS_VISION */
#endif /* OPENSWIFTUI_TARGET_OS_DARWIN */
