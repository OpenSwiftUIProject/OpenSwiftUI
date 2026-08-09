//
//  DisplayListPrinterDualTests.swift
//  OpenSwiftUISymbolDualTests

#if canImport(SwiftUI, _underlyingVersion: 6.5.4)
import Foundation
import OpenRenderBoxShims
@_spi(Private) @testable import OpenSwiftUICore
import Testing

extension DisplayList {
    var swiftUI_description: String {
        @_silgen_name("OpenSwiftUITestStub_DisplayListDescription")
        get
    }

    var swiftUI_minimalDescription: String {
        @_silgen_name("OpenSwiftUITestStub_DisplayListMinimalDescription")
        get
    }
}

extension DisplayList.Item {
    var swiftUI_description: String {
        @_silgen_name("OpenSwiftUITestStub_DisplayListItemDescription")
        get
    }
}

@MainActor
@Suite(.serialized)
struct DisplayListPrinterDualTests {
    @Test(arguments: displayListCases)
    fileprivate func descriptionOfDL(
        _ fixture: DisplayListFixture,
        _ expectedDescription: DualExpectedString,
        _ expectedMinimalDescription: DualExpectedString
    ) {
        let displayList = fixture.makeDisplayList()
        #expect(displayList.description == expectedDescription.openSwiftUI)
        #expect(displayList.minimalDescription == expectedMinimalDescription.openSwiftUI)
        guard isSwiftUIVersionAtLeast65AndBefore70 else { return }
        // Projected payloads can retain OpenSwiftUI type metadata in SwiftUI's description.
        #expect(displayList.swiftUI_description.normalizeSwiftUI == expectedDescription.swiftUI)
        #expect(displayList.swiftUI_minimalDescription == expectedMinimalDescription.swiftUI)
    }

    @Test(arguments: itemCases)
    fileprivate func descriptionOfDLItem(
        _ fixture: ItemFixture,
        _ expectedDescription: DualExpectedString
    ) {
        let item = fixture.makeItem()
        #expect(item.description == expectedDescription.openSwiftUI)
        guard isSwiftUIVersionAtLeast65AndBefore70 else { return }
        // Projected payloads can retain OpenSwiftUI type metadata in SwiftUI's description.
        #expect(item.swiftUI_description.normalizeSwiftUI == expectedDescription.swiftUI)
    }
}

private struct DualExpectedString: Sendable {
    let openSwiftUI: String
    let swiftUI: String

    private init(openSwiftUI: String, swiftUI: String) {
        self.openSwiftUI = openSwiftUI
        self.swiftUI = swiftUI
    }

    init(openSwiftUI: String) {
        self.init(
            openSwiftUI: openSwiftUI,
            swiftUI: openSwiftUI.normalizeSwiftUI
        )
    }
}

extension String {
    package var normalizeSwiftUI: String {
        replacingOccurrences(of: "OpenSwiftUI", with: "SwiftUI")
    }
}

private enum DisplayListFixture: String, Sendable, CustomTestStringConvertible {
    case contents
    case effects
    case filters

    var testDescription: String { rawValue }

    @MainActor
    func makeDisplayList() -> DisplayList {
        switch self {
        case .contents:
            contentDisplayList()
        case .effects:
            effectDisplayList()
        case .filters:
            filterDisplayList()
        }
    }
}

private enum ItemFixture: String, Sendable, CustomTestStringConvertible {
    case empty

    var testDescription: String { rawValue }

    @MainActor
    func makeItem() -> DisplayList.Item {
        DisplayList.Item(
            .empty,
            frame: CGRect(x: 1, y: 2, width: 3, height: 4),
            identity: .init(decodedValue: 1),
            version: .init(decodedValue: 2)
        )
    }
}

private let displayListCases: [(DisplayListFixture, DualExpectedString, DualExpectedString)] = [
    (.contents, expectedContentsDescription, expectedContentsMinimalDescription),
    (.effects, expectedEffectsDescription, expectedEffectsMinimalDescription),
    (.filters, expectedFiltersDescription, expectedFiltersMinimalDescription),
]

private let itemCases: [(ItemFixture, DualExpectedString)] = [
    (
        .empty,
        DualExpectedString(
            openSwiftUI: """
            (display-list-item
              (item #:identity 1 #:version 2
                (frame (1.0 2.0; 3.0 4.0))))
            """
        )
    ),
]

