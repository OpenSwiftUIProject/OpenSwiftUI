//
//  CoreColor.h
//  COpenSwiftUI
//  Audited for RELEASE_2024
//  Status: Complete

#ifndef CoreColor_h
#define CoreColor_h

#include "OpenSwiftUIBase.h"

#if OPENSWIFTUI_TARGET_OS_DARWIN

#if OPENSWIFTUI_TARGET_OS_IOS
#include <UIKit/UIKit.h>
#else
#include <AppKit/AppKit.h>
#endif

OPENSWIFTUI_ASSUME_NONNULL_BEGIN

OPENSWIFTUI_EXPORT
BOOL CoreColorPlatformColorGetComponents(BOOL isAppKitBased, id color, CGFloat *red, CGFloat *green, CGFloat *blue, CGFloat *alpha);

OPENSWIFTUI_EXPORT
Class CoreColorGetKitColorClass(BOOL isAppKitBased);

OPENSWIFTUI_ASSUME_NONNULL_END

#endif

#endif /* CoreColor_h */
