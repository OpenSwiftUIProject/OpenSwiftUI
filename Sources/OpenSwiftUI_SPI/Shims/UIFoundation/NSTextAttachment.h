//
//  NSTextAttachment.h
//  OpenSwiftUI_SPI

#pragma once

#import "OpenSwiftUIBase.h"

#if OPENSWIFTUI_TARGET_OS_DARWIN

// Modified based on macOS 27.0 SDK and iOS 18.5 SDK

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

OPENSWIFTUI_EXPORT API_AVAILABLE(macos(10.0), ios(7.0), tvos(9.0), watchos(2.0), visionos(1.0))
@interface NSTextAttachment : NSObject <NSSecureCoding>

@property (nullable, copy) NSData *contents;
@property (nullable, copy) NSString *fileType;
@property CGRect bounds;

@end

NS_HEADER_AUDIT_END(nullability, sendability)

#endif