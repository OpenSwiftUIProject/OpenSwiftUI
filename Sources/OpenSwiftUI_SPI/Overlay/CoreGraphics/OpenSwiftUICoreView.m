//
//  OpenSwiftUICoreView.m
//  OpenSwiftUI_SPI
//
//  Status: WIP
//  Audited for 6.5.4

#import "OpenSwiftUICoreView.h"

#if OPENSWIFTUI_TARGET_OS_DARWIN

CALayer * OpenSwiftUICoreViewLayer(OpenSwiftUIViewSystem system, id view) {
    if (system == OpenSwiftUIViewSystemCALayer) {
        return view;
    } else {
        return [view layer];
    }
}

#endif /* OPENSWIFTUI_TARGET_OS_DARWIN */
