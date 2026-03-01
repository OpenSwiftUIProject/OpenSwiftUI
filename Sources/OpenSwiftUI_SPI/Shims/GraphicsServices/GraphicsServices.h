//
//  GraphicsServices.h
//  OpenSwiftUI_SPI
//
//  Status: Complete

#ifndef GraphicsServices_h
#define GraphicsServices_h

#include "OpenSwiftUIBase.h"

#if OPENSWIFTUI_TARGET_OS_DARWIN

OPENSWIFTUI_ASSUME_NONNULL_BEGIN

NSString * _SimulatorSystemRootDirectory(void);

OPENSWIFTUI_ASSUME_NONNULL_END

#endif /* OPENSWIFTUI_TARGET_OS_DARWIN */

#endif /* GraphicsServices_h */
