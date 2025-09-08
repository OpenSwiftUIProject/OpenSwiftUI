//
//  OpenSwiftUICoreView.m
//  OpenSwiftUI_SPI
//
//  Status: WIP
//  Audited for 6.5.4

#include "OpenSwiftUICoreView.h"

#if OPENSWIFTUI_TARGET_OS_DARWIN

#if OPENSWIFTUI_TARGET_OS_IOS || OPENSWIFTUI_TARGET_OS_VISION
#include <UIKit/UIKit.h>
#include "Shims/UIKit/UIKit_Private.h"
#else
#include <AppKit/AppKit.h>
#endif

CALayer * OpenSwiftUICoreViewLayer(OpenSwiftUIViewSystem system, id view) {
    if (system == OpenSwiftUIViewSystemCALayer) {
        return view;
    } else {
        return [view layer];
    }
}

#if OPENSWIFTUI_TARGET_OS_IOS || OPENSWIFTUI_TARGET_OS_VISION
UIView * _UIKitCreateCustomView(Class class, CALayer *layer) {
    return [[class alloc] _initWithLayer:layer];
}
#endif

#endif /* OPENSWIFTUI_TARGET_OS_DARWIN */
