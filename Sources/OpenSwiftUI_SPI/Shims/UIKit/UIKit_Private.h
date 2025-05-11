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
- (void)startedTest_openswiftui_safe_wrapper:(nullable NSString *)name OPENSWIFTUI_SWIFT_NAME(startedTest(_:));
- (void)finishedTest_openswiftui_safe_wrapper:(nullable NSString *)name OPENSWIFTUI_SWIFT_NAME(finishedTest(_:));
- (void)failedTest_openswiftui_safe_wrapper:(nullable NSString *)name withFailure:(nullable NSError*)failure OPENSWIFTUI_SWIFT_NAME(failedTest(_:withFailure:));
- (nullable NSString *)_launchTestName_openswiftui_safe_wrapper OPENSWIFTUI_SWIFT_NAME(_launchTestName());

- (void)_performBlockAfterCATransactionCommits_openswiftui_safe_wrapper:(void (^)(void))block OPENSWIFTUI_SWIFT_NAME(_performBlockAfterCATransactionCommits(_:));
@end

@interface UIView (OpenSwiftUI_SPI)
- (BOOL)_shouldAnimatePropertyWithKey_openswiftui_safe_wrapper:(NSString *)key OPENSWIFTUI_SWIFT_NAME(_shouldAnimateProperty(withKey:));
- (void)_setFocusInteractionEnabled_openswiftui_safe_wrapper:(BOOL)enabled OPENSWIFTUI_SWIFT_NAME(_setFocusInteractionEnabled(_:));
@end

@interface UIViewController (OpenSwiftUI_SPI)
@property (nonatomic, readonly) BOOL _canShowWhileLocked_openswiftui_safe_wrapper OPENSWIFTUI_SWIFT_NAME(_canShowWhileLocked);
@end

OPENSWIFTUI_EXPORT
bool UIViewIgnoresTouchEvents(UIView *view);

OPENSWIFTUI_EXPORT
double UIAnimationDragCoefficient(void);

OPENSWIFTUI_ASSUME_NONNULL_END

#endif /* UIKit.h */

#endif /* UIKit_Private_h */
