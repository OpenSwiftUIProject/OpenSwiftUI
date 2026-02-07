//  CALayerPrivate.h
//  OpenSwiftUI_SPI

#ifndef CALayerPrivate_h
#define CALayerPrivate_h

#include "OpenSwiftUIBase.h"

#if __has_include(<QuartzCore/CALayer.h>)

#import <QuartzCore/CALayer.h>

/// A type representing contents swizzle modes for CALayer.
typedef NSString *CALayerContentsSwizzle NS_TYPED_ENUM;

/// A type representing contents scaling modes for CALayer.
typedef NSString *CALayerContentsScaling NS_TYPED_ENUM;

@interface CALayer (OpenSwiftUI_SPI)

@property (nonatomic, assign) BOOL allowsDisplayCompositing_openswiftui_safe_wrapper OPENSWIFTUI_SWIFT_NAME(allowsDisplayCompositing);
@property (nonatomic, assign, readonly) BOOL hasBeenCommitted_openswiftui_safe_wrapper OPENSWIFTUI_SWIFT_NAME(hasBeenCommitted);
@property (nonatomic, assign) BOOL allowsGroupBlending_openswiftui_safe_wrapper OPENSWIFTUI_SWIFT_NAME(allowsGroupBlending);

@property (nonatomic, assign) uint64_t openSwiftUI_viewTestProperties;

/// Private property to control contents alpha channel swizzling.
/// When set to kCALayerContentsSwizzleAAAA, the alpha channel is replicated to all channels.
/// When set to kCALayerContentsSwizzleRGBA, normal RGBA behavior is used.
@property (nullable, copy) CALayerContentsSwizzle contentsSwizzle;

/// Private property to set a multiply color for layer contents.
/// This color is multiplied with the layer contents for tinting effects.
@property (nullable) CGColorRef contentsMultiplyColor;

/// Private property to set the contents scaling mode.
/// Valid values include "stretch" and "repeat".
@property (nullable, copy) CALayerContentsScaling contentsScaling;

/// Private property indicating if the layer wants extended dynamic range content.
@property (nonatomic) BOOL wantsExtendedDynamicRangeContent;

/// Private property for the maximum desired EDR (Extended Dynamic Range) value.
@property (nonatomic) CGFloat contentsMaximumDesiredEDR;

@end

CA_EXTERN CALayerContentsFormat _Nonnull const kCAContentsFormatAutomatic OPENSWIFTUI_SWIFT_NAME(automatic);
CA_EXTERN CALayerContentsFormat _Nonnull const kCAContentsFormatA8 OPENSWIFTUI_SWIFT_NAME(A8);

/// Private constants for contents swizzling (from QuartzCore framework)
OPENSWIFTUI_EXPORT CALayerContentsSwizzle _Nonnull const kCALayerContentsSwizzleAAAA OPENSWIFTUI_SWIFT_NAME(AAAA);
OPENSWIFTUI_EXPORT CALayerContentsSwizzle _Nonnull const kCALayerContentsSwizzleRGBA OPENSWIFTUI_SWIFT_NAME(RGBA);

/// Private constants for contents scaling mode
OPENSWIFTUI_EXPORT CALayerContentsScaling _Nonnull const kCAContentsScalingRepeat OPENSWIFTUI_SWIFT_NAME(repeat);
OPENSWIFTUI_EXPORT CALayerContentsScaling _Nonnull const kCAContentsScalingStretch OPENSWIFTUI_SWIFT_NAME(stretch);

/// Private filter constant for box filtering (high quality downsampling)
OPENSWIFTUI_EXPORT CALayerContentsFilter _Nonnull const kCAFilterBox OPENSWIFTUI_SWIFT_NAME(box);

/// Sets the contents swizzle mode for the layer.
/// When splatAlpha is true, uses kCALayerContentsSwizzleAAAA (alpha-only mode).
/// When splatAlpha is false, uses kCALayerContentsSwizzleRGBA (normal mode).
void _CALayerSetSplatsContentsAlpha(CALayer * _Nonnull layer, BOOL splatAlpha);

#endif

#endif /* CALayerPrivate_h */
