//
//  AXRuntime.h
//  OpenSwiftUI_SPI
//
//  Audited for 6.5.4
//  Status: Complete

#ifndef AXRuntime_h
#define AXRuntime_h

#include "OpenSwiftUIBase.h"

#if OPENSWIFTUI_TARGET_OS_DARWIN

#import <Foundation/Foundation.h>

OPENSWIFTUI_EXTERN_C_BEGIN
OPENSWIFTUI_ASSUME_NONNULL_BEGIN

OPENSWIFTUI_EXPORT
void *AXRuntimeLibrary(void);

OPENSWIFTUI_EXPORT
NSString *AXOpenSwiftUIInteractionLocationDescriptorDefaultName(void);

OPENSWIFTUI_EXPORT
NSString *AXOpenSwiftUIMoveToElementNotificationKeyElement(void);

OPENSWIFTUI_EXPORT
NSString *AXOpenSwiftUIPerformElementUpdateImmediatelyToken(void);

OPENSWIFTUI_ASSUME_NONNULL_END
OPENSWIFTUI_EXTERN_C_END

#endif /* OPENSWIFTUI_TARGET_OS_DARWIN */

#endif /* AXRuntime_h */
