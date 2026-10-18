//
//  PreviewProvider.m
//  COpenSwiftUI

#include "OpenSwiftUIBase.h"

#if OPENSWIFTUI_TARGET_OS_DARWIN

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

// Xcode asks the Swift runtime whether the original provider type conforms to
// SwiftUI's protocols. For an OSUI provider, supply those conformances on demand:
//   1. Let the runtime (and any earlier hook) find an existing conformance.
//   2. If none exists, copy the Swift bridge's witnesses for this concrete type.
//   3. Register the copies and repeat the lookup through the runtime.
// This preserves type identity and also covers providers loaded later by JIT.
// Import rebinding cannot cover direct calls inside the device shared cache.
extern const char $s7SwiftUI16_PreviewProviderMp;
extern const char $s7SwiftUI15PreviewProviderMp;
extern const char $s11OpenSwiftUI16_PreviewProviderMp;
extern const void *swift_conformsToProtocol(const void *type, const void *protocol);
extern const void *swift_getTypeContextDescriptor(const void *type);
extern void swift_registerProtocolConformances(const int32_t *begin, const int32_t *end);
extern __attribute__((swiftcall))
const void *_OpenSwiftUI_LegacyPreviewProviderWitnessType(void);

typedef const void *(*preview_lookup_fn)(const void *, const void *);
typedef const void *(*preview_override_fn)(const void *, const void *, preview_lookup_fn);

typedef struct {
    const char *symbol;
    bool signed_protocol;
    preview_override_fn previous;
} preview_runtime_hook;

// These are two runtime entry points, independent of the two provider protocols.
static preview_runtime_hook preview_legacy_hook = {
    .symbol = "swift_conformsToProtocol",
};
static preview_runtime_hook preview_authenticated_hook = {
    .symbol = "swift_conformsToProtocol2",
    .signed_protocol = true,
};

enum {
    preview_base_protocol, // _PreviewProvider: enumeration and preview traits.
    preview_full_protocol, // PreviewProvider: native preview host creation.
    preview_protocol_count,
};

// Swift ABI layouts: ProtocolDescriptor and ProtocolConformanceDescriptor.
// Each int32_t reference is relative to its own field, not to the struct base.
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
    const void *type_descriptor;
    int32_t records[preview_protocol_count];
    preview_conformance conformances[preview_protocol_count];
    const void *witnesses[];
} preview_registration;

static const preview_protocol *const preview_protocols[preview_protocol_count] = {
    [preview_base_protocol] = (const void *)&$s7SwiftUI16_PreviewProviderMp,
    [preview_full_protocol] = (const void *)&$s7SwiftUI15PreviewProviderMp,
};
static const void *const *preview_witnesses[preview_protocol_count];
static preview_registration *preview_registrations;
static os_unfair_lock preview_registration_lock = OS_UNFAIR_LOCK_INIT;
static bool preview_authenticated_runtime;

// An arm64 app can call an arm64e system runtime. Compiler ptrauth helpers alone
// are no-ops in that app, so use explicit PAC instructions when the runtime is
// arm64e. Keep these conversions at the runtime boundary.
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
static const void *preview_protocol_argument(const preview_runtime_hook *hook, const void *protocol) {
    // The legacy entry takes an unsigned descriptor; the newer entry takes a
    // Swift protocol descriptor signed with the data key and discriminator.
    if (hook->signed_protocol && preview_authenticated_runtime) {
#if defined(__arm64__)
        uintptr_t discriminator = 0xe909; // Swift protocol descriptor.
        __asm__("pacda %0, %1" : "+r"(protocol) : "r"(discriminator));
#endif
    }
    return protocol;
}

static const void *preview_original_lookup(const preview_runtime_hook *hook, const void *type,
                                          const void *protocol, preview_lookup_fn original) {
    // Preserve the original function pointer's signature when chaining hooks.
    if (hook->previous) {
        return hook->previous(type, protocol, original);
    }
    return ((preview_lookup_fn)preview_callable((void *)original))(type, protocol);
}

