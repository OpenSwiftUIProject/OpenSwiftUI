//
//  NSView_NSSafeAreas.h
//  OpenSwiftUI_SPI

#ifndef NSView_NSSafeAreas_h
#define NSView_NSSafeAreas_h

#include "OpenSwiftUIBase.h"

#if __has_include(<AppKit/AppKit.h>)

#include <AppKit/AppKit.h>

@interface NSView (NSSafeAreas)
@property (nonatomic, assign, readonly) NSEdgeInsets computedSafeAreaInsets;
@end

#endif /* __has_include(<AppKit/AppKit.h>) */

#endif /* NSView_NSSafeAreas_h */
