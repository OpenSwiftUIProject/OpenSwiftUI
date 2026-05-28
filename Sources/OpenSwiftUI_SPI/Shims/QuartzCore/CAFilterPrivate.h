//
//  CAFilterPrivate.h
//  OpenSwiftUI_SPI

#ifndef CAFilterPrivate_h
#define CAFilterPrivate_h

#include "OpenSwiftUIBase.h"

#if __has_include(<QuartzCore/CoreAnimation.h>)

#import <QuartzCore/CoreAnimation.h>

OPENSWIFTUI_ASSUME_NONNULL_BEGIN

@interface CAFilter : NSObject

+ (NSArray<NSString *> *)filterTypes;
+ (instancetype)filterWithName:(NSString *)name;
+ (instancetype)filterWithType:(NSString *)type;

@end

typedef NS_ENUM(uint32_t, CAFilterInputKey) {
    CAFilterInputKeyAlphaValues = 0,
    CAFilterInputKeyAmount = 1,
    CAFilterInputKeyAngle = 2,
    CAFilterInputKeyBias = 3,
    CAFilterInputKeyBlueValues = 4,
    CAFilterInputKeyColor = 5,
    CAFilterInputKeyColorMatrix = 6,
    CAFilterInputKeyDither = 7,
    CAFilterInputKeyGreenValues = 8,
    CAFilterInputKeyHardEdges = 9,
    CAFilterInputKeyMaskImage = 10,
    CAFilterInputKeyNormalizeEdges = 11,
    CAFilterInputKeyPremultipliedAlpha = 12,
    CAFilterInputKeyNormalizeEdgesTransparent = 13,
    CAFilterInputKeyPremultipliedValues = 14,
    CAFilterInputKeyRadius = 15,
    CAFilterInputKeyRedValues = 16,
    CAFilterInputKeyValues = 17,
};

typedef NS_ENUM(uint32_t, CAFilterType) {
    CAFilterTypeAlphaThreshold = 0,
    CAFilterTypeAverageColor = 1,
    CAFilterTypeColorBrightness = 2,
    CAFilterTypeColorContrast = 3,
    CAFilterTypeColorHueRotate = 4,
    CAFilterTypeColorInvert = 5,
    CAFilterTypeColorMatrix = 6,
    CAFilterTypeColorMonochrome = 7,
    CAFilterTypeColorSaturate = 8,
    CAFilterTypeCurves = 9,
    CAFilterTypeGaussianBlur = 10,
    CAFilterTypeLuminanceCurveMap = 11,
    CAFilterTypeLuminanceToAlpha = 12,
    CAFilterTypeMultiplyColor = 13,
    CAFilterTypeVariableBlur = 14,
    CAFilterTypeVibrantColorMatrix = 15,
};

OPENSWIFTUI_EXPORT CAFilter *_CAFilterCreate(CAFilterType type) OPENSWIFTUI_SWIFT_NAME(CAFilter.init(key:));
OPENSWIFTUI_EXPORT id _Nullable _CAFilterGetInput(CAFilter *filter, CAFilterInputKey key) OPENSWIFTUI_SWIFT_NAME(CAFilterGetInput(_:key:));
OPENSWIFTUI_EXPORT void _CAFilterSetInput(CAFilter * _Nullable filter, id _Nullable value, CAFilterInputKey key) OPENSWIFTUI_SWIFT_NAME(CAFilter.setInput(self:value:key:));
OPENSWIFTUI_EXPORT NSMutableArray<CAFilter *> *_CAFilterArrayCreate(void) OPENSWIFTUI_SWIFT_NAME(CAFilterArrayCreate());
OPENSWIFTUI_EXPORT void _CAFilterArrayAppend(NSMutableArray<CAFilter *> *array, CAFilter *filter) OPENSWIFTUI_SWIFT_NAME(CAFilterArrayAppend(_:_:));

OPENSWIFTUI_ASSUME_NONNULL_END

#endif /* CoreAnimation.h */

#endif /* CAFilterPrivate_h */