static void register_preview_provider(const void *type, const preview_runtime_hook *hook,
                                      preview_lookup_fn original) {
    if (!swift_conformsToProtocol(type, &$s11OpenSwiftUI16_PreviewProviderMp)) {
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
        if (entry->type_descriptor == descriptor) {
            os_unfair_lock_unlock(&preview_registration_lock);
            return;
        }
    }
    for (unsigned i = 0; i < preview_protocol_count; ++i) {
        // Use the original path here: another native lookup through our hook
        // would recursively try to register this same provider under the lock.
        if (preview_original_lookup(hook, type, preview_protocol_argument(hook, preview_protocols[i]), original)) {
            os_unfair_lock_unlock(&preview_registration_lock);
            return;
        }
    }
    size_t words = preview_protocol_count;
    for (unsigned i = 0; i < preview_protocol_count; ++i) {
        words += preview_protocols[i]->requirement_count;
    }
    // Keep records, descriptors, pointer slots and tables in one allocation so
    // all relative offsets fit in 32 bits, even when the target image is far away.
    preview_registration *entry = calloc(1, sizeof(*entry) + words * sizeof(void *));
    if (!entry) {
        os_unfair_lock_unlock(&preview_registration_lock);
        return;
    }
    entry->type_descriptor = descriptor;
    const void **table = entry->witnesses;
    for (unsigned i = 0; i < preview_protocol_count; ++i) {
        preview_conformance *conformance = &entry->conformances[i];
        entry->records[i] = (int32_t)((char *)conformance - (char *)&entry->records[i]);
        // The protocol's low bit means indirect. The type reference uses the
        // IndirectTypeDescriptor flag instead; both point to local pointer slots.
        conformance->protocol = (int32_t)((char *)&conformance->protocol_pointer - (char *)&conformance->protocol) | 1;
        conformance->type = (int32_t)((char *)&conformance->type_pointer - (char *)&conformance->type);
        conformance->witnesses = (int32_t)((char *)table - (char *)&conformance->witnesses);
        conformance->flags = 1 << 3; // IndirectTypeDescriptor; completed witness table.
        conformance->protocol_pointer = preview_protocols[i];
        conformance->type_pointer = descriptor;
        size_t count = 1 + preview_protocols[i]->requirement_count;
        memcpy(table, preview_witnesses[i], count * sizeof(void *));
        table[0] = conformance; // The table must describe this type, not the template.
        if (i == preview_full_protocol) {
            // Redirect the inherited _PreviewProvider witness to this type's
            // copied table. The remaining entries are shared Swift implementations.
            for (size_t j = 1; j < count; ++j) {
                if (table[j] == preview_witnesses[preview_base_protocol]) {
                    table[j] = entry->witnesses;
                }
            }
        }
        table += count;
    }
    // The runtime retains these records and tables for the process lifetime.
    // Registration also invalidates previously cached conformance misses.
    swift_registerProtocolConformances(entry->records, entry->records + preview_protocol_count);
    entry->next = preview_registrations;
    preview_registrations = entry;
    os_unfair_lock_unlock(&preview_registration_lock);
}

static const void *preview_runtime_lookup(const preview_runtime_hook *hook, const void *type,
                                         const void *protocol, preview_lookup_fn original) {
    const void *result = preview_original_lookup(hook, type, protocol, original);
    if (result) {
        return result;
    }
    const void *raw_protocol = preview_strip_data(protocol);
    if (raw_protocol != preview_protocols[preview_base_protocol] &&
        raw_protocol != preview_protocols[preview_full_protocol]) {
        return result;
    }
    const char *enabled = getenv("XCODE_RUNNING_FOR_PREVIEWS");
    if (!enabled || strcmp(enabled, "1") != 0) {
        return result;
    }
    register_preview_provider(type, hook, original);
    return preview_original_lookup(hook, type, protocol, original);
}

