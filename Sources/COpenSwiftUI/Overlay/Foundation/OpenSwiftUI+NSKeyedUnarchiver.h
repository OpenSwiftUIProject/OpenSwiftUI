//
//  OpenSwiftUI+NSKeyedUnarchiver.h
//  COpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete

#ifndef OpenSwiftUI_NSKeyedUnarchiver_h
#define OpenSwiftUI_NSKeyedUnarchiver_h

#include "OpenSwiftUIBase.h"

#if OPENSWIFTUI_TARGET_OS_DARWIN

#import <Foundation/Foundation.h>

OPENSWIFTUI_ASSUME_NONNULL_BEGIN

@interface NSKeyedUnarchiver (OpenSwiftUI)
// Preserve nil results when no NSError is reported.
+ (NSObject * _Nullable)openswiftui_unarchiveTopLevelLNActionWithData:(NSData *)data
                                                             error:(NSError * _Nullable * _Nullable)error
    __attribute__((swift_error(nonnull_error)))
    NS_SWIFT_NAME(openswiftui_unarchiveTopLevelLNAction(with:));
@end

OPENSWIFTUI_ASSUME_NONNULL_END

#endif /* OPENSWIFTUI_TARGET_OS_DARWIN */

#endif /* OpenSwiftUI_NSKeyedUnarchiver_h */
