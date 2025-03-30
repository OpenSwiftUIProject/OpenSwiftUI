//
//  OpenSwiftUI+NSColor.m
//  COpenSwiftUI
//
//  Audited for macOS 15.0
//  Status: WIP

#import "OpenSwiftUI+NSColor.h"

#if OPENSWIFTUI_TARGET_OS_OSX

BOOL _NSColorDependsOnAppearance(NSColor *color) {
    return [color isKindOfClass:NSClassFromString(@"NSDynamicNamedColor")];
}


@implementation NSColor (OpenSwiftUI)

- (instancetype)initWithColor__openSwiftUI__:(NSColor *)color {
    self = color;
    return self;
}

@end

#endif
