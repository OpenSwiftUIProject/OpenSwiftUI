//
//  OpenSwiftUI+NSThread.h
//  COpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete

#include "OpenSwiftUI+NSThread.h"

#if OPENSWIFTUI_TARGET_OS_DARWIN

@interface NSThread (COpenSwiftUI_NSThread)
- (BOOL)startAndReturnError:(NSError **)error;
@end

BOOL _NSThreadStart(NSThread *thread) {
    if ([thread respondsToSelector:@selector(startAndReturnError:)]) {
        return [thread startAndReturnError:nil];
    } else {
        [thread start];
        return YES;
    }
}

#endif /* OPENSWIFTUI_TARGET_OS_DARWIN */
