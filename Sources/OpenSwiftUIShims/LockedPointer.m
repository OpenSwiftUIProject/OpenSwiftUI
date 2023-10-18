//
//  LockedPointer.c
//  
//
//  Created by Kyle on 2023/10/19.
//

#import "LockedPointer.h"

LockedPointer _LockedPointerCreate(size_t size) {
    LockedPointer ptr = malloc(size);
    if (ptr == NULL) { abort(); }
    ptr->lock = OS_UNFAIR_LOCK_INIT;
    ptr->offset = 8;
    return ptr;
}

void *_LockedPointerGetAddress(LockedPointer ptr) {
    return (void *)((uintptr_t)ptr + (uintptr_t)(ptr->offset));
}

void _LockedPointerDelete(LockedPointer ptr) {
    free(ptr);
}

void _LockedPointerUnlock(LockedPointer ptr) {
    os_unfair_lock_unlock(&ptr->lock);
}

void _LockedPointerLock(LockedPointer ptr) {
    os_unfair_lock_lock(&ptr->lock);
}
