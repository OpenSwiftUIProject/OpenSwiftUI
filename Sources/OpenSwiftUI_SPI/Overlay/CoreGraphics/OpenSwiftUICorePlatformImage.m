//
//  OpenSwiftUICorePlatformImage.m
//  OpenSwiftUI_SPI
//
//  Audited for 6.5.4
//  Status: Complete

#include "OpenSwiftUICorePlatformImage.h"

#if OPENSWIFTUI_TARGET_OS_DARWIN

#include <Foundation/Foundation.h>
#if OPENSWIFTUI_TARGET_OS_IOS || OPENSWIFTUI_TARGET_OS_VISION
#include <UIKit/UIKit.h>
#endif

#if OPENSWIFTUI_TARGET_OS_OSX
#include <AppKit/AppKit.h>
#endif

// NOTE:
// On macOS, UIKit is not imported. For Mac Catalyst support (system == UIKit),
// we declare the needed UIImage selectors here so they can be called on id.
#if OPENSWIFTUI_TARGET_OS_OSX
@interface NSObject (OpenSwiftUICorePlatformImage_UIImage)
- (instancetype)initWithCGImage:(CGImageRef)cgImage scale:(CGFloat)scale orientation:(NSInteger)orientation; // UIImage
- (NSInteger)renderingMode; // UIImage
- (id)imageWithRenderingMode:(NSInteger)renderingMode; // UIImage
- (CGFloat)baselineOffsetFromBottom; // UIImage
- (id)imageWithBaselineOffsetFromBottom:(CGFloat)offset; // UIImage
- (CGImageRef)CGImage; // UIImage
- (NSInteger)imageOrientation; // UIImage
@end
#endif

Class _Nullable _OpenSwiftUICorePlatformImageClass(OpenSwiftUICoreSystem system) {
    static BOOL isValid;
    static Class imageClass;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        #if OPENSWIFTUI_TARGET_OS_IOS || OPENSWIFTUI_TARGET_OS_VISION
        Class class = NSClassFromString(@"UIImage");
        #elif OPENSWIFTUI_TARGET_OS_OSX
        // [Q]: Should we check the system here to lookup UIImage for non AppKit system?
        Class class = NSClassFromString(@"NSImage");
        #else
        Class class = nil;
        #endif
        imageClass = class;
        isValid = class != nil;
    });
    if (!isValid) {
        [NSException raise:@"Invalid image class" format:@""];
    }
    return imageClass;
}