private let expectedContentsDescription = DualExpectedString(
    openSwiftUI: """
(display-list
  (item #:version 0
    (frame (0.0 0.0; 0.0 0.0)))
  (item #:version 0
    (frame (0.0 0.0; 0.0 0.0))
    (content-seed 1)
    (backdrop
      (scale 2.0)
      (color #FFFFFFFF)
      (filters [])))
  (item #:version 0
    (frame (0.0 0.0; 0.0 0.0))
    (content-seed 1)
    (color #FFFFFFFF))
  (item #:version 0
    (frame (0.0 0.0; 0.0 0.0))
    (content-seed 1)
    (chameleon-color
      (color #000000FF)
      (filters [])))
  (item #:version 0
    (frame (0.0 0.0; 0.0 0.0))
    (content-seed 1)
    (image #:size (10.0 5.0)))
  (item #:version 0
    (frame (0.0 0.0; 0.0 0.0))
    (content-seed 1)
    (shape
      (path 1 2 m 4 2 l 4 6 l 1 6 l h)
      (paint OpenSwiftUI._AnyResolvedPaint<OpenSwiftUI.Color.Resolved>)
      (style FillStyle(isEOFilled: true, isAntialiased: false))))
  (item #:version 0
    (frame (0.0 0.0; 0.0 0.0))
    (content-seed 1)
    (shadow
      (path 1 2 m 4 2 l 4 6 l 1 6 l h)
      (shadow ResolvedShadowStyle(color: #000000FF, radius: 2.0, offset: (3.0, 4.0), midpoint: 0.5, kind: OpenSwiftUI.ShadowStyle.Kind(rawValue: 0)))))
  (item #:version 0 #:required true
    (frame (0.0 0.0; 0.0 0.0))
    (content-seed 1)
    (platform-view))
  (item #:version 0
    (frame (0.0 0.0; 0.0 0.0))
    (content-seed 1)
    (platform-layer))
  (item #:version 0
    (frame (0.0 0.0; 0.0 0.0))
    (content-seed 1)
    (text "Hello" #:size (100.0, 20.0)))
  (item #:version 0
    (frame (0.0 0.0; 0.0 0.0))
    (content-seed 1)
    (text "" #:size (0.0, 0.0)))
  (item #:version 0
    (frame (0.0 0.0; 0.0 0.0))
    (content-seed 1)
    (flattened #:origin (3.0 4.0)
      (item #:version 0
        (frame (0.0 0.0; 0.0 0.0))
        (content-seed 2)
        (color #FFFFFFFF))))
  (item #:version 0
    (frame (0.0 0.0; 0.0 0.0))
    (content-seed 1)
    (drawing #:offset (5.0 6.0) #:accelerated #:alpha-only))
  (item #:version 0 #:views true
    (frame (0.0 0.0; 0.0 0.0))
    (content-seed 1)
    (view #:type EmptyViewFactory))
  (item #:version 0 #:views true
    (frame (0.0 0.0; 0.0 0.0))
    (content-seed 1)
    (placeholder #2)))
"""
)

private let expectedContentsMinimalDescription = DualExpectedString(
    openSwiftUI: "(DL(I:0)(I:0 B)(I:0 C)(I:0 CH)(I:0 IM)(I:0 S)(I:0 SH)(I:0 PV)(I:0 PL)(I:0 T)(I:0 T)(I:0(F(I:0 C)))(I:0 D)(I:0 V:EmptyViewFactory)(I:0 @#2))"
)

