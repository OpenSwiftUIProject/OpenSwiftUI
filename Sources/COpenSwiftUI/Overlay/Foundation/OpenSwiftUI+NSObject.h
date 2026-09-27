//
//  OpenSwiftUI+NSObject.h
//  COpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete

#ifndef OpenSwiftUI_NSObject_h
#define OpenSwiftUI_NSObject_h

#include "OpenSwiftUIBase.h"

#if OPENSWIFTUI_TARGET_OS_DARWIN

#import <Foundation/Foundation.h>

OPENSWIFTUI_ASSUME_NONNULL_BEGIN

@interface NSObject (OpenSwiftUI)
+ (BOOL)_isFromOpenSwiftUI;
- (void)_performSelector:(SEL)selector withObject:(nullable id)object;
@end

OPENSWIFTUI_ASSUME_NONNULL_END

#endif /* OPENSWIFTUI_TARGET_OS_DARWIN */

#endif /* OpenSwiftUI_NSObject_h */
