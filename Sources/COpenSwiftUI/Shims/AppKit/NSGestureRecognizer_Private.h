//
//  NSGestureRecognizer_Private.h
//  COpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete

#ifndef NSGestureRecognizer_Private_h
#define NSGestureRecognizer_Private_h

#include "OpenSwiftUIBase.h"

#if __has_include(<AppKit/AppKit.h>)

#import <AppKit/AppKit.h>

OPENSWIFTUI_ASSUME_NONNULL_BEGIN

@interface NSGestureRecognizer (OpenSwiftUI_SPI)
- (void)_updateForActiveEvents;
- (BOOL)_hasUnmetFailureRequirements;
@end

@interface NSWindow (OpenSwiftUI_SPI)

/// Replaces the existing left-button event target with the specified view.
///
/// For a left-mouse-down event, updates the window's nonnull `_lastLeftHit`.
/// AppKit uses this target to route subsequent mouse-dragged and mouse-up
/// events, subject to its normal event-delivery checks. Other event types,
/// or a window with no existing left-button target, leave the target unchanged.
///
/// This method does not perform a hit test or send the event. It does not
/// change the separate targets used for pressure or momentum-scroll events.
- (void)_latchView:(NSView *)view forEvent:(NSEvent *)event;
@end

OPENSWIFTUI_ASSUME_NONNULL_END

#endif /* __has_include(<AppKit/AppKit.h>) */

#endif /* NSGestureRecognizer_Private_h */
