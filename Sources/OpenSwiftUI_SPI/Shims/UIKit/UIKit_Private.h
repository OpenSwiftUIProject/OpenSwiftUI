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

@interface UIScreen (OpenSwiftUI_SPI)
@property (nonatomic, readonly) CGRect _referenceBounds_openswiftui_safe_wrapper OPENSWIFTUI_SWIFT_NAME(_referenceBounds);
@property (nonatomic, readonly) CGFloat _pointsPerInch_openswiftui_safe_wrapper OPENSWIFTUI_SWIFT_NAME(_pointsPerInch);
@end

@interface UIWindowScene (OpenSwiftUI_SPI)
@property (nonatomic, readonly) UIUserInterfaceStyle _systemUserInterfaceStyle_openswiftui_safe_wrapper OPENSWIFTUI_SWIFT_NAME(_systemUserInterfaceStyle);
@end

@interface UITraitCollection (OpenSwiftUI_SPI)
@property (nonatomic, readonly, nullable) NSObject *_environmentWrapper_openswiftui_safe_wrapper OPENSWIFTUI_SWIFT_NAME(_environmentWrapper);
@end

OPENSWIFTUI_EXPORT
bool UIViewIgnoresTouchEvents(UIView *view);

OPENSWIFTUI_EXPORT
float UIAnimationDragCoefficient(void);

// MARK: - UIUpdate related private API from UIKitCore

OPENSWIFTUI_EXPORT
bool _UIUpdateAdaptiveRateNeeded();

OPENSWIFTUI_ASSUME_NONNULL_END

#endif /* UIKit.h */

#endif /* UIKit_Private_h */