private let expectedEffectsDescription = DualExpectedString(
    openSwiftUI: """
(display-list
  (item #:version 0
    (frame (0.0 0.0; 0.0 0.0))
    (effect))
  (item #:version 0
    (frame (0.0 0.0; 0.0 0.0))
    (effect #:geometry-group))
  (item #:version 0
    (frame (0.0 0.0; 0.0 0.0))
    (effect #:compositing-group))
  (item #:version 0
    (frame (0.0 0.0; 0.0 0.0))
    (effect #:backdrop-group true))
  (item #:version 0
    (frame (0.0 0.0; 0.0 0.0))
    (effect #:archive nil))
  (item #:version 0
    (frame (0.0 0.0; 0.0 0.0))
    (effect #:archive 00000000-0000-0000-0000-000000000001))
  (item #:version 0 #:required true
    (frame (0.0 0.0; 0.0 0.0))
    (effect #:primary-fg-layer #:secondary-fg-layer #:tertiary-fg-layer #:quaternary-fg-layer #:ignores-events #:privacy-sensitive #:archives-interactive-controls #:screencapture-prohibited))
  (item #:version 0 #:required true
    (frame (0.0 0.0; 0.0 0.0))
    (effect #:platform-group))
  (item #:version 0
    (frame (0.0 0.0; 0.0 0.0))
    (effect #:opacity 0.5))
  (item #:version 0
    (frame (0.0 0.0; 0.0 0.0))
    (effect #:blend-mode blendMode(OpenSwiftUI.GraphicsContext.BlendMode(rawValue: 0))))
  (item #:version 0
    (frame (0.0 0.0; 0.0 0.0))
    (effect
      (clip
        (path 1 2 m 4 2 l 4 6 l 1 6 l h)
        (style FillStyle(isEOFilled: false, isAntialiased: true))
        (options ClipOptions(rawValue: 1)))))
  (item #:version 0
    (frame (0.0 0.0; 0.0 0.0))
    (effect
      (mask
        (options ClipOptions(rawValue: 1)))))
  (item #:version 0
    (frame (0.0 0.0; 0.0 0.0))
    (effect
      (transform affine(__C.CGAffineTransform(a: 1.0, b: 0.0, c: 0.0, d: 1.0, tx: 1.0, ty: 2.0)))))
  (item #:version 0
    (frame (0.0 0.0; 0.0 0.0))
    (effect
      (animation
        (animation OffsetAnimation(from: OpenSwiftUI._OffsetEffect(offset: (0.0, 0.0)), to: OpenSwiftUI._OffsetEffect(offset: (1.0, 2.0)), animation: AnyAnimator(OpenSwiftUI.DefaultAnimation()))))))
  (item #:version 0
    (frame (0.0 0.0; 0.0 0.0))
    (effect
      (contentTransition
        (transition ContentTransition(storage: OpenSwiftUI.ContentTransition.Storage.named(OpenSwiftUI.ContentTransition.NamedTransition(name: OpenSwiftUI.ContentTransition.NamedTransition.Name.default, layoutDirection: nil, style: nil)), isReplaceable: false))
        (animation DefaultAnimation()))))
  (item #:version 0 #:views true
    (frame (0.0 0.0; 0.0 0.0))
    (effect
      (view #:type EmptyViewFactory)))
  (item #:version 0
    (frame (0.0 0.0; 0.0 0.0))
    (effect
      (accessibility)))
  (item #:version 0
    (frame (0.0 0.0; 0.0 0.0))
    (effect))
  (item #:version 0
    (frame (0.0 0.0; 0.0 0.0))
    (effect
      (state #0000000000000000000000000000000000000000)))
  (item #:version 0
    (frame (0.0 0.0; 0.0 0.0))
    (effect
      (interpolatorRoot
        (content-origin (3.0, 4.0))
        (content-offset (5.0, 6.0)))))
  (item #:version 0 #:required true
    (frame (0.0 0.0; 0.0 0.0))
    (effect
      (interpolatorLayer #:serial 7)))
  (item #:version 0
    (frame (0.0 0.0; 0.0 0.0))
    (effect
      (interpolator-animation
        (value #0000000000000000000000000000000000000000)
        (animation DefaultAnimation()))))
  (item #:version 0
    (frame (0.0 0.0; 0.0 0.0))
    (states
      (state #0000000000000000000000000000000000000000
        (item #:version 0
          (frame (0.0 0.0; 0.0 0.0))
          (content-seed 2)
          (color #FFFFFFFF))))))
"""
)

private let expectedEffectsMinimalDescription = DualExpectedString(
    openSwiftUI: "(DL(I:0(E))(I:0(E GG))(I:0(E CG))(I:0(E BG))(I:0(E A:nil))(I:0(E A:00000000-0000-0000-0000-000000000001))(I:0(E PR))(I:0(E PG))(I:0(E O))(I:0(E B))(I:0(E C))(I:0(E M))(I:0(E T))(I:0(E AN))(I:0(E TR))(I:0(E(V:EmptyViewFactory)))(I:0(E AX))(I:0(E PL))(I:0(E H:#0000000000000000000000000000000000000000))(I:0(E IR))(I:0(E IL))(I:0(E IA))(I:0(states(#0000000000000000000000000000000000000000(I:0 C)))))"
)

