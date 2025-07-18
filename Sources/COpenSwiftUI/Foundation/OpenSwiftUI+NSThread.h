//
//  OpenSwiftUI+NSThread.h
//  COpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete

#include "OpenSwiftUIBase.h"

#if OPENSWIFTUI_TARGET_OS_DARWIN

#import <Foundation/Foundation.h>

OPENSWIFTUI_ASSUME_NONNULL_BEGIN

OPENSWIFTUI_EXPORT
BOOL _NSThreadStart(NSThread *thread);

OPENSWIFTUI_ASSUME_NONNULL_END

#endif /* OPENSWIFTUI_TARGET_OS_DARWIN */
