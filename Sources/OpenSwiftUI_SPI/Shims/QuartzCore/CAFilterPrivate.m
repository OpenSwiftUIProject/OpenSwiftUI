//
//  CAFilterPrivate.m
//  OpenSwiftUI_SPI

#import "CAFilterPrivate.h"

#if __has_include(<QuartzCore/CoreAnimation.h>)

extern NSString * const kCAFilterAlphaThreshold;
extern NSString * const kCAFilterAverageColor;
extern NSString * const kCAFilterColorBrightness;
extern NSString * const kCAFilterColorContrast;
extern NSString * const kCAFilterColorHueRotate;
extern NSString * const kCAFilterColorInvert;
extern NSString * const kCAFilterColorMatrix;
extern NSString * const kCAFilterColorMonochrome;
extern NSString * const kCAFilterColorSaturate;
extern NSString * const kCAFilterCurves;
extern NSString * const kCAFilterGaussianBlur;
extern NSString * const kCAFilterLuminanceCurveMap;
extern NSString * const kCAFilterLuminanceToAlpha;
extern NSString * const kCAFilterMultiplyColor;
extern NSString * const kCAFilterVariableBlur;
extern NSString * const kCAFilterVibrantColorMatrix;

extern NSString * const kCAFilterInputAlphaValues;
extern NSString * const kCAFilterInputAmount;
extern NSString * const kCAFilterInputAngle;
extern NSString * const kCAFilterInputBias;
extern NSString * const kCAFilterInputBlueValues;
extern NSString * const kCAFilterInputColor;
extern NSString * const kCAFilterInputColorMatrix;
extern NSString * const kCAFilterInputDither;
extern NSString * const kCAFilterInputGreenValues;
extern NSString * const kCAFilterInputHardEdges;
extern NSString * const kCAFilterInputNormalizeEdges;
extern NSString * const kCAFilterInputPremultipliedValues;
extern NSString * const kCAFilterInputRadius;
extern NSString * const kCAFilterInputRedValues;
extern NSString * const kCAFilterInputValues;

static NSString *OpenSwiftUICAFilterType(uint32_t type) {
    static NSString * const * const types[] = {
        &kCAFilterAlphaThreshold,
        &kCAFilterAverageColor,
        &kCAFilterColorBrightness,
        &kCAFilterColorContrast,
        &kCAFilterColorHueRotate,
        &kCAFilterColorInvert,
        &kCAFilterColorMatrix,
        &kCAFilterColorMonochrome,
        &kCAFilterColorSaturate,
        &kCAFilterCurves,
        &kCAFilterGaussianBlur,
        &kCAFilterLuminanceCurveMap,
        &kCAFilterLuminanceToAlpha,
        &kCAFilterMultiplyColor,
        &kCAFilterVariableBlur,
        &kCAFilterVibrantColorMatrix,
    };
    return *types[type];
}

static NSString *_CAFilterInputKey(CAFilterInputKey key) __attribute__((noinline));

CAFilter *_CAFilterCreate(uint32_t type) {
    NSString *filterType;
    if (type <= 15) {
        filterType = OpenSwiftUICAFilterType(type);
    }
    return [CAFilter filterWithType:filterType];
}

id _CAFilterGetInput(CAFilter *filter, CAFilterInputKey key) {
    return [filter valueForKey:_CAFilterInputKey(key)];
}

static NSString *_CAFilterInputKey(CAFilterInputKey key) {
    switch (key) {
        case CAFilterInputKeyAlphaValues: return kCAFilterInputAlphaValues;
        case CAFilterInputKeyAmount: return kCAFilterInputAmount;
        case CAFilterInputKeyAngle: return kCAFilterInputAngle;
        case CAFilterInputKeyBias: return kCAFilterInputBias;
        case CAFilterInputKeyBlueValues: return kCAFilterInputBlueValues;
        case CAFilterInputKeyColor: return kCAFilterInputColor;
        case CAFilterInputKeyColorMatrix: return kCAFilterInputColorMatrix;
        case CAFilterInputKeyDither: return kCAFilterInputDither;
        case CAFilterInputKeyGreenValues: return kCAFilterInputGreenValues;
        case CAFilterInputKeyHardEdges: return kCAFilterInputHardEdges;
        case CAFilterInputKeyMaskImage: return @"inputMaskImage";
        case CAFilterInputKeyNormalizeEdges: return kCAFilterInputNormalizeEdges;
        case CAFilterInputKeyPremultipliedAlpha: return @"inputPremultipliedAlpha";
        case CAFilterInputKeyNormalizeEdgesTransparent: return @"inputNormalizeEdgesTransparent";
        case CAFilterInputKeyPremultipliedValues: return kCAFilterInputPremultipliedValues;
        case CAFilterInputKeyRadius: return kCAFilterInputRadius;
        case CAFilterInputKeyRedValues: return kCAFilterInputRedValues;
        case CAFilterInputKeyValues: return kCAFilterInputValues;
        default: return @"inputMaskImage";
    }
}

void _CAFilterSetInput(CAFilter *filter, id value, CAFilterInputKey key) {
    [filter setValue:value forKey:_CAFilterInputKey(key)];
}

NSMutableArray<CAFilter *> *_CAFilterArrayCreate(void) {
    return (__bridge NSMutableArray *)CFArrayCreateMutable(NULL, 0, &kCFTypeArrayCallBacks);
}

void _CAFilterArrayAppend(NSMutableArray<CAFilter *> *array, CAFilter *filter) {
    CFArrayAppendValue((__bridge CFMutableArrayRef)array, (__bridge const void *)filter);
}

#endif /* CoreAnimation.h */
