# SwiftUI Compatibility Gaps

This document tracks large SwiftUI feature areas that are not yet supported, or are only partially supported, by OpenSwiftUI. It is intentionally broad: use it as a contributor-facing map, not as an API-by-API compatibility matrix.

Last updated: 2026-05-18.

## Major Unsupported Areas

| Area | Current state | What is still missing |
|------|---------------|-----------------------|
| Text layout and rendering | Partial | Basic `Text` structure exists, but SwiftUI-compatible measurement, line breaking, truncation, baseline handling, rich attributes, attachments, and renderer integration are still incomplete. |
| Text localization and formatted text | Partial | `LocalizedStringKey` / localized `Text` support is mostly placeholder-level. Bundle/table/locale lookup, interpolation, `FormatStyle`, date/timer text, and formatter-backed text need more work. |
| Complex `Path` and shape geometry | Partial | Simple path construction exists, but advanced `Path` behavior is incomplete, including robust CoreGraphics bridging, iteration, containment, trimming, stroked paths, rounded-rect variants, and platform parity for path storage. |
| Gradient and shape style system | Partial | Gradient data types exist, but full SwiftUI-style gradient resolution, color-space handling, rendering, animation behavior, and integration with `ShapeStyle` / display-list rendering are not complete. |
| Gesture system | Partial | Gesture types and modifiers are present, but the gesture graph, event routing, platform recognizer bridge, hit testing, gesture state propagation, and composed gestures are still largely unfinished. |

## Adjacent Gaps

These areas are closely tied to the major gaps above and may need to move together:

- Font resolution, font modifiers, dynamic type, and platform font bridging.
- Text accessibility attributes and attributed-string export/import.
- Shape layer and mask rendering for filled, stroked, clipped, and styled paths.
- Material, tint, foreground/background style resolution, and multicolor style rendering.
- Gesture debug support and compatibility tests for user interaction behavior.

## Source Areas

The relevant implementation is mostly under:

- `Sources/OpenSwiftUICore/View/Text`
- `Sources/OpenSwiftUICore/Shape`
- `Sources/OpenSwiftUICore/Graphic/Gradient`
- `Sources/OpenSwiftUICore/Shape/ShapeStyle`
- `Sources/OpenSwiftUICore/Event/Gesture`

When a major area becomes usable, update this document with a short note and add focused compatibility tests near the implementation.
