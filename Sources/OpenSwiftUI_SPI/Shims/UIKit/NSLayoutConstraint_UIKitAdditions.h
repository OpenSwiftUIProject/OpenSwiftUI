//
//  NSLayoutConstraint_UIKitAdditions.h
//  OpenSwiftUI_SPI

#ifndef NSLayoutConstraint_UIKitAdditions_h
#define NSLayoutConstraint_UIKitAdditions_h

#include "OpenSwiftUIBase.h"

#if __has_include(<UIKit/UIKit.h>)

#include <UIKit/UIKit.h>

@interface UIView (NSLayoutConstraint_UIKitAdditions)
- (void)_setHostsLayoutEngine:(BOOL)hostsLayoutEngine;
@end

@interface UIViewController (NSLayoutConstraint_UIKitAdditions)
- (void)_setViewHostsLayoutEngine:(BOOL)hostsLayoutEngine;
@end

#endif /* __has_include(<UIKit/UIKit.h>) */

#endif /* NSLayoutConstraint_UIKitAdditions_h */
