#include <stdint.h>

#if defined(__ANDROID__)

#define EXPORT_SWIFT_DESCRIPTOR(storage_name, symbol_name) \
    __attribute__((visibility("default"), used, aligned(8))) \
    uintptr_t storage_name[8] __asm__(symbol_name) = { 0 }

EXPORT_SWIFT_DESCRIPTOR(
    OpenSwiftUIAndroidShimNSCFBoolean,
    "$s10Foundation13__NSCFBooleanCN"
);

EXPORT_SWIFT_DESCRIPTOR(
    OpenSwiftUIAndroidShimBigStringIndex,
    "$s22_FoundationCollections9BigStringV5IndexVMn"
);

#endif
