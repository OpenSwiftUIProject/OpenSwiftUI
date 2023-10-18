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

typedef struct LockedPointerData_s {
    os_unfair_lock lock;
    uint32_t offset;
} LockedPointerData;

typedef LockedPointerData *LockedPointer __attribute((swift_newtype(struct)));

LockedPointer _Nonnull _LockedPointerCreate(size_t size);

void * _Nonnull _LockedPointerGetAddress(LockedPointer _Nonnull ptr);

void _LockedPointerDelete(LockedPointer _Nonnull ptr);

void _LockedPointerUnlock(LockedPointer _Nonnull ptr);

void _LockedPointerLock(LockedPointer _Nonnull ptr);

#endif /* LockedPointer_h */
