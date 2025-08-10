//
//  NSLayoutConstraint_AppKitAdditions.h
//  OpenSwiftUI_SPI

#ifndef NSLayoutConstraint_AppKitAdditions_h
#define NSLayoutConstraint_AppKitAdditions_h

#include "OpenSwiftUIBase.h"

#if __has_include(<AppKit/AppKit.h>)

#include <AppKit/AppKit.h>

@interface NSView (NSLayoutConstraint_AppKitAdditions)
@end

@interface NSViewController (NSLayoutConstraint_AppKitAdditions)
@end

#endif /* __has_include(<AppKit/AppKit.h>) */

#endif /* NSLayoutConstraint_AppKitAdditions_h */
