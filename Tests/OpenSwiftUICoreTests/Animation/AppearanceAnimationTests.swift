//
//  AppearanceAnimationTests.swift
//  OpenSwiftUICoreTests

import Foundation
@_spi(Private) @testable import OpenSwiftUICore
import Testing

@MainActor
@Suite(.tags(.aigc))
struct AppearanceAnimationTests {
    @Test
    func modifierEvaluatesBothEndpointsOnce() throws {
        var phases: [Bool] = []
        let result = EmptyView().appearanceAnimation { content, active in
            phases.append(active)
            return content.modifier(_OpacityEffect(opacity: active ? 0.75 : 0.25))
        }
        let view = try #require(result as? AppearanceAnimationView<EmptyView, ModifiedContent<EmptyView, _OpacityEffect>>)
        #expect(phases == [false, true])
        #expect(view.from.modifier.opacity == 0.25)
        #expect(view.to.modifier.opacity == 0.75)
        #expect(view.animation == .default)
        #expect(view.strategy == .withAnimation)
    }

    @Test(arguments: [
        ("opacity", "220d0a050d0000000012001a023a00"),
        ("offset", "0a140a00120c0a0a0d00002041150000a0411a023a00"),
        ("scale", "12140a00120c0a0a0d0000004015000000401a023a00"),
        ("rotation", "1a110a00120909182d4454fb21f93f1a023a00"),
    ])
    func archivedAnimationPreservesEndpoints(kind: String, expected: String) throws {
        let animation: (any DisplayList.AnyEffectAnimation)?
        switch kind {
        case "opacity":
            animation = extract(_OpacityEffect(opacity: 0), _OpacityEffect(opacity: 1))
        case "offset":
            animation = extract(_OffsetEffect(offset: .zero), _OffsetEffect(offset: CGSize(width: 10, height: 20)))
        case "scale":
            animation = extract(
                _ScaleEffect(scale: CGSize(width: 1, height: 1), anchor: .center),
                _ScaleEffect(scale: CGSize(width: 2, height: 2), anchor: .center)
            )
        default:
            animation = extract(_RotationEffect(angle: .zero, anchor: .center), _RotationEffect(angle: .degrees(90), anchor: .center))
        }
        let effect = try #require(animation)
        let data = try ProtobufEncoder.encoding(CodableEffectAnimation(base: effect))
        #expect(data.map { String(format: "%02x", $0) }.joined() == expected)
    }

    @Test
    func archivedBodyKeepsOriginalContent() throws {
        let view = AppearanceAnimationView(
            content: Marker(value: 10),
            from: Marker(value: 20).modifier(_OpacityEffect(opacity: -0.5)),
            to: Marker(value: 30).modifier(_OpacityEffect(opacity: 1.5)),
            animation: .linear(duration: 2),
            strategy: .animationValue
        )
        typealias Effect = AppearanceAnimationView<Marker, ModifiedContent<Marker, _OpacityEffect>>.AnimationEffect
        let archived = try #require(view.archivedBody as? ModifiedContent<Marker, Effect>)
        #expect(archived.content.value == 10)
        guard case let .animation(effect) = archived.modifier.effectValue(size: .zero) else {
            Issue.record("Expected an archived animation effect")
            return
        }
        let opacity = try #require(effect as? DisplayList.OpacityAnimation)
        #expect(opacity.from.opacity == -0.5)
        #expect(opacity.to.opacity == 1.5)
        #expect(opacity.animation == .linear(duration: 2))
    }

    @Test
    func unsupportedCompositionUsesIdentity() throws {
        let content = EmptyView()
        let endpoint = content.modifier(_OpacityEffect(opacity: 0.5)).modifier(_OpacityEffect(opacity: 0.5))
        let view = AppearanceAnimationView(content: content, from: endpoint, to: endpoint, animation: .default, strategy: .withAnimation)
        #expect(view.displayListAnimation == nil)
        typealias Effect = AppearanceAnimationView<EmptyView, ModifiedContent<ModifiedContent<EmptyView, _OpacityEffect>, _OpacityEffect>>.AnimationEffect
        let archived = try #require(view.archivedBody as? ModifiedContent<EmptyView, Effect>)
        guard case .identity = archived.modifier.effectValue(size: CGSize(width: 20, height: 30)) else {
            Issue.record("Unsupported endpoint composition must leave the content unchanged")
            return
        }
    }

    private func extract<Effect>(_ from: Effect, _ to: Effect) -> (any DisplayList.AnyEffectAnimation)? where Effect: ViewModifier {
        let content = EmptyView()
        return AppearanceAnimationView(
            content: content,
            from: content.modifier(from),
            to: content.modifier(to),
            animation: Animation(DefaultAnimation()),
            strategy: .withAnimation
        ).displayListAnimation
    }

    private struct Marker: View {
        var value: Int
        var body: some View { EmptyView() }
    }
}
