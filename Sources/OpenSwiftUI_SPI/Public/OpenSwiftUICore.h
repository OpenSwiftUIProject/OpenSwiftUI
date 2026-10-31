//
//  OpenSwiftUICore.h
//  OpenSwiftUICore

#ifndef OPENSWIFTUICORE_PUBLIC_H
#define OPENSWIFTUICORE_PUBLIC_H

#if defined(__METAL_VERSION__)
#include "OpenSwiftUI_Metal.h"
#elif defined(__APPLE__)
#import <TargetConditionals.h>
#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <CoreText/CoreText.h>

#if __has_include(<QuartzCore/QuartzCore.h>)
#import <QuartzCore/QuartzCore.h>
#endif

#if TARGET_OS_VISION && __has_include(<Spatial/Spatial.h>)
#import <Spatial/Spatial.h>
#endif
#endif

#endif /* OPENSWIFTUICORE_PUBLIC_H */
