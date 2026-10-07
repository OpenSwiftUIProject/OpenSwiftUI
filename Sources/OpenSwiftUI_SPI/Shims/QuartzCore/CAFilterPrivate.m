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

extern NSString * const kCAFilterClear;
extern NSString * const kCAFilterColorBlendMode;
extern NSString * const kCAFilterColorBurnBlendMode;
extern NSString * const kCAFilterColorDodgeBlendMode;
extern NSString * const kCAFilterCopy;
extern NSString * const kCAFilterDarkenBlendMode;
extern NSString * const kCAFilterDarkenSourceOver;
extern NSString * const kCAFilterDestAtop;
extern NSString * const kCAFilterDestIn;
extern NSString * const kCAFilterDestOut;
extern NSString * const kCAFilterDestOver;
extern NSString * const kCAFilterDifferenceBlendMode;
extern NSString * const kCAFilterDivideBlendMode;
extern NSString * const kCAFilterExclusionBlendMode;
extern NSString * const kCAFilterHardLightBlendMode;
extern NSString * const kCAFilterHueBlendMode;
extern NSString * const kCAFilterLightenBlendMode;
extern NSString * const kCAFilterLightenSourceOver;
extern NSString * const kCAFilterLinearBurnBlendMode;
extern NSString * const kCAFilterLinearDodgeBlendMode;
extern NSString * const kCAFilterLinearLightBlendMode;
extern NSString * const kCAFilterLuminosityBlendMode;
extern NSString * const kCAFilterMaximum;
extern NSString * const kCAFilterMultiplyBlendMode;
extern NSString * const kCAFilterOverlayBlendMode;
extern NSString * const kCAFilterPinLightBlendMode;
extern NSString * const kCAFilterPlusD;
extern NSString * const kCAFilterPlusL;
extern NSString * const kCAFilterSaturationBlendMode;
extern NSString * const kCAFilterScreenBlendMode;
extern NSString * const kCAFilterSoftLightBlendMode;
extern NSString * const kCAFilterSourceAtop;
extern NSString * const kCAFilterSourceIn;
extern NSString * const kCAFilterSourceOut;
extern NSString * const kCAFilterSubtractBlendMode;
extern NSString * const kCAFilterXor;

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

