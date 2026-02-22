//
//  OpenSwiftUICorePlatformImage.h
//  OpenSwiftUI_SPI
//
//  Audited for 6.5.4
//  Status: Complete

#ifndef OpenSwiftUICorePlatformImage_h
#define OpenSwiftUICorePlatformImage_h

#include "OpenSwiftUIBase.h"

#if OPENSWIFTUI_TARGET_OS_DARWIN

#include <CoreGraphics/CoreGraphics.h>
#include "OpenSwiftUICoreSystem.h"

OPENSWIFTUI_IMPLICIT_BRIDGING_ENABLED

OPENSWIFTUI_ASSUME_NONNULL_BEGIN

OPENSWIFTUI_EXPORT
NSObject* _OpenSwiftUICorePlatformImageMakeKitImage(OpenSwiftUICoreSystem system, CGImageRef cgImage, CGFloat scale, uint8_t orientation) OPENSWIFTUI_SWIFT_NAME(_CorePlatformImageMakeKitImage(system:cgImage:scale:orientation:));

OPENSWIFTUI_EXPORT
BOOL _OpenSwiftUICorePlatformImageIsTemplate(OpenSwiftUICoreSystem system, id kitImage) OPENSWIFTUI_SWIFT_NAME(_CorePlatformImageIsTemplate(system:kitImage:));

OPENSWIFTUI_EXPORT
CGImageRef _Nullable _OpenSwiftUICorePlatformImageGetCGImage(OpenSwiftUICoreSystem system, id kitImage) OPENSWIFTUI_SWIFT_NAME(_CorePlatformImageGetCGImage(system:kitImage:));

OPENSWIFTUI_EXPORT
CGSize _OpenSwiftUICorePlatformImageGetSize(OpenSwiftUICoreSystem system, id kitImage) OPENSWIFTUI_SWIFT_NAME(_CorePlatformImageGetSize(system:kitImage:));

OPENSWIFTUI_EXPORT
CGFloat _OpenSwiftUICorePlatformImageGetScale(OpenSwiftUICoreSystem system, id kitImage) OPENSWIFTUI_SWIFT_NAME(_CorePlatformImageGetScale(system:kitImage:));

OPENSWIFTUI_EXPORT
uint8_t _OpenSwiftUICorePlatformImageGetImageOrientation(OpenSwiftUICoreSystem system, id kitImage) OPENSWIFTUI_SWIFT_NAME(_CorePlatformImageGetImageOrientation(system:kitImage:));

OPENSWIFTUI_EXPORT
CGFloat _OpenSwiftUICorePlatformImageGetBaselineOffsetFromBottom(OpenSwiftUICoreSystem system, id kitImage) OPENSWIFTUI_SWIFT_NAME(_CorePlatformImageGetBaselineOffsetFromBottom(system:kitImage:));

OPENSWIFTUI_EXPORT
CGRect _OpenSwiftUICorePlatformImageGetAlignmentRect(OpenSwiftUICoreSystem system, id kitImage) OPENSWIFTUI_SWIFT_NAME(_CorePlatformImageGetAlignmentRect(system:kitImage:));

OPENSWIFTUI_EXPORT
void _OpenSwiftUICorePlatformImageSetAlignmentRect(OpenSwiftUICoreSystem system, id kitImage, CGRect rect) OPENSWIFTUI_SWIFT_NAME(_CorePlatformImageSetAlignmentRect(system:kitImage:_:));

OPENSWIFTUI_ASSUME_NONNULL_END

OPENSWIFTUI_IMPLICIT_BRIDGING_DISABLED

#endif

#endif /* OpenSwiftUICorePlatformImage_h */
