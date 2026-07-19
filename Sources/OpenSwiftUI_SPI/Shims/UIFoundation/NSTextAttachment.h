//
//  NSTextAttachment.h
//  OpenSwiftUI_SPI

#pragma once

#import "OpenSwiftUIBase.h"

#if OPENSWIFTUI_TARGET_OS_DARWIN

// Modified based on macOS 26.2 SDK and iOS 18.5/26.2 SDKs. Keep the
// declarations aligned with AppKit and UIKit because clients can import both
// those modules and UIFoundation_Private.

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

@class NSTextContainer;
@class NSLayoutManager;
@class NSFileWrapper;
@class NSTextAttachmentViewProvider;
@class NSTextLayoutManager;
@protocol NSTextLocation;

#if OPENSWIFTUI_TARGET_OS_OSX
@class NSImage;
@class NSView;
@class NSTextAttachmentCell;
@protocol NSTextAttachmentCell;
#else
@class UIImage;
@class UIView;
#endif

API_AVAILABLE(macos(12.0), ios(15.0), tvos(15.0), watchos(8.0), visionos(1.0))
@protocol NSTextAttachmentLayout <NSObject>

#if OPENSWIFTUI_TARGET_OS_OSX
- (nullable NSImage *)imageForBounds:(CGRect)bounds attributes:(NSDictionary<NSAttributedStringKey, id> *)attributes location:(id <NSTextLocation>)location textContainer:(nullable NSTextContainer *)textContainer API_AVAILABLE(macos(12.0), ios(15.0), tvos(15.0), watchos(8.0), visionos(1.0));
#else
- (nullable UIImage *)imageForBounds:(CGRect)bounds attributes:(NSDictionary<NSAttributedStringKey, id> *)attributes location:(id <NSTextLocation>)location textContainer:(nullable NSTextContainer *)textContainer API_AVAILABLE(macos(12.0), ios(15.0), tvos(15.0), watchos(8.0), visionos(1.0));
#endif

- (CGRect)attachmentBoundsForAttributes:(NSDictionary<NSAttributedStringKey, id> *)attributes location:(id <NSTextLocation>)location textContainer:(nullable NSTextContainer *)textContainer proposedLineFragment:(CGRect)proposedLineFragment position:(CGPoint)position API_AVAILABLE(macos(12.0), ios(15.0), tvos(15.0), watchos(8.0), visionos(1.0));

#if OPENSWIFTUI_TARGET_OS_OSX
- (nullable NSTextAttachmentViewProvider *)viewProviderForParentView:(nullable NSView *)parentView location:(id <NSTextLocation>)location textContainer:(nullable NSTextContainer *)textContainer API_AVAILABLE(macos(12.0), ios(15.0), tvos(15.0), visionos(1.0)) API_UNAVAILABLE(watchos);
#else
- (nullable NSTextAttachmentViewProvider *)viewProviderForParentView:(nullable UIView *)parentView location:(id <NSTextLocation>)location textContainer:(nullable NSTextContainer *)textContainer API_AVAILABLE(macos(12.0), ios(15.0), tvos(15.0), visionos(1.0)) API_UNAVAILABLE(watchos);
#endif

@end

OPENSWIFTUI_EXPORT API_AVAILABLE(macos(10.0), ios(7.0), tvos(9.0), watchos(2.0), visionos(1.0))
@interface NSTextAttachment : NSObject <NSTextAttachmentLayout, NSSecureCoding>

- (instancetype)initWithData:(nullable NSData *)contentData ofType:(nullable NSString *)uti NS_DESIGNATED_INITIALIZER API_AVAILABLE(macos(10.11), ios(7.0), tvos(9.0), watchos(2.0), visionos(1.0));

#if OPENSWIFTUI_TARGET_OS_OSX
- (instancetype)initWithFileWrapper:(nullable NSFileWrapper *)fileWrapper;
#endif

@property (nullable, copy, NS_NONATOMIC_IOSONLY) NSData *contents API_AVAILABLE(macos(10.11), ios(7.0), tvos(9.0), watchos(2.0), visionos(1.0));
@property (nullable, copy, NS_NONATOMIC_IOSONLY) NSString *fileType API_AVAILABLE(macos(10.11), ios(7.0), tvos(9.0), watchos(2.0), visionos(1.0));

#if OPENSWIFTUI_TARGET_OS_OSX
@property (nullable, strong) NSImage *image API_AVAILABLE(macos(10.11), ios(7.0), tvos(9.0), watchos(2.0), visionos(1.0));
#else
@property (nullable, strong, NS_NONATOMIC_IOSONLY) UIImage *image API_AVAILABLE(macos(10.11), ios(7.0), tvos(9.0), watchos(2.0), visionos(1.0));
#endif

@property (NS_NONATOMIC_IOSONLY) CGRect bounds API_AVAILABLE(macos(10.11), ios(7.0), tvos(9.0), watchos(2.0), visionos(1.0));
@property (nullable, strong, NS_NONATOMIC_IOSONLY) NSFileWrapper *fileWrapper;

#if OPENSWIFTUI_TARGET_OS_OSX
@property (nullable, strong) id <NSTextAttachmentCell> attachmentCell API_AVAILABLE(macos(10.0)) API_UNAVAILABLE(ios, watchos, tvos, visionos);
#endif

@property CGFloat lineLayoutPadding API_AVAILABLE(macos(12.0), ios(15.0), tvos(15.0), watchos(8.0), visionos(1.0));

+ (nullable Class)textAttachmentViewProviderClassForFileType:(NSString *)fileType API_AVAILABLE(macos(12.0), ios(15.0), tvos(15.0), visionos(1.0)) API_UNAVAILABLE(watchos);
+ (void)registerTextAttachmentViewProviderClass:(Class)textAttachmentViewProviderClass forFileType:(NSString *)fileType API_AVAILABLE(macos(12.0), ios(15.0), tvos(15.0), visionos(1.0)) API_UNAVAILABLE(watchos);

@property BOOL allowsTextAttachmentView API_AVAILABLE(macos(12.0), ios(15.0), tvos(15.0), visionos(1.0)) API_UNAVAILABLE(watchos);
@property (readonly) BOOL usesTextAttachmentView API_AVAILABLE(macos(12.0), ios(15.0), tvos(15.0), visionos(1.0)) API_UNAVAILABLE(watchos);

@end

@interface NSTextAttachment (OpenSwiftUI_SPI)

@property (nullable, strong) NSString *accessibilityLabel;

@end

NS_HEADER_AUDIT_END(nullability, sendability)

#endif