private let expectedFiltersDescription = DualExpectedString(
    openSwiftUI: """
(display-list
  (item #:version 0
    (frame (0.0 0.0; 0.0 0.0))
    (effect
      (filter
        (blur #:radius 1.0))))
  (item #:version 0
    (frame (0.0 0.0; 0.0 0.0))
    (effect
      (filter
        (variable-blur #:radius 2.0))))
  (item #:version 0
    (frame (0.0 0.0; 0.0 0.0))
    (effect
      (filter
        (average-color))))
  (item #:version 0
    (frame (0.0 0.0; 0.0 0.0))
    (effect
      (filter
        (shadow
          (kind 0)
          (radius 2.0)
          (offset (3.0, 4.0)
          (color #000000FF)))))
  (item #:version 0
    (frame (0.0 0.0; 0.0 0.0))
    (effect
      (filter
        (projection ProjectionTransform(m11: 2.0, m12: 0.0, m13: 0.0, m21: 0.0, m22: 3.0, m23: 0.0, m31: 0.0, m32: 0.0, m33: 1.0)))))
  (item #:version 0
    (frame (0.0 0.0; 0.0 0.0))
    (effect
      (filter
        (color-matrix _ColorMatrix(m11: 1.0, m12: 0.0, m13: 0.0, m14: 0.0, m15: 0.0, m21: 0.0, m22: 1.0, m23: 0.0, m24: 0.0, m25: 0.0, m31: 0.0, m32: 0.0, m33: 1.0, m34: 0.0, m35: 0.0, m41: 0.0, m42: 0.0, m43: 0.0, m44: 1.0, m45: 0.0)))))
  (item #:version 0
    (frame (0.0 0.0; 0.0 0.0))
    (effect
      (filter
        (premultiplied-color-matrix _ColorMatrix(m11: 1.0, m12: 0.0, m13: 0.0, m14: 0.0, m15: 0.0, m21: 0.0, m22: 1.0, m23: 0.0, m24: 0.0, m25: 0.0, m31: 0.0, m32: 0.0, m33: 1.0, m34: 0.0, m35: 0.0, m41: 0.0, m42: 0.0, m43: 0.0, m44: 1.0, m45: 0.0)))))
  (item #:version 0
    (frame (0.0 0.0; 0.0 0.0))
    (effect
      (filter
        (color-multiply #FFFFFFFF))))
  (item #:version 0
    (frame (0.0 0.0; 0.0 0.0))
    (effect
      (filter
        (hue-rotation 90.0deg))))
  (item #:version 0
    (frame (0.0 0.0; 0.0 0.0))
    (effect
      (filter
        (saturation 0.5))))
  (item #:version 0
    (frame (0.0 0.0; 0.0 0.0))
    (effect
      (filter
        (brightness 0.25))))
  (item #:version 0
    (frame (0.0 0.0; 0.0 0.0))
    (effect
      (filter
        (contrast 2.0))))
  (item #:version 0
    (frame (0.0 0.0; 0.0 0.0))
    (effect
      (filter
        (luminance-to-alpha))))
  (item #:version 0
    (frame (0.0 0.0; 0.0 0.0))
    (effect
      (filter
        (color-invert))))
  (item #:version 0
    (frame (0.0 0.0; 0.0 0.0))
    (effect
      (filter
        (grayscale 0.75))))
  (item #:version 0
    (frame (0.0 0.0; 0.0 0.0))
    (effect
      (filter
        (color-monochrome #FFFFFFFF #:amount 0.5 #:bias 0.25))))
  (item #:version 0
    (frame (0.0 0.0; 0.0 0.0))
    (effect
      (filter
        (vibrant-color-matrix _ColorMatrix(m11: 1.0, m12: 0.0, m13: 0.0, m14: 0.0, m15: 0.0, m21: 0.0, m22: 1.0, m23: 0.0, m24: 0.0, m25: 0.0, m31: 0.0, m32: 0.0, m33: 1.0, m34: 0.0, m35: 0.0, m41: 0.0, m42: 0.0, m43: 0.0, m44: 1.0, m45: 0.0)))))
  (item #:version 0
    (frame (0.0 0.0; 0.0 0.0))
    (effect
      (filter
        (luminance-curve Curve(values: (0.0, 0.25, 0.75, 1.0)) #:amount 0.5))))
  (item #:version 0
    (frame (0.0 0.0; 0.0 0.0))
    (effect
      (filter
        (color-curves #:red Curve(values: (0.0, 0.25, 0.75, 1.0)) #:green Curve(values: (0.0, 0.25, 0.75, 1.0)) #:blue Curve(values: (0.0, 0.25, 0.75, 1.0)) #:opacity Curve(values: (0.0, 0.25, 0.75, 1.0))))))
  (item #:version 0
    (frame (0.0 0.0; 0.0 0.0))
    (effect
      (filter
        (shader ShaderFilter(shader: OpenSwiftUI.Shader.ResolvedShader(rbShader: nil, maxSampleOffset: (1.0, 2.0), options: OpenSwiftUI.Shader.Options(rawValue: 3)), size: (3.0, 4.0))))))
  (item #:version 0
    (frame (0.0 0.0; 0.0 0.0))
    (effect
      (filter
        (alpha-threshold #000000FF #:amount 0.5)))))
"""
)

