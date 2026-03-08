//
//  OpenSwiftUI+NSView.h
//  COpenSwiftUI
//
//  Audited for 6.0.87
//  Status: WIP

#ifndef OpenSwiftUI_NSView_h
#define OpenSwiftUI_NSView_h

#include "OpenSwiftUIBase.h"

#if OPENSWIFTUI_TARGET_OS_OSX

#import <AppKit/AppKit.h>
#import <QuartzCore/CALayer.h>

OPENSWIFTUI_ASSUME_NONNULL_BEGIN

@interface NSView (OpenSwiftUI)

@property (strong, nullable) NSView *maskView;

- (void)setFlipped:(BOOL)flipped;

@end

void _SetLayerViewDelegate(CALayer *layer, id view);

OPENSWIFTUI_ASSUME_NONNULL_END

#endif /* OPENSWIFTUI_TARGET_OS_OSX */

#endif /* OpenSwiftUI_NSView_h */
