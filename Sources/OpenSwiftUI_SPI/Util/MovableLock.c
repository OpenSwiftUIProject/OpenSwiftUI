//
//  MovableLock.c
//  OpenSwiftUI
//
//  Audited for 6.5.4
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

static void wait_for_lock(MovableLock lock, pthread_t thread);
static void sync_main_callback(MovableLock lock);

MovableLock _MovableLockCreate() {
    #if OPENSWIFTUI_TARGET_OS_DARWIN
    static_assert(sizeof(MovableLock_t) == 0x100, "MovebleLock size is not 0x100 bytes.");
    #endif
    MovableLock lock = calloc(1, sizeof(MovableLock_t));
    if (!lock) {
        abort();
    }
    pthread_mutex_init(&lock->mutex, NULL);
    pthread_cond_init(&lock->lock_condition, NULL);
    pthread_cond_init(&lock->main_callback_condition, NULL);
    pthread_cond_init(&lock->broadcast_condition, NULL);
    #if OPENSWIFTUI_TARGET_OS_DARWIN
    lock->main_thread = pthread_main_thread_np();
    #endif
    return lock;
}

void _MovableLockDestroy(MovableLock lock) {
    pthread_cond_destroy(&lock->lock_condition);
    pthread_cond_destroy(&lock->main_callback_condition);
    pthread_cond_destroy(&lock->broadcast_condition);
    pthread_mutex_destroy(&lock->mutex);
    free(lock);
}

bool _MovableLockIsOwner(MovableLock lock) {
    pthread_t owner = lock->owner_thread;
    return pthread_self() == owner;
}

bool _MovableLockIsOutermostOwner(MovableLock lock) {
    pthread_t owner = lock->owner_thread;
    return pthread_self() == owner && lock->lock_level == 1;
}

void _MovableLockLock(MovableLock lock) {
    #if OPENSWIFTUI_TARGET_OS_DARWIN
    pthread_t owner = pthread_self();
    if (owner == lock->owner_thread) {
        lock->lock_level += 1;
        return;
    }
    pthread_mutex_lock(&lock->mutex);
    while (lock->owner_thread) {
        [[clang::noinline]]
        wait_for_lock(lock, owner);
    }
    lock->owner_thread = owner;
    lock->lock_level = 1;
    #endif
}

void _MovableLockUnlock(MovableLock lock) {
    #if OPENSWIFTUI_TARGET_OS_DARWIN
    lock->lock_level -= 1;
    if (lock->lock_level != 0) {
        return;
    }
    if (lock->waiter_count != 0) {
        pthread_cond_signal(&lock->lock_condition);
    }
    lock->owner_thread = NULL;
    pthread_mutex_unlock(&lock->mutex);
    #endif
}

void _MovableLockSyncMain(MovableLock lock, const void *main_callback_context, void (*main_callback)(const void *main_callback_context)) {
    #if OPENSWIFTUI_TARGET_OS_DARWIN
    if (pthread_self() == lock->main_thread) {
        main_callback(main_callback_context);
    } else {
        lock->main_callback = main_callback;
        lock->main_callback_context = main_callback_context;
        if (lock->main_thread_waiting) {
            pthread_cond_signal_thread_np(&lock->lock_condition, lock->main_thread);
        } else if (!lock->main_callback_pending) {
            lock->main_callback_pending = true;
            dispatch_async_f(dispatch_get_main_queue(), lock, (dispatch_function_t)&sync_main_callback);
            if (lock->main_thread_waiting) {
                pthread_cond_signal_thread_np(&lock->lock_condition, lock->main_thread);
            }
        }
        while (lock->main_callback) {
            pthread_cond_wait(&lock->main_callback_condition, &lock->mutex);
        }
    }
    #endif
}

void _MovableLockWait(MovableLock lock) {
    #if OPENSWIFTUI_TARGET_OS_DARWIN
    pthread_t owner = pthread_self();
    uint32_t level = lock->lock_level;
    lock->lock_level = 0;
    lock->owner_thread = NULL;
    if (lock->waiter_count != 0) {
        pthread_cond_broadcast(&lock->lock_condition);
    }
    pthread_cond_wait(&lock->broadcast_condition, &lock->mutex);
    while (lock->owner_thread) {
        [[clang::noinline]]
        wait_for_lock(lock, owner);
    }
    lock->owner_thread = owner;
    lock->lock_level = level;
    #endif
}

void _MovableLockBroadcast(MovableLock lock) {
    #if OPENSWIFTUI_TARGET_OS_DARWIN
    pthread_cond_broadcast(&lock->broadcast_condition);
    #endif
}

static void wait_for_lock(MovableLock lock, pthread_t owner) {
    #if OPENSWIFTUI_TARGET_OS_DARWIN
    lock->waiter_count += 1;
    if (lock->main_thread == owner) {
        lock->main_thread_waiting = true;
        if (lock->main_callback) {
            pthread_t original_owner = __atomic_load_n(&lock->owner_thread, __ATOMIC_SEQ_CST);
            uint32_t original_level = lock->lock_level;
            pthread_t main_thread = lock->main_thread;
            lock->owner_thread = main_thread;
            lock->lock_level = original_level + 1;
            void (*main_callback)(const void *) = lock->main_callback;
            const void *main_callback_context = lock->main_callback_context;
            main_callback(main_callback_context);
            lock->lock_level = original_level;
            lock->owner_thread = original_owner;
            lock->main_callback = NULL;
            lock->main_callback_context = NULL;
            pthread_cond_signal(&lock->main_callback_condition);
        }
    }
    pthread_cond_wait(&lock->lock_condition, &lock->mutex);
    if (lock->main_thread == owner) {
        lock->main_thread_waiting = false;
    }
    lock->waiter_count -= 1;
    #endif
}

static void sync_main_callback(MovableLock lock) {
    #if OPENSWIFTUI_TARGET_OS_DARWIN
    [[clang::noinline]]
    _MovableLockLock(lock);
    lock->main_callback_pending = false;
    [[clang::noinline]]
    _MovableLockUnlock(lock);
    #endif
}
