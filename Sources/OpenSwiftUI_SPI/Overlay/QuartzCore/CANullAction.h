//
//  CANullAction.h
//  OpenSwiftUI_SPI
//
//  Status: Complete

#ifndef CANullAction_h
#define CANullAction_h

#include "OpenSwiftUIBase.h"

#if __has_include(<QuartzCore/QuartzCore.h>)

#import <QuartzCore/QuartzCore.h>

/// Returns kCFNull as a CAAction to suppress implicit layer animations.
OPENSWIFTUI_EXPORT
id<CAAction> _Nonnull _CANullAction(void);

#endif /* __has_include(<QuartzCore/QuartzCore.h>) */

#endif /* CANullAction_h */
