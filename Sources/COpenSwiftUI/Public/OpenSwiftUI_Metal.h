//
//  OpenSwiftUI_Metal.h
//  OpenSwiftUI

#ifndef OPENSWIFTUI_METAL_H
#define OPENSWIFTUI_METAL_H

#if defined(__METAL_VERSION__)

#include <metal_stdlib>

namespace OpenSwiftUI {

/// A region of a rasterized layer.
struct Layer {
    metal::texture2d<half> tex;
    float2 info[5];

    /// Samples the layer at a position in user coordinates with linear filtering.
    /// Returns premultiplied RGBA in the layer's working color space.
    half4 sample(float2 p) const {
        p = metal::fma(p.x, info[0], metal::fma(p.y, info[1], info[2]));
        p = metal::clamp(p, info[3], info[4]);
        return tex.sample(metal::sampler(metal::filter::linear), p);
    }
};

} // namespace OpenSwiftUI

#endif /* defined(__METAL_VERSION__) */
#endif /* OPENSWIFTUI_METAL_H */