static NSString *OpenSwiftUICAFilterType(CAFilterType type) {
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

CAFilter *_CAFilterCreate(CAFilterType type) {
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

id _ORBBlendModeGetCompositingFilter(ORBBlendMode blendMode, bool compositingGroup) {
    switch (blendMode) {
        case ORBBlendModeMultiply: return kCAFilterMultiplyBlendMode;
        case ORBBlendModeScreen: return kCAFilterScreenBlendMode;
        case ORBBlendModeOverlay: return kCAFilterOverlayBlendMode;
        case ORBBlendModeDarken: return kCAFilterDarkenBlendMode;
        case ORBBlendModeLighten: return kCAFilterLightenBlendMode;
        case ORBBlendModeColorDodge: return kCAFilterColorDodgeBlendMode;
        case ORBBlendModeColorBurn: return kCAFilterColorBurnBlendMode;
        case ORBBlendModeSoftLight: return kCAFilterSoftLightBlendMode;
        case ORBBlendModeHardLight: return kCAFilterHardLightBlendMode;
        case ORBBlendModeDifference: return kCAFilterDifferenceBlendMode;
        case ORBBlendModeExclusion: return kCAFilterExclusionBlendMode;
        case ORBBlendModeHue: return kCAFilterHueBlendMode;
        case ORBBlendModeSaturation: return kCAFilterSaturationBlendMode;
        case ORBBlendModeColor: return kCAFilterColorBlendMode;
        case ORBBlendModeLuminosity: return kCAFilterLuminosityBlendMode;
        case ORBBlendModeClear: return kCAFilterClear;
        case ORBBlendModeCopy: return kCAFilterCopy;
        case ORBBlendModeSourceIn: return kCAFilterSourceIn;
        case ORBBlendModeSourceOut: return kCAFilterSourceOut;
        case ORBBlendModeSourceAtop: return kCAFilterSourceAtop;
        case ORBBlendModeDestinationOver: return kCAFilterDestOver;
        case ORBBlendModeDestinationIn: return kCAFilterDestIn;
        case ORBBlendModeDestinationOut: return kCAFilterDestOut;
        case ORBBlendModeDestinationAtop: return kCAFilterDestAtop;
        case ORBBlendModeXOR: return kCAFilterXor;
        case ORBBlendModePlusDarker: return kCAFilterPlusD;
        case ORBBlendModePlusLighter: return kCAFilterPlusL;
        case ORBBlendModeLinearDodge: return kCAFilterLinearDodgeBlendMode;
        case ORBBlendModeLinearBurn: return kCAFilterLinearBurnBlendMode;
        case ORBBlendModeLinearLight: return kCAFilterLinearLightBlendMode;
        case ORBBlendModePinLight: return kCAFilterPinLightBlendMode;
        case ORBBlendModeSubtract: return kCAFilterSubtractBlendMode;
        case ORBBlendModeDivide: return kCAFilterDivideBlendMode;
        case ORBBlendModeMaximum: return kCAFilterMaximum;
        case ORBBlendModeDarkenSourceOver: return kCAFilterDarkenSourceOver;
        case ORBBlendModeLightenSourceOver: return kCAFilterLightenSourceOver;
        default: return nil;
    }
}

ORBBlendMode _CACompositingFilterGetORBBlendMode(id filter) {
    if (!filter) {
        return ORBBlendModeNormal;
    }
    if ([filter isEqualToString:kCAFilterMultiplyBlendMode]) {
        return ORBBlendModeMultiply;
    }
    if ([filter isEqualToString:kCAFilterScreenBlendMode]) {
        return ORBBlendModeScreen;
    }
    if ([filter isEqualToString:kCAFilterOverlayBlendMode]) {
        return ORBBlendModeOverlay;
    }
    if ([filter isEqualToString:kCAFilterDarkenBlendMode]) {
        return ORBBlendModeDarken;
    }
    if ([filter isEqualToString:kCAFilterLightenBlendMode]) {
        return ORBBlendModeLighten;
    }
    if ([filter isEqualToString:kCAFilterColorDodgeBlendMode]) {
        return ORBBlendModeColorDodge;
    }
    if ([filter isEqualToString:kCAFilterColorBurnBlendMode]) {
        return ORBBlendModeColorBurn;
    }
    if ([filter isEqualToString:kCAFilterSoftLightBlendMode]) {
        return ORBBlendModeSoftLight;
    }
    if ([filter isEqualToString:kCAFilterHardLightBlendMode]) {
        return ORBBlendModeHardLight;
    }
    if ([filter isEqualToString:kCAFilterDifferenceBlendMode]) {
        return ORBBlendModeDifference;
    }
    if ([filter isEqualToString:kCAFilterExclusionBlendMode]) {
        return ORBBlendModeExclusion;
    }
    if ([filter isEqualToString:kCAFilterHueBlendMode]) {
        return ORBBlendModeHue;
    }
    if ([filter isEqualToString:kCAFilterSaturationBlendMode]) {
        return ORBBlendModeSaturation;
    }
    if ([filter isEqualToString:kCAFilterColorBlendMode]) {
        return ORBBlendModeColor;
    }
    if ([filter isEqualToString:kCAFilterLuminosityBlendMode]) {
        return ORBBlendModeLuminosity;
    }
    if ([filter isEqualToString:kCAFilterClear]) {
        return ORBBlendModeClear;
    }
    if ([filter isEqualToString:kCAFilterCopy]) {
        return ORBBlendModeCopy;
    }
    if ([filter isEqualToString:kCAFilterSourceIn]) {
        return ORBBlendModeSourceIn;
    }
    if ([filter isEqualToString:kCAFilterSourceOut]) {
        return ORBBlendModeSourceOut;
    }
    if ([filter isEqualToString:kCAFilterSourceAtop]) {
        return ORBBlendModeSourceAtop;
    }
    if ([filter isEqualToString:kCAFilterDestOver]) {
        return ORBBlendModeDestinationOver;
    }
    if ([filter isEqualToString:kCAFilterDestIn]) {
        return ORBBlendModeDestinationIn;
    }
    if ([filter isEqualToString:kCAFilterDestOut]) {
        return ORBBlendModeDestinationOut;
    }
    if ([filter isEqualToString:kCAFilterDestAtop]) {
        return ORBBlendModeDestinationAtop;
    }
    if ([filter isEqualToString:kCAFilterXor]) {
        return ORBBlendModeXOR;
    }
    if ([filter isEqualToString:kCAFilterPlusD]) {
        return ORBBlendModePlusDarker;
    }
    if ([filter isEqualToString:kCAFilterPlusL]) {
        return ORBBlendModePlusLighter;
    }
    if ([filter isEqualToString:kCAFilterLinearDodgeBlendMode]) {
        return ORBBlendModeLinearDodge;
    }
    if ([filter isEqualToString:kCAFilterLinearBurnBlendMode]) {
        return ORBBlendModeLinearBurn;
    }
    if ([filter isEqualToString:kCAFilterLinearLightBlendMode]) {
        return ORBBlendModeLinearLight;
    }
    if ([filter isEqualToString:kCAFilterPinLightBlendMode]) {
        return ORBBlendModePinLight;
    }
    if ([filter isEqualToString:kCAFilterSubtractBlendMode]) {
        return ORBBlendModeSubtract;
    }
    if ([filter isEqualToString:kCAFilterDivideBlendMode]) {
        return ORBBlendModeDivide;
    }
    if ([filter isEqualToString:kCAFilterMaximum]) {
        return ORBBlendModeMaximum;
    }
    if ([filter isEqualToString:kCAFilterDarkenSourceOver]) {
        return ORBBlendModeDarkenSourceOver;
    }
    if ([filter isEqualToString:kCAFilterLightenSourceOver]) {
        return ORBBlendModeLightenSourceOver;
    }
    return (ORBBlendMode)-1;
}

#endif /* CoreAnimation.h */
