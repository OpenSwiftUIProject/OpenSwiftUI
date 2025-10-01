//
//  OpenSwiftUI+NSColor.h
//  COpenSwiftUI
//
//  Audited for 6.0.87
//  Status: WIP

#ifndef OpenSwiftUI_NSColor_h
#define OpenSwiftUI_NSColor_h

#include "OpenSwiftUIBase.h"

#if OPENSWIFTUI_TARGET_OS_OSX

#import <AppKit/AppKit.h>

OPENSWIFTUI_ASSUME_NONNULL_BEGIN

OPENSWIFTUI_EXPORT
BOOL _NSColorDependsOnAppearance(NSColor *color);

@interface NSColor (OpenSwiftUI_NSColor)

// Workaround Swift initializer limitation
- (instancetype)initWithColor__openSwiftUI__:(NSColor *)color;

@end

OPENSWIFTUI_ASSUME_NONNULL_END

#endif /* OPENSWIFTUI_TARGET_OS_OSX */

#endif /* OpenSwiftUI_NSColor_h */
