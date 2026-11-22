//
//  UITraitCollection+Private.h
//  COpenSwiftUI
//
//  Status: Complete

#ifndef UITraitCollection_Private_h
#define UITraitCollection_Private_h

#include "OpenSwiftUIBase.h"

#if __has_include(<UIKit/UIKit.h>)

#import <UIKit/UIKit.h>
#include "Shims/UIKit/UIUserInterfaceVibrancy.h"
#include "Shims/UIKit/UIBacklightLuminance.h"
#if OPENSWIFTUI_LINK_BACKLIGHTSERVICES
#import <BacklightServices/BacklightServices.h>
#endif

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

typedef NS_ENUM(NSInteger, OpenSwiftUIHDRHeadroomUsage) {
    OpenSwiftUIHDRHeadroomUsageUnspecified = -1,
    OpenSwiftUIHDRHeadroomUsageDisabled = 0,
    OpenSwiftUIHDRHeadroomUsageEnabled = 1,
};

#if OPENSWIFTUI_TARGET_OS_VISION
@interface RSSPlacementTarget : NSObject
- (NSUInteger)anchoredPlane;
@end
#endif

@interface UITraitCollection (OpenSwiftUI_Private)

@property (nonatomic, readonly) UITraitCollection *_traitCollectionByRemovingEnvironmentWrapper_openswiftui_safe_wrapper OPENSWIFTUI_SWIFT_NAME(_traitCollectionByRemovingEnvironmentWrapper);
@property (nonatomic, readonly) _UIBacklightLuminance _backlightLuminance_openswiftui_safe_wrapper OPENSWIFTUI_SWIFT_NAME(_backlightLuminance);
@property (nonatomic, readonly) OpenSwiftUIHDRHeadroomUsage _headroomUsage_openswiftui_safe_wrapper OPENSWIFTUI_SWIFT_NAME(_headroomUsage);
@property (nonatomic, readonly) NSInteger _userInterfaceRenderingMode_openswiftui_safe_wrapper OPENSWIFTUI_SWIFT_NAME(_userInterfaceRenderingMode);
@property (nonatomic, readonly) CGFloat displayCornerRadius_openswiftui_safe_wrapper OPENSWIFTUI_SWIFT_NAME(displayCornerRadius);
@property (nonatomic, readonly) _UIUserInterfaceVibrancy _vibrancy_openswiftui_safe_wrapper OPENSWIFTUI_SWIFT_NAME(_vibrancy);

#if OPENSWIFTUI_TARGET_OS_VISION
@property (nonatomic, readonly, nullable) RSSPlacementTarget *mrui_placementTarget_openswiftui_safe_wrapper OPENSWIFTUI_SWIFT_NAME(mrui_placementTarget);
@property (nonatomic, readonly) CGFloat _pointsPerMeter_openswiftui_safe_wrapper OPENSWIFTUI_SWIFT_NAME(_pointsPerMeter);
@property (nonatomic, readonly) NSInteger _platterGroundingShadowVisibility_openswiftui_safe_wrapper OPENSWIFTUI_SWIFT_NAME(_platterGroundingShadowVisibility);
@property (nonatomic, readonly) BOOL mrui_ornamentStatus_openswiftui_safe_wrapper OPENSWIFTUI_SWIFT_NAME(mrui_ornamentStatus);
@property (nonatomic, readonly) NSInteger _containerVibrancy_openswiftui_safe_wrapper OPENSWIFTUI_SWIFT_NAME(_containerVibrancy);
@property (nonatomic, readonly) NSInteger _platterStatus_openswiftui_safe_wrapper OPENSWIFTUI_SWIFT_NAME(_platterStatus);
#endif

#if OPENSWIFTUI_LINK_BACKLIGHTSERVICES
@property (nonatomic, readonly) BLSUpdateFidelity _updateFidelity_openswiftui_safe_wrapper OPENSWIFTUI_SWIFT_NAME(_updateFidelity);
#endif

@end

OPENSWIFTUI_EXPORT
const CGFloat _UITraitCollectionDisplayCornerRadiusUnspecified;

NS_HEADER_AUDIT_END(nullability, sendability)

#endif /* __has_include(<UIKit/UIKit.h>) */

#endif /* UITraitCollection_Private_h */
