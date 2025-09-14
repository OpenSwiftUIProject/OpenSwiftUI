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

#if OPENSWIFTUI_LINK_BACKLIGHTSERVICES
#include <BacklightServices/BLSBacklightFBSSceneEnvironment.h>
#endif

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
- (instancetype)_initWithLayer:(CALayer *)layer;
- (BOOL)_shouldAnimatePropertyWithKey_openswiftui_safe_wrapper:(NSString *)key OPENSWIFTUI_SWIFT_NAME(_shouldAnimateProperty(withKey:));
- (void)_setFocusInteractionEnabled_openswiftui_safe_wrapper:(BOOL)enabled OPENSWIFTUI_SWIFT_NAME(_setFocusInteractionEnabled(_:));
@property(nonatomic, readonly, nullable) UIViewController *_viewControllerForAncestor_openswiftui_safe_wrapper OPENSWIFTUI_SWIFT_NAME(_viewControllerForAncestor);
@end

#if OPENSWIFTUI_LINK_BACKLIGHTSERVICES
@protocol _UIBacklightEnvironmentObserver <NSObject>
- (void)_timelinesForDateInterval:(NSDateInterval *)dateInterval;
- (void)_timelinesForDateInterval:(NSDateInterval *)dateInterval completion:(void (^)(void))completion;
- (void)_updateWithFrameSpecifier:(id)frameSpecifier;
- (void)_updateWithFrameSpecifier:(id)frameSpecifier completion:(void (^)(void))completion;
@optional
- (void)_willEnterAlwaysOn;
- (void)_didEnterAlwaysOn;
- (void)_willExitAlwaysOn;
- (void)_didExitAlwaysOn;
@end
#endif

@interface UIViewController (OpenSwiftUI_SPI)
@property (nonatomic, readonly) BOOL _canShowWhileLocked_openswiftui_safe_wrapper OPENSWIFTUI_SWIFT_NAME(_canShowWhileLocked);
#if OPENSWIFTUI_LINK_BACKLIGHTSERVICES
@property (nonatomic, readonly, nullable) NSArray<UIViewController<_UIBacklightEnvironmentObserver> *> *_effectiveControllersForAlwaysOnTimelines;
#endif
@end

#if !OPENSWIFTUI_TARGET_OS_VISION || OPENSWIFTUI_INTERNAL_XR_SDK
@interface UIScreen (OpenSwiftUI_SPI)
@property (nonatomic, readonly) CGRect _referenceBounds_openswiftui_safe_wrapper OPENSWIFTUI_SWIFT_NAME(_referenceBounds);
@property (nonatomic, readonly) CGFloat _pointsPerInch_openswiftui_safe_wrapper OPENSWIFTUI_SWIFT_NAME(_pointsPerInch);
@end
#endif

@interface UIWindowScene (OpenSwiftUI_SPI)
@property (nonatomic, readonly) UIUserInterfaceStyle _systemUserInterfaceStyle_openswiftui_safe_wrapper OPENSWIFTUI_SWIFT_NAME(_systemUserInterfaceStyle);
#if OPENSWIFTUI_LINK_BACKLIGHTSERVICES
@property (nonatomic, readonly, nullable) BLSBacklightFBSSceneEnvironment *_backlightSceneEnvironment_openswiftui_safe_wrapper OPENSWIFTUI_SWIFT_NAME(_backlightSceneEnvironment);
#endif
@end

@interface UITraitCollection (OpenSwiftUI_SPI)
@property (nonatomic, readonly, nullable) NSObject *_environmentWrapper_openswiftui_safe_wrapper OPENSWIFTUI_SWIFT_NAME(_environmentWrapper);
@end

#if OPENSWIFTUI_LINK_BACKLIGHTSERVICES
@interface _UIAlwaysOnEnvironment : NSObject
@property (class, nonatomic, readonly) BOOL _alwaysOnSupported;
@end
#endif

OPENSWIFTUI_EXPORT
bool UIViewIgnoresTouchEvents(UIView *view);

OPENSWIFTUI_EXPORT
float UIAnimationDragCoefficient(void);

// MARK: - UIUpdate related private API from UIKitCore

OPENSWIFTUI_EXPORT
bool _UIUpdateAdaptiveRateNeeded();

OPENSWIFTUI_ASSUME_NONNULL_END

#endif /* __has_include(<UIKit/UIKit.h>) */

#endif /* UIKit_Private_h */
