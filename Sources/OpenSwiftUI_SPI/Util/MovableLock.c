//
//  MovableLock.c
//  OpenSwiftUI
//
//  Audited for 3.5.2
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
    pthread_cond_init(&lock->lockCondition, NULL);
    pthread_cond_init(&lock->syncMainCondition, NULL);
    pthread_cond_init(&lock->waitCondition, NULL);
    #if OPENSWIFTUI_TARGET_OS_DARWIN
    lock->main = pthread_main_thread_np();
    #endif
    return lock;
}

void _MovableLockDestroy(MovableLock lock) {
    pthread_cond_destroy(&lock->lockCondition);
    pthread_cond_destroy(&lock->syncMainCondition);
    pthread_cond_destroy(&lock->waitCondition);
    pthread_mutex_destroy(&lock->mutex);
    free(lock);
}

bool _MovableLockIsOwner(MovableLock lock) {
    pthread_t owner = lock->owner;
    return pthread_self() == owner;
}

bool _MovableLockIsOutermostOwner(MovableLock lock) {
    pthread_t owner = lock->owner;
    return pthread_self() == owner && lock->level == 1;
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
        [[clang::noinline]]
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
    if (lock->waiterCount != 0) {
        pthread_cond_signal(&lock->lockCondition);
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
        if (lock->mainThreadWaiting) {
            pthread_cond_signal_thread_np(&lock->lockCondition, lock->main);
        } else if (!lock->syncMainCallbackPending) {
            lock->syncMainCallbackPending = true;
            dispatch_async_f(dispatch_get_main_queue(), lock, (dispatch_function_t)&sync_main_callback);
            if (lock->mainThreadWaiting) {
                pthread_cond_signal_thread_np(&lock->lockCondition, lock->main);
            }
        }
        while (lock->function) {
            pthread_cond_wait(&lock->syncMainCondition, &lock->mutex);
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
    if (lock->waiterCount != 0) {
        pthread_cond_broadcast(&lock->lockCondition);
    }
    pthread_cond_wait(&lock->waitCondition, &lock->mutex);
    while (lock->owner) {
        [[clang::noinline]]
        wait_for_lock(lock, owner);
    }
    lock->owner = owner;
    lock->level = level;
    #endif
}

void _MovableLockBroadcast(MovableLock lock) {
    #if OPENSWIFTUI_TARGET_OS_DARWIN
    pthread_cond_broadcast(&lock->waitCondition);
    #endif
}

static void wait_for_lock(MovableLock lock, pthread_t owner) {
    #if OPENSWIFTUI_TARGET_OS_DARWIN
    lock->waiterCount += 1;
    if (lock->main == owner) {
        lock->mainThreadWaiting = true;
        if (lock->function) {
            pthread_t original_owner = __atomic_load_n(&lock->owner, __ATOMIC_SEQ_CST);
            uint32_t original_level = lock->level;
            pthread_t main = lock->main;
            lock->owner = main;
            lock->level = original_level + 1;
            void (*function)(const void *) = lock->function;
            const void *context = lock->context;
            function(context);
            lock->level = original_level;
            lock->owner = original_owner;
            lock->function = NULL;
            lock->context = NULL;
            pthread_cond_signal(&lock->syncMainCondition);
        }
    }
    pthread_cond_wait(&lock->lockCondition, &lock->mutex);
    if (lock->main == owner) {
        lock->mainThreadWaiting = false;
    }
    lock->waiterCount -= 1;
    #endif
}

static void sync_main_callback(MovableLock lock) {
    #if OPENSWIFTUI_TARGET_OS_DARWIN
    [[clang::noinline]]
    _MovableLockLock(lock);
    lock->syncMainCallbackPending = false;
    [[clang::noinline]]
    _MovableLockUnlock(lock);
    #endif
}
