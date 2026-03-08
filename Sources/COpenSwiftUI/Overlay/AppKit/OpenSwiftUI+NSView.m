//
//  OpenSwiftUI+NSView.m
//  COpenSwiftUI
//
//  Audited for 6.0.87
//  Status: WIP

#import "OpenSwiftUI+NSView.h"

#if OPENSWIFTUI_TARGET_OS_OSX

void _SetLayerViewDelegate(CALayer *layer, id view) {
    layer.delegate = view;
}

#endif
