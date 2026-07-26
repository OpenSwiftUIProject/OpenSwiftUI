//
//  NSTextEncapsulation.h
//  OpenSwiftUI_SPI

#pragma once

#include "OpenSwiftUIBase.h"

typedef unsigned long NSUInteger;

typedef OPENSWIFTUI_CLOSED_ENUM(NSUInteger, NSTextEncapsulationScale) {
    NSTextEncapsulationScaleMedium = 0x0,
    NSTextEncapsulationScaleSmall = 0x1,
    NSTextEncapsulationScaleLarge = 0x2,
};

typedef OPENSWIFTUI_CLOSED_ENUM(NSUInteger, NSTextEncapsulationShape) {
    NSTextEncapsulationShapeRoundedRectangle = 0x0,
    NSTextEncapsulationShapeRectangle = 0x1,
    NSTextEncapsulationShapeCapsule = 0x2,
};

typedef OPENSWIFTUI_CLOSED_ENUM(NSUInteger, NSTextEncapsulationStyle) {
    NSTextEncapsulationStyleOutline = 0x0,
    NSTextEncapsulationStyleFill = 0x1,
};

typedef OPENSWIFTUI_CLOSED_ENUM(NSUInteger, NSTextEncapsulationPlatterSize) {
    NSTextEncapsulationPlatterSizeRegular = 0x0,
    NSTextEncapsulationPlatterSizeLarge = 0x1,
};

#if __has_include(<Foundation/Foundation.h>) && __has_include(<CoreGraphics/CoreGraphics.h>)

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSTextEncapsulation : NSObject

@property (nonatomic) NSTextEncapsulationScale scale;
@property (nonatomic) NSTextEncapsulationShape shape;
@property (nonatomic) NSTextEncapsulationStyle style;
@property (nonatomic) NSTextEncapsulationPlatterSize platterSize;
@property (nonatomic) CGFloat lineWeight;
@property (nonatomic, strong, nullable) NSObject *color;
@property (nonatomic) CGFloat minimumWidth;

@end

@interface NSTextEncapsulation (OpenSwiftUICore)

- (void)setPlatformColor:(NSObject * _Nullable)platformColor;

@end

NS_ASSUME_NONNULL_END

#endif
