//
//  AccessibilitySharedSupport.h
//  OpenSwiftUI_SPI
//
//  Audited for 6.5.4
//  Status: Complete

#ifndef AccessibilitySharedSupport_h
#define AccessibilitySharedSupport_h

#include "OpenSwiftUIBase.h"

#if OPENSWIFTUI_TARGET_OS_DARWIN

#import <Foundation/Foundation.h>

OPENSWIFTUI_EXTERN_C_BEGIN
OPENSWIFTUI_ASSUME_NONNULL_BEGIN

OPENSWIFTUI_EXPORT
NSString *soft_AXSSAccessibilityDescriptionForSymbolName(NSString *symbolName, NSString *localeIdentifier);

OPENSWIFTUI_ASSUME_NONNULL_END
OPENSWIFTUI_EXTERN_C_END

#endif /* OPENSWIFTUI_TARGET_OS_DARWIN */

#endif /* AccessibilitySharedSupport_h */
