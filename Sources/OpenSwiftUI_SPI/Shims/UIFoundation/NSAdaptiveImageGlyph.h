//
//  NSAdaptiveImageGlyph.h
//  OpenSwiftUI_SPI

#pragma once

#import "OpenSwiftUIBase.h"

#if OPENSWIFTUI_TARGET_OS_DARWIN

// Modified based on macOS 26.2 SDK and iOS 18.5/26.2 SDKs. Keep the
// declarations aligned with AppKit and UIKit because clients can import both
// those modules and UIFoundation_Private.

#import <Foundation/Foundation.h>
#import <CoreText/CTRunDelegate.h>

@protocol CTAdaptiveImageProviding;
@class CTAdaptiveImageGlyph;
@class UTType;

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

FOUNDATION_EXPORT NSAttributedStringKey const NSAdaptiveImageGlyphAttributeName API_AVAILABLE(macos(15.0), ios(18.0), tvos(18.0), watchos(11.0), visionos(2.0)) NS_SWIFT_NAME(adaptiveImageGlyph);

API_AVAILABLE(macos(15.0), ios(18.0), tvos(18.0), watchos(11.0), visionos(2.0)) NS_SWIFT_SENDABLE
@interface NSAdaptiveImageGlyph : NSObject <NSCopying, NSSecureCoding, CTAdaptiveImageProviding>

- (instancetype)initWithImageContent:(NSData *)imageContent NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithCoder:(NSCoder *)coder NS_DESIGNATED_INITIALIZER;
- (instancetype)init NS_UNAVAILABLE;

@property (readonly) NSData *imageContent;
@property (readonly) NSString *contentIdentifier;
@property (readonly, copy) NSString *contentDescription;

@property (class, readonly) UTType *contentType;

@end

@interface NSAdaptiveImageGlyph (OpenSwiftUICore)

- (instancetype)initWithCTAdaptiveImageGlyph:(CTAdaptiveImageGlyph *)adaptiveImageGlyph;

@end

NS_HEADER_AUDIT_END(nullability, sendability)

#endif
