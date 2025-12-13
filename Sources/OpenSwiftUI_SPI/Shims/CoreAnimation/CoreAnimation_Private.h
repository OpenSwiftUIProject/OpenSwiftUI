//
//  CoreAnimation_Private.h
//  OpenSwiftUI_SPI

#ifndef CoreAnimation_Private_h
#define CoreAnimation_Private_h

#include "OpenSwiftUIBase.h"

#if __has_include(<QuartzCore/CoreAnimation.h>)

#import <QuartzCore/CoreAnimation.h>

OPENSWIFTUI_ASSUME_NONNULL_BEGIN

@interface CALayer (OpenSwiftUI_SPI)
@property (nonatomic, assign, readonly) BOOL hasBeenCommitted_openswiftui_safe_wrapper OPENSWIFTUI_SWIFT_NAME(hasBeenCommitted);
@property (nonatomic, assign) BOOL allowsGroupBlending_openswiftui_safe_wrapper OPENSWIFTUI_SWIFT_NAME(allowsGroupBlending);

@property (nonatomic, assign) uint64_t openSwiftUI_viewTestProperties;
@end

struct CAColorMatrix {
    float m11, m12, m13, m14, m15;
    float m21, m22, m23, m24, m25;
    float m31, m32, m33, m34, m35;
    float m41, m42, m43, m44, m45;
};
typedef struct CAColorMatrix CAColorMatrix;

@interface NSValue (OpenSwiftUI_SPI)
+ (NSValue *)valueWithCAColorMatrix_openswiftui_safe_wrapper:(CAColorMatrix)t OPENSWIFTUI_SWIFT_NAME(init(caColorMatrix:));
@end

@interface CADisplay : NSObject {
    void * _impl;
}
@end

@interface CADisplayLink (OpenSwiftUI_SPI)

+ (instancetype)displayLinkWithDisplay_openswiftui_safe_wrapper:(CADisplay *)display target:(id)target selector:(SEL)selector OPENSWIFTUI_SWIFT_NAME(init(display:target:selector:));

@property(readonly, assign, nonatomic) CADisplay* display_openswiftui_safe_wrapper OPENSWIFTUI_SWIFT_NAME(display);

- (void)setHighFrameRateReasons_openswiftui_safe_wrapper:(const uint32_t *)reasons count:(NSInteger)count OPENSWIFTUI_SWIFT_NAME(setHighFrameRateReasons(_:count:));
@end

CA_EXTERN CALayerContentsFormat const kCAContentsFormatAutomatic OPENSWIFTUI_SWIFT_NAME(automatic);
CA_EXTERN CALayerContentsFormat const kCAContentsFormatA8 OPENSWIFTUI_SWIFT_NAME(A8);

OPENSWIFTUI_ASSUME_NONNULL_END

#endif /* CoreAnimation.h */

#endif /* CoreAnimation_Private_h */