private let expectedFiltersMinimalDescription = DualExpectedString(
    openSwiftUI: "(DL(I:0(E F))(I:0(E F))(I:0(E F))(I:0(E F))(I:0(E F))(I:0(E F))(I:0(E F))(I:0(E F))(I:0(E F))(I:0(E F))(I:0(E F))(I:0(E F))(I:0(E F))(I:0(E F))(I:0(E F))(I:0(E F))(I:0(E F))(I:0(E F))(I:0(E F))(I:0(E F))(I:0(E F)))"
)

@MainActor
private func contentDisplayList() -> DisplayList {
    let child = DisplayList(contentItem(.color(.white), seed: 2))
    let styledText = resolvedStyledText("Hello")
    let emptyText = resolvedStyledText(nil)
    let drawingOptions = RasterizationOptions(flags: [.isAccelerated, .alphaOnly])

    return DisplayList([
        displayListItem(.empty),
        contentItem(.backdrop(.init(scale: 2, color: .white, filters: []))),
        contentItem(.color(.white)),
        contentItem(.chameleonColor(fallback: .black, filters: [])),
        contentItem(.image(.init(
            contents: nil,
            scale: 2,
            unrotatedPixelSize: CGSize(width: 20, height: 10),
            orientation: .up,
            isTemplate: false
        ))),
        contentItem(.shape(
            Path(CGRect(x: 1, y: 2, width: 3, height: 4)),
            OpenSwiftUICore._AnyResolvedPaint(Color.Resolved.white),
            FillStyle(eoFill: true, antialiased: false)
        )),
        contentItem(.shadow(
            Path(CGRect(x: 1, y: 2, width: 3, height: 4)),
            resolvedShadow
        )),
        contentItem(.platformView(EmptyViewFactory())),
        contentItem(.platformLayer(EmptyViewFactory())),
        contentItem(.text(StyledTextContentView(text: styledText), CGSize(width: 100, height: 20))),
        contentItem(.text(StyledTextContentView(text: emptyText), .zero)),
        contentItem(.flattened(child, CGPoint(x: 3, y: 4), .init())),
        contentItem(.drawing(ORBDisplayList(), CGPoint(x: 5, y: 6), drawingOptions)),
        contentItem(.view(EmptyViewFactory())),
        contentItem(.placeholder(id: .init(decodedValue: 2))),
    ])
}

