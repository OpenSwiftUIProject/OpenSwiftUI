//
//  LockedPointer.h
//  
//
//  Created by Kyle on 2023/10/18.
//

#ifndef LockedPointer_h
#define LockedPointer_h

#include <stdio.h>
#include <os/lock.h>
#include <CoreFoundation/CoreFoundation.h>

/**
 |<--------lock-------->|    padding    |<--------data---------->|
 |<------8  bytes------>|
 |<------------offset------------>|<--------size---------->|
 |                                                                                                                             |
 |<------------------LockedPointerData------------------->|
 */
typedef struct LockedPointerData_s {
    os_unfair_lock lock;
    uint32_t offset;
} LockedPointerData;

typedef LockedPointerData *LockedPointer __attribute((swift_newtype(struct)));

/// Create a LockedPointer
/// - Parameters:
///   - size: Size of data type
///   - alignment: Alignment of data type
LockedPointer _Nonnull _LockedPointerCreate(size_t size, size_t alignment);

/// Get the pointer address of data
void * _Nonnull _LockedPointerGetAddress(LockedPointer _Nonnull ptr);

/// Delete and clean up the LockedPointer's content
void _LockedPointerDelete(LockedPointer _Nonnull ptr);

/// Unlock the LockedPointer's lock
void _LockedPointerUnlock(LockedPointer _Nonnull ptr);

/// Lock the LockedPointer's lock
void _LockedPointerLock(LockedPointer _Nonnull ptr);

#endif /* LockedPointer_h */
