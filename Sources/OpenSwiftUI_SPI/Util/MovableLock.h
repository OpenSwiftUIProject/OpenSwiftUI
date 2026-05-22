//
//  MovableLock.h
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete

#ifndef MovableLock_h
#define MovableLock_h

#include "OpenSwiftUIBase.h"
#import <pthread.h>

OPENSWIFTUI_ASSUME_NONNULL_BEGIN

typedef struct MovableLock_s {
    pthread_mutex_t mutex;
    pthread_cond_t lock_condition;
    pthread_cond_t main_callback_condition;
    pthread_cond_t broadcast_condition;
    pthread_t main_thread;
    pthread_t owner_thread;
    uint32_t lock_level;
    uint32_t waiter_count;
    void (* _Nullable main_callback)(const void *main_callback_context);
    const void * _Nullable main_callback_context;
    bool main_callback_pending;
    bool main_thread_waiting;
} MovableLock_t;

typedef MovableLock_t *MovableLock __attribute((swift_newtype(struct)));

MovableLock _MovableLockCreate(void) OPENSWIFTUI_SWIFT_NAME(MovableLock.init());

void _MovableLockDestroy(MovableLock lock) OPENSWIFTUI_SWIFT_NAME(MovableLock.destroy(self:));

bool _MovableLockIsOwner(MovableLock lock) OPENSWIFTUI_SWIFT_NAME(getter:MovableLock.isOwner(self:));

bool _MovableLockIsOutermostOwner(MovableLock lock) OPENSWIFTUI_SWIFT_NAME(getter:MovableLock.isOutermostOwner(self:));

void _MovableLockLock(MovableLock lock) OPENSWIFTUI_SWIFT_NAME(MovableLock.lock(self:));

void _MovableLockUnlock(MovableLock lock) OPENSWIFTUI_SWIFT_NAME(MovableLock.unlock(self:));

void _MovableLockSyncMain(MovableLock lock, const void *main_callback_context, void (*main_callback)(const void *main_callback_context)) OPENSWIFTUI_SWIFT_NAME(MovableLock.syncMain(self:_:function:));

void _MovableLockWait(MovableLock lock) OPENSWIFTUI_SWIFT_NAME(MovableLock.wait(self:));

void _MovableLockBroadcast(MovableLock lock) OPENSWIFTUI_SWIFT_NAME(MovableLock.broadcast(self:));

OPENSWIFTUI_ASSUME_NONNULL_END

#endif /* MovableLock_h */
