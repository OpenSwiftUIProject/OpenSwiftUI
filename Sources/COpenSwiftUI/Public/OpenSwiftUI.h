//
//  OpenSwiftUI.h
//  OpenSwiftUI

#ifndef OPENSWIFTUI_PUBLIC_H
#define OPENSWIFTUI_PUBLIC_H

#if defined(__METAL_VERSION__)
#include "OpenSwiftUI_Metal.h"
#elif defined(__APPLE__)
#import <TargetConditionals.h>

#if TARGET_OS_OSX && __has_include(<AppKit/AppKit.h>)
#import <AppKit/AppKit.h>
#endif

#if !TARGET_OS_OSX && __has_include(<UIKit/UIKit.h>)
#import <UIKit/UIKit.h>
#endif
#endif

#endif /* OPENSWIFTUI_PUBLIC_H */
