//
//  MovableLock.c
//  OpenSwiftUI
//
//  Audited for RELEASE_2021
//  Status: Complete

#include "MovableLock.h"
#include <stdlib.h>
#include <assert.h>

#if !OPENSWIFTUI_TARGET_OS_WASI
#include <dispatch/dispatch.h>
#endif

#if OPENSWIFTUI_TARGET_OS_DARWIN
extern pthread_t pthread_main_thread_np(void);
#endif

void wait_for_lock(MovableLock lock, pthread_t thread);
void sync_main_callback(MovableLock lock);

MovableLock _MovableLockCreate() {
    #if OPENSWIFTUI_TARGET_OS_DARWIN
    static_assert(sizeof(MovableLock_t) == 0x100, "MovebleLock size is not 0x100 bytes.");
    #endif
    MovableLock lock = calloc(1, sizeof(MovableLock_t));
    if (!lock) {
        abort();
    }
    pthread_mutex_init(&lock->mutex, NULL);
    pthread_cond_init(&lock->cond1, NULL);
    pthread_cond_init(&lock->cond2, NULL);
    pthread_cond_init(&lock->cond3, NULL);
    #if OPENSWIFTUI_TARGET_OS_DARWIN
    lock->main = pthread_main_thread_np();
    #endif
    return lock;
}

void _MovableLockDestory(MovableLock lock) {
    pthread_cond_destroy(&lock->cond1);
    pthread_cond_destroy(&lock->cond2);
    pthread_cond_destroy(&lock->cond3);
    pthread_mutex_destroy(&lock->mutex);
    free(lock);
}

bool _MovableLockIsOwner(MovableLock lock) {
    return pthread_self() == lock->owner;
}

bool _MovableLockIsOuterMostOwner(MovableLock lock) {
    return pthread_self() == lock->owner && lock->level == 1;
}

void _MovableLockLock(MovableLock lock) {
    #if OPENSWIFTUI_TARGET_OS_DARWIN
    pthread_t owner = pthread_self();
    if (owner == lock->owner) {
        lock->level += 1;
        return;
    }
    pthread_mutex_lock(&lock->mutex);
    while (lock->owner) {
        wait_for_lock(lock, owner);
    }
    lock->owner = owner;
    lock->level = 1;
    #endif
}

void _MovableLockUnlock(MovableLock lock) {
    #if OPENSWIFTUI_TARGET_OS_DARWIN
    lock->level -= 1;
    if (lock->level != 0) {
        return;
    }
    if (lock->unknown != 0) {
        pthread_cond_signal(&lock->cond1);
    }
    lock->owner = NULL;
    pthread_mutex_unlock(&lock->mutex);
    #endif
}

void _MovableLockSyncMain(MovableLock lock, const void *context, void (*function)(const void *context)) {
    #if OPENSWIFTUI_TARGET_OS_DARWIN
    if (pthread_self() == lock->main) {
        function(context);
    } else {
        lock->function = function;
        lock->context = context;
        if (lock->unknown5) {
            pthread_cond_signal_thread_np(&lock->cond1, lock->main);
        } else if (!lock->unknown4) {
            lock->unknown4 = true;
            dispatch_async_f(dispatch_get_main_queue(), lock, (dispatch_function_t)&sync_main_callback);
            if (lock->unknown5) {
                pthread_cond_signal_thread_np(&lock->cond1, lock->main);
            }
        }
        while (lock->function) {
            pthread_cond_wait(&lock->cond2, &lock->mutex);
        }
    }
    #endif
}

void _MovableLockWait(MovableLock lock) {
    #if OPENSWIFTUI_TARGET_OS_DARWIN
    pthread_t owner = pthread_self();
    uint32_t level = lock->level;
    lock->level = 0;
    lock->owner = NULL;
    if (lock->unknown != 0) {
        pthread_cond_broadcast(&lock->cond1);
    }
    pthread_cond_wait(&lock->cond3, &lock->mutex);
    while (lock->owner) {
        wait_for_lock(lock, owner);
    }
    lock->owner = owner;
    lock->level = level;
    #endif
}

void _MovableLockBroadcast(MovableLock lock) {
    #if OPENSWIFTUI_TARGET_OS_DARWIN
    pthread_cond_broadcast(&lock->cond3);
    #endif
}

void wait_for_lock(MovableLock lock, pthread_t owner) {
    #if OPENSWIFTUI_TARGET_OS_DARWIN
    lock->unknown += 1;
    if (lock->main == owner) {
        lock->unknown5 = 1;
        if (lock->function) {
            uint32_t original_level = lock->level;
            pthread_t original_owner = lock->owner;
            lock->owner = lock->main;
            lock->level = original_level + 1;
            lock->function(lock->context);
            lock->level = original_level;
            lock->owner = original_owner;
            lock->function = NULL;
            lock->context = NULL;
            pthread_cond_signal(&lock->cond2);
        }
    }
    pthread_cond_wait(&lock->cond1, &lock->mutex);
    if (lock->main == owner) {
        lock->unknown5 = 0;
    }
    lock->unknown -= 1;
    #endif
}

void sync_main_callback(MovableLock lock) {
    #if OPENSWIFTUI_TARGET_OS_DARWIN
    _MovableLockLock(lock);
    lock->unknown4 = 0;
    _MovableLockUnlock(lock);
    #endif
}
