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
    pthread_cond_t lockCondition;
    pthread_cond_t syncMainCondition;
    pthread_cond_t waitCondition;
    pthread_t main;
    pthread_t owner;
    uint32_t level;
    uint32_t waiterCount;
    void (* _Nullable function)(const void *context);
    const void * _Nullable context;
    bool syncMainCallbackPending;
    bool mainThreadWaiting;
} MovableLock_t;

typedef MovableLock_t *MovableLock __attribute((swift_newtype(struct)));

OPENSWIFTUI_EXPORT
MovableLock _MovableLockCreate(void) OPENSWIFTUI_SWIFT_NAME(MovableLock.create());

OPENSWIFTUI_EXPORT
void _MovableLockDestroy(MovableLock lock) OPENSWIFTUI_SWIFT_NAME(MovableLock.destroy(self:));

OPENSWIFTUI_EXPORT
bool _MovableLockIsOwner(MovableLock lock) OPENSWIFTUI_SWIFT_NAME(getter:MovableLock.isOwner(self:));

OPENSWIFTUI_EXPORT
bool _MovableLockIsOutermostOwner(MovableLock lock) OPENSWIFTUI_SWIFT_NAME(getter:MovableLock.isOutermostOwner(self:));

OPENSWIFTUI_EXPORT
void _MovableLockLock(MovableLock lock) OPENSWIFTUI_SWIFT_NAME(MovableLock.lock(self:));

OPENSWIFTUI_EXPORT
void _MovableLockUnlock(MovableLock lock) OPENSWIFTUI_SWIFT_NAME(MovableLock.unlock(self:));

OPENSWIFTUI_EXPORT
void _MovableLockSyncMain(MovableLock lock, const void *context, void (*function)(const void *context)) OPENSWIFTUI_SWIFT_NAME(MovableLock.syncMain(self:_:function:));

OPENSWIFTUI_EXPORT
void _MovableLockWait(MovableLock lock) OPENSWIFTUI_SWIFT_NAME(MovableLock.wait(self:));

OPENSWIFTUI_EXPORT
void _MovableLockBroadcast(MovableLock lock) OPENSWIFTUI_SWIFT_NAME(MovableLock.broadcast(self:));

OPENSWIFTUI_ASSUME_NONNULL_END

#endif /* MovableLock_h */
