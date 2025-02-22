//
//  AppKit_Private.h
//  OpenSwiftUI_SPI
//
//  Status: WIP

#ifndef AppKit_Private_h
#define AppKit_Private_h

#include "OpenSwiftUIBase.h"

#if __has_include(<AppKit/AppKit.h>)

#import <AppKit/AppKit.h>

OPENSWIFTUI_ASSUME_NONNULL_BEGIN

@interface NSApplication (OpenSwiftUI_SPI)
- (void)startedTest:(nullable NSString *)name;
- (void)finishedTest:(nullable NSString *)name;
- (void)failedTest:(nullable NSString *)name withFailure:(nullable NSError*)failure;
@end

OPENSWIFTUI_ASSUME_NONNULL_END

#endif /* AppKit.h */

#endif /* AppKit_Private_h */
