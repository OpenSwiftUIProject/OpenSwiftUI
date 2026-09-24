# SwiftUI Compatibility Gaps

This document tracks large SwiftUI feature areas that are not yet supported, or are only partially supported, by OpenSwiftUI. It is intentionally broad: use it as a contributor-facing map, not as an API-by-API compatibility matrix.

Last updated: 2026-09-24.

## Major Unsupported Areas

| Area | Current state | What is still missing |
|------|---------------|-----------------------|
| Complex `Path` and shape geometry | Partial | Simple path construction exists, but advanced `Path` behavior is incomplete, including robust CoreGraphics bridging, iteration, containment, trimming, stroked paths, rounded-rect variants, and platform parity for path storage. |
| Gradient and shape style system | Partial | Gradient data types exist, but full SwiftUI-style gradient resolution, color-space handling, rendering, animation behavior, and integration with `ShapeStyle` / display-list rendering are not complete. |

## Adjacent Gaps

These related areas still need work:

- Non-Darwin text layout, font resolution, and platform font bridging.
- Remaining text accessibility attributes and attributed-string conversion helpers.
- Shape layer and mask rendering for filled, stroked, clipped, and styled paths.
- Material, tint, foreground/background style resolution, and multicolor style rendering.

## Source Areas

The remaining gaps correspond to these source areas:

- `Sources/OpenSwiftUICore/Shape`: path and shape geometry.
- `Sources/OpenSwiftUICore/Graphic/Gradient`: gradient resolution and rendering.
- `Sources/OpenSwiftUICore/Shape/ShapeStyle`: material, tint, and style resolution.
- `Sources/OpenSwiftUICore/View/Text`: non-Darwin text and font support, remaining accessibility attributes, and attributed-string conversion.

When a major area becomes usable, remove it from the gap list, update the README feature list, and add focused compatibility tests near the implementation.
