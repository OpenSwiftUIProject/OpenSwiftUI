//
//  CTAdaptiveImageGlyph.h
//  OpenSwiftUI_SPI

#pragma once

#include "OpenSwiftUIBase.h"

#if OPENSWIFTUI_TARGET_OS_DARWIN && __has_include(<CoreText/CoreText.h>)

#import <CoreText/CoreText.h>
#import <Foundation/Foundation.h>

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

API_AVAILABLE(macos(15.0), ios(18.0), tvos(18.0), watchos(11.0), visionos(2.0)) NS_SWIFT_SENDABLE
@interface CTAdaptiveImageGlyph : NSObject <CTAdaptiveImageProviding>
@end

NS_HEADER_AUDIT_END(nullability, sendability)

#endif