static const void *preview_runtime_lookup_legacy(const void *type, const void *protocol, preview_lookup_fn original) {
    return preview_runtime_lookup(&preview_legacy_hook, type, protocol, original);
}

static const void *preview_runtime_lookup_authenticated(const void *type, const void *protocol, preview_lookup_fn original) {
    return preview_runtime_lookup(&preview_authenticated_hook, type, protocol, original);
}

// Swift's compatibility thunks cache an override callback in writable memory.
// There is no exported setter. Locate that cache from the thunk's instructions;
// do not patch executable pages. These patterns are runtime implementation
// details, not Swift ABI. If the cache-load pattern is not recognized, do not
// install this hook.
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
    // Only resilient witnesses and a generic witness-table header may follow.
    // Other flags can introduce trailing data that this fixed template cannot use.
    if (flags & ~0x30000u) return false;
    const uint32_t *trailing = descriptor + 4;
    if (flags & 0x10000) trailing += 1 + trailing[0] * 2;
    // The template has no dependent associated types or per-type cache slots.
    return !(flags & 0x20000) || (((const uint16_t *)trailing)[1] >> 1) == 0;
}

PREVIEW_PTRAUTH
static void install_preview_hook(preview_runtime_hook *hook, preview_override_fn callback, const void *type) {
    void *symbol = dlsym(RTLD_DEFAULT, hook->symbol);
    if (!symbol) return;
    preview_lookup_fn lookup = (preview_lookup_fn)preview_callable(symbol);
    uintptr_t *slot = preview_override_slot(lookup);
    if (!slot || !lookup(type, preview_protocol_argument(hook, preview_protocols[preview_base_protocol]))) {
        os_log_error(OS_LOG_DEFAULT, "OpenSwiftUI could not find the %{public}s compatibility hook.", hook->symbol);
        return;
    }
    // The cache is 0 before initialization, 1 for no override, or a callback.
    // The lookup above initializes it before we replace it; otherwise the
    // runtime's first lookup could overwrite our callback. Chain an earlier hook.
    uintptr_t previous = __atomic_load_n(slot, __ATOMIC_ACQUIRE);
    if (!previous) return;
    hook->previous = previous == 1 ? NULL : (preview_override_fn)preview_callable((void *)previous);
    void *replacement = preview_strip_code((void *)callback);
    if (preview_authenticated_runtime) {
#if defined(__arm64__)
        // The validated arm64e thunks use an IA-key signature with discriminator
        // zero. Recheck this together with the instruction patterns for new runtimes.
        __asm__("paciza %0" : "+r"(replacement));
#endif
    }
    __atomic_store_n(slot, (uintptr_t)replacement, __ATOMIC_RELEASE);
}

static void install_preview_support(void) {
    Dl_info image;
    void *lookup = dlsym(RTLD_DEFAULT, preview_legacy_hook.symbol);
    if (!lookup || !dladdr(lookup, &image)) return;
    const struct mach_header *header = image.dli_fbase;
    preview_authenticated_runtime = header->cputype == CPU_TYPE_ARM64 &&
        (header->cpusubtype & ~CPU_SUBTYPE_MASK) == CPU_SUBTYPE_ARM64E;
    const void *type = _OpenSwiftUI_LegacyPreviewProviderWitnessType();
    for (unsigned i = 0; i < preview_protocol_count; ++i) {
        preview_witnesses[i] = swift_conformsToProtocol(type, preview_protocols[i]);
        if (!preview_witnesses[i] || !preview_witness_layout_supported(preview_witnesses[i])) {
            os_log_error(OS_LOG_DEFAULT, "OpenSwiftUI could not prepare legacy preview witnesses.");
            return;
        }
    }
    install_preview_hook(&preview_legacy_hook, preview_runtime_lookup_legacy, type);
    install_preview_hook(&preview_authenticated_hook, preview_runtime_lookup_authenticated, type);
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
#endif /* OPENSWIFTUI_TARGET_OS_DARWIN */
