//
//  OpenSwiftUI+NSWindow.m
//  COpenSwiftUI

#import "OpenSwiftUI+NSWindow.h"

#if OPENSWIFTUI_TARGET_OS_OSX

CGDirectDisplayID _NSWindowGetCGDisplayID(NSWindow *window) {
    NSScreen *screen = [window screen];
    NSDictionary *deviceDescription = [screen deviceDescription];
    NSNumber *screenNumber = deviceDescription[@"NSScreenNumber"];
    return [screenNumber unsignedIntValue];
}
#endif