@MainActor
private func effectDisplayList() -> DisplayList {
    let group = DisplayList.InterpolatorGroup()
    let animation = Animation.default
    let path = Path(CGRect(x: 1, y: 2, width: 3, height: 4))
    let child = DisplayList(contentItem(.color(.white), seed: 2))
    let archiveIDs = DisplayList.ArchiveIDs(
        uuid: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
        stableIDs: .init()
    )
    let offsetAnimation = DisplayList.OffsetAnimation(
        from: _OffsetEffect(offset: .zero),
        to: _OffsetEffect(offset: CGSize(width: 1, height: 2)),
        animation: animation
    )

    return DisplayList([
        effectItem(.identity),
        effectItem(.geometryGroup),
        effectItem(.compositingGroup),
        effectItem(.backdropGroup(true)),
        effectItem(.archive(nil)),
        effectItem(.archive(archiveIDs)),
        effectItem(.properties(.init(rawValue: .max))),
        effectItem(.platformGroup(EmptyViewFactory())),
        effectItem(.opacity(0.5)),
        effectItem(.blendMode(.normal)),
        effectItem(.clip(path, FillStyle(), .inverse)),
        effectItem(.mask(DisplayList(), .inverse)),
        effectItem(.transform(.affine(CGAffineTransform(translationX: 1, y: 2)))),
        effectItem(.animation(offsetAnimation)),
        effectItem(.contentTransition(.init(animation: animation))),
        effectItem(.view(EmptyViewFactory())),
        effectItem(.accessibility([])),
        effectItem(.platform(.identity)),
        effectItem(.state(StrongHash())),
        effectItem(.interpolatorRoot(
            group,
            contentOrigin: CGPoint(x: 3, y: 4),
            contentOffset: CGSize(width: 5, height: 6)
        )),
        effectItem(.interpolatorLayer(group, serial: 7)),
        effectItem(.interpolatorAnimation(.init(value: StrongHash(), animation: animation))),
        displayListItem(.states([(StrongHash(), child)])),
    ])
}

@MainActor
private func filterDisplayList() -> DisplayList {
    let curve = GraphicsFilter.Curve((0, 0.25, 0.75, 1))
    let matrix = _ColorMatrix()
    // TODO: Use a real non nil shader case here after we implement ORBShader
    let shader = Shader.ResolvedShader(
        rbShader: nil,
        maxSampleOffset: CGSize(width: 1, height: 2),
        options: [.dithersColor, .colorFilter]
    )
    let filters: [GraphicsFilter] = [
        .blur(.init(radius: 1)),
        .variableBlur(.init(radius: 2)),
        .averageColor,
        .shadow(resolvedShadow),
        .projection(ProjectionTransform(CGAffineTransform(scaleX: 2, y: 3))),
        .colorMatrix(matrix, premultiplied: false),
        .colorMatrix(matrix, premultiplied: true),
        .colorMultiply(.white),
        .hueRotation(.degrees(90)),
        .saturation(0.5),
        .brightness(0.25),
        .contrast(2),
        .luminanceToAlpha,
        .colorInvert,
        .grayscale(0.75),
        .colorMonochrome(.init(color: .white, amount: 0.5, bias: 0.25)),
        .vibrantColorMatrix(matrix),
        .luminanceCurve(.init(curve: curve, amount: 0.5)),
        .colorCurves(.init(
            redCurve: curve,
            greenCurve: curve,
            blueCurve: curve,
            opacityCurve: curve
        )),
        .shader(.init(shader: shader, size: CGSize(width: 3, height: 4))),
        .alphaThreshold(.init(color: .black, amount: 0.5)),
    ]
    return DisplayList(filters.map { effectItem(.filter($0)) })
}

@MainActor
private func displayListItem(
    _ value: DisplayList.Item.Value,
    frame: CGRect = .zero,
    identity: UInt32 = 0,
    version: Int = 0
) -> DisplayList.Item {
    DisplayList.Item(
        value,
        frame: frame,
        identity: .init(decodedValue: identity),
        version: .init(decodedValue: version)
    )
}

@MainActor
private func contentItem(
    _ value: DisplayList.Content.Value,
    seed: UInt16 = 1
) -> DisplayList.Item {
    displayListItem(.content(.init(value, seed: .init(decodedValue: seed))))
}

@MainActor
private func effectItem(
    _ effect: DisplayList.Effect,
    child: DisplayList = DisplayList()
) -> DisplayList.Item {
    displayListItem(.effect(effect, child))
}

@MainActor
private func resolvedStyledText(_ string: String?) -> ResolvedStyledText {
    ResolvedStyledText(
        storage: string.map { NSAttributedString(string: $0) },
        layoutProperties: TextLayoutProperties(EnvironmentValues()),
        layoutMargins: nil,
        stylePadding: .zero,
        archiveOptions: .init(),
        isCollapsible: false,
        features: [],
        suffix: .none,
        attachments: .init(),
        styles: [],
        transitions: [],
        scaleFactorOverride: nil
    )
}

private let resolvedShadow = ResolvedShadowStyle(
    color: .black,
    radius: 2,
    offset: CGSize(width: 3, height: 4)
)

#endif
