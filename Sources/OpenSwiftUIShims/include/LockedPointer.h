//
//  LockedPointer.h
//  
//
//  Created by Kyle on 2023/10/18.
//

#ifndef LockedPointer_h
#define LockedPointer_h

#include <OpenFoundation/OpenFoundation.h>

#if __has_include(<os/lock.h>)
#include <os/lock.h>
#define OPENSWIFTUI_LOCK_T os_unfair_lock
#define OPENSWIFTUI_LOCK_INIT OS_UNFAIR_LOCK_INIT
#define OPENSWIFTUI_LOCK_LOCK(lock) os_unfair_lock_lock(lock)
#define OPENSWIFTUI_LOCK_UNLOCK(lock) os_unfair_lock_unlock(lock)
#elif TARGET_OS_LINUX
#define OPENSWIFTUI_LOCK_T int32_t
#include <stdint.h>
#include <unistd.h>
OF_INLINE void __OPENSWIFTUI_Lock(volatile OPENSWIFTUI_LOCK_T * _Nonnull lock) {
  while (__sync_val_compare_and_swap(lock, 0, ~0) != 0) {
    sleep(0);
  }
}

OF_INLINE void __OPENSWIFTUI_Unlock(volatile OPENSWIFTUI_LOCK_T * _Nonnull lock) {
  __sync_synchronize();
  *lock = 0;
}
#define OPENSWIFTUI_LOCK_INIT 0
#define OPENSWIFTUI_LOCK_LOCK(lock) __OPENSWIFTUI_Lock(lock)
#define OPENSWIFTUI_LOCK_UNLOCK(lock) __OPENSWIFTUI_Unlock(lock)
#endif

/**
 |<--------lock-------->|    padding    |<--------data---------->|
 |<------8  bytes------>|
 |<------------offset------------>|<--------size---------->|
 |                                                                                                                             |
 |<------------------LockedPointerData------------------->|
 */
typedef struct LockedPointerData_s {
    OPENSWIFTUI_LOCK_T lock;
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
