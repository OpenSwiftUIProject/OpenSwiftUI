//
//  ColorSpace.c
//  OpenSwiftUI_SPI
//
//  Audited for 6.5.4
//  Status: Complete

#include "ColorSpace.h"

#if __has_include(<CoreGraphics/CGColorSpace.h>)

#include <dispatch/dispatch.h>

CGColorSpaceRef _CGColorSpaceGetPerceptual(void) {
    static CGColorSpaceRef space;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        static const CGFloat white[] = {0.987, 0.982, 0.974};
        static const CGFloat gamma[] = {2.2, 2.2, 2.2};
        static const CGFloat matrix[] = {
            1.227013851103521, -0.04058017842328059, -0.0763812845057069,
            -0.5577999806518222, 1.11225686961683, -0.4214819784180127,
            0.2812561489664678, -0.07167667866560119, 1.586163220440795,
        };
        // The cache owns the Create result for the lifetime of the process.
        space = CGColorSpaceCreateCalibratedRGB(white, NULL, gamma, matrix);
    });
    return space;
}

#endif /* CoreGraphics/CGColorSpace.h */