NSObject* _OpenSwiftUICorePlatformImageMakeKitImage(OpenSwiftUICoreSystem system, CGImageRef cgImage, CGFloat scale, uint8_t orientation) {
    Class imageClass = _OpenSwiftUICorePlatformImageClass(system);
    #if OPENSWIFTUI_TARGET_OS_OSX
    if (system == OpenSwiftUICoreSystemAppKit) {
        CGSize size = CGSizeMake(CGImageGetWidth(cgImage) / scale, CGImageGetHeight(cgImage) / scale);
        NSImage *kitImage = [[imageClass alloc] initWithCGImage:cgImage size:size];
        return kitImage;
    } else {
        id kitImage = [[imageClass alloc] initWithCGImage:cgImage scale:scale orientation:orientation];
        if ([kitImage renderingMode] == 2 /* UIImageRenderingModeAlwaysTemplate */) {
            kitImage = [kitImage imageWithRenderingMode:2 /* UIImageRenderingModeAlwaysTemplate */];
        }
        if ([kitImage baselineOffsetFromBottom] > 0.0) {
            kitImage = [kitImage imageWithBaselineOffsetFromBottom:[kitImage baselineOffsetFromBottom]];
        }
        return kitImage;
    }
    #else
    UIImage *kitImage = [[imageClass alloc] initWithCGImage:cgImage scale:scale orientation:orientation];
    if (kitImage.renderingMode == UIImageRenderingModeAlwaysTemplate) {
        kitImage = [kitImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    }
    if (kitImage.baselineOffsetFromBottom > 0.0) {
        kitImage = [kitImage imageWithBaselineOffsetFromBottom:kitImage.baselineOffsetFromBottom];
    }
    return kitImage;
    #endif
}

BOOL _OpenSwiftUICorePlatformImageIsTemplate(OpenSwiftUICoreSystem system, id kitImage) {
    #if OPENSWIFTUI_TARGET_OS_OSX
    if (system == OpenSwiftUICoreSystemAppKit) {
        return NO;
    } else {
        return [kitImage renderingMode] == 2 /* UIImageRenderingModeAlwaysTemplate */;
    }
    #else
    return [(UIImage *)kitImage renderingMode] == UIImageRenderingModeAlwaysTemplate;
    #endif
}

CGImageRef _OpenSwiftUICorePlatformImageGetCGImage(OpenSwiftUICoreSystem system, id kitImage) {
    if (!kitImage) {
        return nil;
    }
    #if OPENSWIFTUI_TARGET_OS_OSX
    if (system == OpenSwiftUICoreSystemAppKit) {
        return [kitImage CGImageForProposedRect:nil context:nil hints:nil];
    } else {
        return [kitImage CGImage];
    }
    #else
    return [(UIImage *)kitImage CGImage];
    #endif
}

CGSize _OpenSwiftUICorePlatformImageGetSize(OpenSwiftUICoreSystem system, id kitImage) {
    CGImageRef cgImage = _OpenSwiftUICorePlatformImageGetCGImage(system, kitImage);
    if (!cgImage) {
        return CGSizeZero;
    }
    return CGSizeMake(CGImageGetWidth(cgImage), CGImageGetHeight(cgImage));
}

CGFloat _OpenSwiftUICorePlatformImageGetScale(OpenSwiftUICoreSystem system, id kitImage) {
    #if OPENSWIFTUI_TARGET_OS_OSX
    if (system == OpenSwiftUICoreSystemAppKit) {
        CGFloat kitImageWidth = [(NSImage *)kitImage size].width;
        CGFloat cgImageWidth = _OpenSwiftUICorePlatformImageGetSize(OpenSwiftUICoreSystemAppKit, kitImage).width;
        CGFloat scale = kitImageWidth / cgImageWidth;
        return scale;
    } else {
        return [kitImage scale];
    }
    #else
    return [(UIImage *)kitImage scale];
    #endif
}

uint8_t _OpenSwiftUICorePlatformImageGetImageOrientation(OpenSwiftUICoreSystem system, id kitImage) {
    #if OPENSWIFTUI_TARGET_OS_OSX
    if (system == OpenSwiftUICoreSystemAppKit) {
        return 0;
    } else {
        return (uint8_t)[kitImage imageOrientation];
    }
    #else
    return [(UIImage *)kitImage imageOrientation];
    #endif
}

CGFloat _OpenSwiftUICorePlatformImageGetBaselineOffsetFromBottom(OpenSwiftUICoreSystem system, id kitImage) {
    #if OPENSWIFTUI_TARGET_OS_OSX
    if (system == OpenSwiftUICoreSystemAppKit) {
        return [(NSImage *)kitImage alignmentRect].origin.y;
    } else {
        return [kitImage baselineOffsetFromBottom];
    }
    #else
    return [(UIImage *)kitImage baselineOffsetFromBottom];
    #endif
}

CGRect _OpenSwiftUICorePlatformImageGetAlignmentRect(OpenSwiftUICoreSystem system, id kitImage) {
    #if OPENSWIFTUI_TARGET_OS_OSX
    if (system == OpenSwiftUICoreSystemAppKit) {
        return [(NSImage *)kitImage alignmentRect];
    } else {
        return CGRectZero;
    }
    #else
    return CGRectZero;
    #endif
}

void _OpenSwiftUICorePlatformImageSetAlignmentRect(OpenSwiftUICoreSystem system, id kitImage, CGRect rect) {
    #if OPENSWIFTUI_TARGET_OS_OSX
    if (system == OpenSwiftUICoreSystemAppKit) {
        return [(NSImage *)kitImage setAlignmentRect:rect];
    } else {
        return;
    }
    #else
    return;
    #endif
}

#endif
