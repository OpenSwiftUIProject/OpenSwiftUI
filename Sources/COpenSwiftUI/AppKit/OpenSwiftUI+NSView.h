//
//  OpenSwiftUI+NSView.h
//  COpenSwiftUI
//
//  Audited for macOS 15.0
//  Status: WIP

#ifndef OpenSwiftUI_NSView_h
#define OpenSwiftUI_NSView_h

#include "OpenSwiftUIBase.h"

#if OPENSWIFTUI_TARGET_OS_OSX

#import <AppKit/AppKit.h>

OPENSWIFTUI_ASSUME_NONNULL_BEGIN

@interface NSView (OpenSwiftUI)

@property (strong, nullable) NSView *maskView;

- (void)setFlipped:(BOOL)flipped;

@end

OPENSWIFTUI_ASSUME_NONNULL_END

#endif /* OPENSWIFTUI_TARGET_OS_OSX */

#endif /* OpenSwiftUI_NSView_h */
