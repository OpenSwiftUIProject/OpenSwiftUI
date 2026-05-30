//
//  CANullAction.m
//  OpenSwiftUI_SPI
//
//  Audited for 6.5.4
//  Status: Complete

#import "CANullAction.h"

#if __has_include(<QuartzCore/QuartzCore.h>)

id<CAAction> _CANullAction(void) {
    return (id<CAAction>)kCFNull;
}

#endif /* __has_include(<QuartzCore/QuartzCore.h>) */
