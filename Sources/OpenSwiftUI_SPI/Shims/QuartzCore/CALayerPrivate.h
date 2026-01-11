//  CALayerPrivate.h
//  OpenSwiftUI_SPI

#ifndef CALayerPrivate_h
#define CALayerPrivate_h

#include "OpenSwiftUIBase.h"

#if __has_include(<QuartzCore/CALayer.h>)

#import <QuartzCore/CALayer.h>

@interface CALayer (OpenSwiftUI_SPI)

@property (nonatomic, assign) BOOL allowsDisplayCompositing_openswiftui_safe_wrapper OPENSWIFTUI_SWIFT_NAME(allowsDisplayCompositing);
@property (nonatomic, assign, readonly) BOOL hasBeenCommitted_openswiftui_safe_wrapper OPENSWIFTUI_SWIFT_NAME(hasBeenCommitted);
@property (nonatomic, assign) BOOL allowsGroupBlending_openswiftui_safe_wrapper OPENSWIFTUI_SWIFT_NAME(allowsGroupBlending);

@property (nonatomic, assign) uint64_t openSwiftUI_viewTestProperties;
@end

CA_EXTERN CALayerContentsFormat const kCAContentsFormatAutomatic OPENSWIFTUI_SWIFT_NAME(automatic);
CA_EXTERN CALayerContentsFormat const kCAContentsFormatA8 OPENSWIFTUI_SWIFT_NAME(A8);

#endif

#endif /* CALayerPrivate_h */
