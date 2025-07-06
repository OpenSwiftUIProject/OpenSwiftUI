//
//  OpenSwiftUICoreView.h
//  OpenSwiftUI_SPI
//
//  Status: WIP
//  Audited for 6.5.4

#ifndef OpenSwiftUICoreView_h
#define OpenSwiftUICoreView_h

#include "OpenSwiftUIBase.h"

#if OPENSWIFTUI_TARGET_OS_DARWIN

#include "OpenSwiftUIViewSystem.h"
#include <QuartzCore/QuartzCore.h>

NS_ASSUME_NONNULL_BEGIN

CALayer * OpenSwiftUICoreViewLayer(OpenSwiftUIViewSystem system, id view) OPENSWIFTUI_SWIFT_NAME(CoreViewLayer(system:view:));

NS_ASSUME_NONNULL_END

#endif /* OPENSWIFTUI_TARGET_OS_DARWIN */

#endif /* OpenSwiftUICoreView_h */
