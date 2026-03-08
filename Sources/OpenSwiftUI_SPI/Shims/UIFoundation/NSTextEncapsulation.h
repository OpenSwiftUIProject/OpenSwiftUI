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
