//
//  OpenSwiftUI_SPI.h
//  OpenSwiftUI
//
//  Audited for RELEASE_2021
//  Status: WIP

#ifndef OpenSwiftUI_SPI_h
#define OpenSwiftUI_SPI_h

#include "OpenSwiftUIBase.h"

#if __has_include(<QuartzCore/CoreAnimation.h>)

#import <QuartzCore/CoreAnimation.h>

OPENSWIFTUI_ASSUME_NONNULL_BEGIN

@interface CALayer (OpenSwiftUI_SPI)
- (BOOL)hasBeenCommitted;
@end

OPENSWIFTUI_ASSUME_NONNULL_END

#endif /* CoreAnimation.h */

#if __has_include(<UIKit/UIKit.h>)

#import <UIKit/UIKit.h>

OPENSWIFTUI_ASSUME_NONNULL_BEGIN

@interface UIApplication (OpenSwiftUI_SPI)
- (void)startedTest:(nullable NSString *)name;
- (void)finishedTest:(nullable NSString *)name;
- (void)failedTest:(nullable NSString *)name withFailure:(nullable NSError*)failure;
- (nullable NSString *)_launchTestName;
@end

@interface UIView (OpenSwiftUI_SPI)
- (BOOL)_shouldAnimatePropertyWithKey:(NSString *)key;
@end

OPENSWIFTUI_ASSUME_NONNULL_END

#elif __has_include(<AppKit/AppKit.h>)

#import <AppKit/AppKit.h>

OPENSWIFTUI_ASSUME_NONNULL_BEGIN

@interface NSApplication (OpenSwiftUI_SPI)
- (void)startedTest:(nullable NSString *)name;
- (void)finishedTest:(nullable NSString *)name;
- (void)failedTest:(nullable NSString *)name withFailure:(nullable NSError*)failure;
@end

OPENSWIFTUI_ASSUME_NONNULL_END

#endif /* UIKit.h / AppKit.h */

#endif /* OpenSwiftUI_SPI_h */
