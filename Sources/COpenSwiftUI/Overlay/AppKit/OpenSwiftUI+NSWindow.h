//
//  OpenSwiftUI+NSWindow.h
//  COpenSwiftUI

#ifndef OpenSwiftUI_NSWindow_h
#define OpenSwiftUI_NSWindow_h

#include "OpenSwiftUIBase.h"

#if OPENSWIFTUI_TARGET_OS_OSX

#import <AppKit/AppKit.h>
#import <CoreGraphics/CGDirectDisplay.h>

OPENSWIFTUI_ASSUME_NONNULL_BEGIN

OPENSWIFTUI_EXPORT
CGDirectDisplayID _NSWindowGetCGDisplayID(NSWindow * _Nullable window);

OPENSWIFTUI_ASSUME_NONNULL_END

#endif /* OPENSWIFTUI_TARGET_OS_OSX */

#endif /* OpenSwiftUI_NSWindow_h */

