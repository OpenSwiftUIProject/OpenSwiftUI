//
//  OpenSwiftUICoreShadow.h
//  OpenSwiftUI_SPI
//
//  Audited for 6.5.4
//  Status: Complete

#ifndef OpenSwiftUICoreShadow_h
#define OpenSwiftUICoreShadow_h

#include "OpenSwiftUIBase.h"

#if OPENSWIFTUI_TARGET_OS_DARWIN

#include <CoreGraphics/CoreGraphics.h>

OPENSWIFTUI_ASSUME_NONNULL_BEGIN

OPENSWIFTUI_EXPORT
CGSize OpenSwiftUICoreShadowGetOffset(id shadow) OPENSWIFTUI_SWIFT_NAME(CoreShadowGetOffset(_:));

OPENSWIFTUI_EXPORT
CGFloat OpenSwiftUICoreShadowGetBlurRadius(id shadow) OPENSWIFTUI_SWIFT_NAME(CoreShadowGetBlurRadius(_:));

OPENSWIFTUI_EXPORT
id _Nullable OpenSwiftUICoreShadowGetPlatformColor(id shadow) OPENSWIFTUI_SWIFT_NAME(CoreShadowGetPlatformColor(_:));

OPENSWIFTUI_EXPORT
Class _Nullable OpenSwiftUICoreShadowClass(void) OPENSWIFTUI_SWIFT_NAME(CoreShadowClass());

OPENSWIFTUI_ASSUME_NONNULL_END

#endif

#endif /* OpenSwiftUICoreShadow_h */
