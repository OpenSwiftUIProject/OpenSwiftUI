//
//  UIKit_Private.h
//  OpenSwiftUI_SPI
//
//  Status: WIP

#ifndef UIKit_Private_h
#define UIKit_Private_h

#include "OpenSwiftUIBase.h"

#if __has_include(<UIKit/UIKit.h>)

#import <UIKit/UIKit.h>

OPENSWIFTUI_ASSUME_NONNULL_BEGIN

@interface UIApplication (OpenSwiftUI_SPI)
// Test API
- (void)startedTest:(nullable NSString *)name;
- (void)finishedTest:(nullable NSString *)name;
- (void)failedTest:(nullable NSString *)name withFailure:(nullable NSError*)failure;
- (nullable NSString *)_launchTestName;

- (void)_performBlockAfterCATransactionCommits:(void (^)(void))block OPENSWIFTUI_SWIFT_NAME(_performBlockAfterCATransactionCommits(_:));
@end

@interface UIView (OpenSwiftUI_SPI)
- (BOOL)_shouldAnimatePropertyWithKey:(NSString *)key;
@end

@interface UIViewController (OpenSwiftUI_SPI)
@property (nonatomic, readonly) BOOL _canShowWhileLocked;
@end

OPENSWIFTUI_EXPORT
bool UIViewIgnoresTouchEvents(UIView *view);

OPENSWIFTUI_EXPORT
double UIAnimationDragCoefficient(void);

OPENSWIFTUI_ASSUME_NONNULL_END

#endif /* UIKit.h */

#endif /* UIKit_Private_h */
