//
//  ImageContentTransitionTests.swift
//  OpenSwiftUICoreTests

#if canImport(Darwin) && OPENSWIFTUI_LINK_COREUI && OPENSWIFTUI_RENDERBOX

import CoreUI
import ObjectiveC
import OpenAttributeGraphShims
import OpenRenderBoxShims
@_spi(Private) @testable import OpenSwiftUICore
import OpenSwiftUITestsSupport
import Testing

@MainActor
@Suite(.tags(.aigc))
struct ImageContentTransitionTests {
    enum PreviousGlyph: CaseIterable {
        case absent
        case compatible
        case incompatible
    }

    @Test(.disabled(if: attributeGraphVendor == .oag), arguments: PreviousGlyph.allCases)
    func replacementRequiresAnIncompatiblePreviousGlyph(previous: PreviousGlyph) {
        let graph = Graph()
        let subgraph = Subgraph(graph: graph)
        defer { subgraph.invalidate() }
        subgraph.apply {
            let source = Attribute(value: Transaction(animation: .linear))
            var environment = EnvironmentValues()
            environment.contentTransition = .init(storage: .symbolReplace(.init()))
            var context = ImageResolutionContext(environment: environment, transaction: .init(source))
            let animator = RecordingAnimator()
            if previous != .absent {
                animator.glyph = TestGlyph.make(interpolates: previous == .compatible)
            }
            context.symbolAnimator = animator
            #expect(!context.willUpdateVectorGlyph(to: TestGlyph.make(), variableValue: 0))
            #expect(animator.animations.count == 1)
            guard let animation = animator.animations.first else { return }
            #expect(animation.kind == (previous == .incompatible ? .replace : .interpolate))
            #expect(animation.options[ORBSymbolAnimation.OptionKey.timing.rawValue] is ORBAnimation)
            if previous != .incompatible {
                #expect(animation.options[ORBSymbolAnimation.OptionKey.interpolateOptions.rawValue] as? Bool == true)
            }
        }
    }

    @Test(.disabled(if: attributeGraphVendor == .oag), arguments: [
        ContentTransition.default, .interpolate, .identity, .opacity,
        .init(method: .none, effects: []),
    ])
    func interpolationOptionsUseTheResolvedTransition(transition: ContentTransition) {
        let graph = Graph()
        let subgraph = Subgraph(graph: graph)
        defer { subgraph.invalidate() }
        subgraph.apply {
            let source = Attribute(value: Transaction(animation: .linear))
            var environment = EnvironmentValues()
            environment.contentTransition = transition
            var context = ImageResolutionContext(environment: environment, transaction: .init(source))
            let animator = RecordingAnimator()
            context.symbolAnimator = animator
            #expect(!context.willUpdateVectorGlyph(to: TestGlyph.make(), variableValue: 0))
            #expect(animator.animations.count == 1)
            guard let animation = animator.animations.first else { return }
            #expect(animation.kind == .interpolate)
            let resolved = transition.isNamed(.default)
                ? (isLinkedOnOrAfter(.v4) ? ContentTransition.interpolate : .identity)
                : transition
            #expect((animation.options[ORBSymbolAnimation.OptionKey.interpolateOptions.rawValue] as? Bool) == (resolved == .interpolate ? nil : true))
        }
    }

    @Test(.disabled(if: attributeGraphVendor == .oag), arguments: [false, true])
    func explicitAnimationDoesNotRequireTransactionAnimation(explicitAnimation: Bool) {
        let graph = Graph()
        let subgraph = Subgraph(graph: graph)
        defer { subgraph.invalidate() }
        subgraph.apply {
            let source = Attribute(value: Transaction())
            var environment = EnvironmentValues()
            environment.contentTransitionState = .init(
                transition: .opacity, animation: explicitAnimation ? .linear : nil
            )
            var context = ImageResolutionContext(environment: environment, transaction: .init(source))
            let animator = RecordingAnimator()
            context.symbolAnimator = animator
            #expect(!context.willUpdateVectorGlyph(to: TestGlyph.make(), variableValue: 0))
            #expect(animator.animations.count == (explicitAnimation ? 1 : 0))
        }
    }
}

private enum TestGlyph {
    // A static subclass requires _OBJC_METACLASS_$_CUINamedVectorGlyph,
    // which CoreUI does not export. Create the
    // subclass at runtime to avoid this link dependency.
    static func make(interpolates: Bool = false) -> CUINamedVectorGlyph {
        let type = interpolates ? compatibleClass : incompatibleClass
        return type.init()
    }

    private static let compatibleClass = makeClass(interpolates: true)
    private static let incompatibleClass = makeClass(interpolates: false)

    private static func makeClass(interpolates: Bool) -> CUINamedVectorGlyph.Type {
        let name = "OpenSwiftUIImageContentTransition\(interpolates ? "Compatible" : "Incompatible")Glyph"
        let selector = #selector(CUINamedVectorGlyph.canBeInterpolated(with:))
        guard let type = objc_allocateClassPair(CUINamedVectorGlyph.self, name, 0),
              let method = class_getInstanceMethod(CUINamedVectorGlyph.self, selector) else {
            preconditionFailure("Could not create the glyph test class.")
        }
        let implementation: @convention(block) (CUINamedVectorGlyph, CUINamedVectorGlyph) -> Bool = { _, _ in
            interpolates
        }
        let added = class_addMethod(type, selector, imp_implementationWithBlock(implementation), method_getTypeEncoding(method))
        precondition(added, "Could not override glyph interpolation.")
        objc_registerClassPair(type)
        return type as! CUINamedVectorGlyph.Type
    }
}

private final class RecordingAnimator: ORBSymbolAnimator {
    struct Animation {
        var kind: ORBSymbolAnimation
        var options: [String: Any]
    }

    var animations: [Animation] = []
    private var storedGlyph: CUINamedVectorGlyph?

    override var glyph: CUINamedVectorGlyph? {
        get { storedGlyph }
        set { storedGlyph = newValue }
    }

    override func addAnimation(_ animation: ORBSymbolAnimation, options: Any?) -> UInt32 {
        animations.append(.init(kind: animation, options: options as? [String: Any] ?? [:]))
        return 0
    }
}

#endif
