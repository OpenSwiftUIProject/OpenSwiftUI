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

#if OPENSWIFTUI_TARGET_OS_IOS || OPENSWIFTUI_TARGET_OS_VISION
#include <UIKit/UIKit.h>
#else
#include <AppKit/AppKit.h>
#endif

NS_ASSUME_NONNULL_BEGIN

CALayer * OpenSwiftUICoreViewLayer(OpenSwiftUIViewSystem system, id view) OPENSWIFTUI_SWIFT_NAME(CoreViewLayer(system:view:));

#if OPENSWIFTUI_TARGET_OS_IOS || OPENSWIFTUI_TARGET_OS_VISION
UIView * _UIKitCreateCustomView(Class class, CALayer *layer);
#endif

NS_ASSUME_NONNULL_END

#endif /* OPENSWIFTUI_TARGET_OS_DARWIN */

#endif /* OpenSwiftUICoreView_h */
