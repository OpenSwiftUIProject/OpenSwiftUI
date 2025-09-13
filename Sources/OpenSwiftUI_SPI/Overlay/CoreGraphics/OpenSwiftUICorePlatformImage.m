//
//  OpenSwiftUICorePlatformImage.h
//  OpenSwiftUICore
//
//  Audited for iOS 18.0 & macOS 15.0
//  Status: Blocked by macOS implementation and Mac Catalyst support

#include "OpenSwiftUICorePlatformImage.h"

#if OPENSWIFTUI_TARGET_OS_DARWIN

#include <Foundation/Foundation.h>
#if OPENSWIFTUI_TARGET_OS_IOS || OPENSWIFTUI_TARGET_OS_VISION
#include <UIKit/UIKit.h>
#else
#include <AppKit/AppKit.h>
#endif

Class _Nullable _OpenSwiftUICorePlatformImageClass(void) {
    static BOOL isValid = true;
    static Class imageClass;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        #if OPENSWIFTUI_TARGET_OS_OSX
        Class class = NSClassFromString(@"NSImage");
        imageClass = class;
        isValid = class != nil;
        #else
        Class class = NSClassFromString(@"UIImage");
        imageClass = class;
        isValid = class != nil;
        #endif
    });
    if (isValid) {
        return imageClass;
    } else {
        [NSException raise:@"Invalid image class" format:@""];
    }
}

NSObject* _OpenSwiftUICorePlatformImageMakeKitImage(OpenSwiftUICoreSystem system, CGImageRef cgImage, CGFloat scale, uint8_t orientation) {
    Class imageClass = _OpenSwiftUICorePlatformImageClass();
    #if OPENSWIFTUI_TARGET_OS_OSX
    if (system == OpenSwiftUICoreSystemAppKit) {
        CGSize size = CGSizeMake(CGImageGetWidth(cgImage), CGImageGetHeight(cgImage));
        NSImage *kitImage = [[imageClass alloc] initWithCGImage:cgImage size:size];
        return kitImage;
    } else {
        // FIXME: How to import macOS SDK's iOS Support <UIKit/UIImage.h> header here
        // UIImage *kitImage = [[imageClass alloc] initWithCGImage:cgImage scale:scale orientation:orientation];
        // TODO: Unimplemented
        return nil;
    }
    #else
    UIImage *kitImage = [[imageClass alloc] initWithCGImage:cgImage scale:scale orientation:orientation];
    if (kitImage.renderingMode == UIImageRenderingModeAlwaysTemplate) {
        kitImage = [kitImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
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
        // FIXME: How to import macOS SDK's iOS Support <UIKit/UIImage.h> header here
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
        // FIXME: How to import macOS SDK's iOS Support <UIKit/UIImage.h> header here
        // return [(UIImage *)kitImage imageOrientation];
        // TODO: Unimplemented
        return 0;
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
        // FIXME: How to import macOS SDK's iOS Support <UIKit/UIImage.h> header here
        // return [(UIImage *)kitImage baselineOffsetFromBottom];
        // TODO: Unimplemented
        return 0.0;
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
