//
//  MovableLock.h
//  OpenSwiftUI
//
//  Audited for 3.5.2
//  Status: Complete

#ifndef MovableLock_h
#define MovableLock_h

#include "OpenSwiftUIBase.h"
#import <pthread.h>

OPENSWIFTUI_ASSUME_NONNULL_BEGIN

typedef struct MovableLock_s {
    pthread_mutex_t mutex;
    pthread_cond_t cond1;
    pthread_cond_t cond2;
    pthread_cond_t cond3;
    pthread_t main;
    pthread_t owner;
    uint32_t level;
    uint32_t unknown;
    void (* _Nullable function)(const void *context);
    const void * _Nullable context;
    bool unknown4;
    bool unknown5;
} MovableLock_t;

typedef MovableLock_t *MovableLock __attribute((swift_newtype(struct)));

OPENSWIFTUI_EXPORT
OPENSWIFTUI_REFINED_FOR_SWIFT
MovableLock _MovableLockCreate(void) OPENSWIFTUI_SWIFT_NAME(MovableLock.create());

OPENSWIFTUI_EXPORT
OPENSWIFTUI_REFINED_FOR_SWIFT
void _MovableLockDestroy(MovableLock lock) OPENSWIFTUI_SWIFT_NAME(MovableLock.destroy(self:));
bool _MovableLockIsOwner(MovableLock lock) OPENSWIFTUI_SWIFT_NAME(getter:MovableLock.isOwner(self:));
bool _MovableLockIsOuterMostOwner(MovableLock lock) OPENSWIFTUI_SWIFT_NAME(getter:MovableLock.isOuterMostOwner(self:));
void _MovableLockLock(MovableLock lock) OPENSWIFTUI_SWIFT_NAME(MovableLock.lock(self:));
void _MovableLockUnlock(MovableLock lock) OPENSWIFTUI_SWIFT_NAME(MovableLock.unlock(self:));
void _MovableLockSyncMain(MovableLock lock, const void *context, void (*function)(const void *context)) OPENSWIFTUI_SWIFT_NAME(MovableLock.syncMain(self:_:function:));
void _MovableLockWait(MovableLock lock) OPENSWIFTUI_SWIFT_NAME(MovableLock.wait(self:));
void _MovableLockBroadcast(MovableLock lock) OPENSWIFTUI_SWIFT_NAME(MovableLock.broadcast(self:));

OPENSWIFTUI_ASSUME_NONNULL_END

#endif /* MovableLock_h */
