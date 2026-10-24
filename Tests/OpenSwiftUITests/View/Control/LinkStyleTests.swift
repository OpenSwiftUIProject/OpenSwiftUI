//
//  LinkStyleTests.swift
//  OpenSwiftUITests

import Foundation
@testable import OpenSwiftUI
import OpenSwiftUITestsSupport
import Testing

@Suite(.tags(.aigc))
@MainActor
struct LinkStyleTests {
    @Test(arguments: [false, true])
    func usesPlatformDefaultStyleForAutomaticStyle(explicitAutomatic: Bool) throws {
        var inputs = _GraphInputs.invalid
        if explicitAutomatic {
            inputs[ButtonStyleInput.self] = .init(base: DefaultButtonStyle.self)
        }
        #if os(macOS)
        #expect(try selectedStyle(in: inputs) == LinkButtonStyle.self)
        #else
        #expect(try selectedStyle(in: inputs) == DefaultButtonStyle.self)
        #endif
    }

    @Test(arguments: ExplicitStyle.allCases)
    func preservesExplicitStyle(_ style: ExplicitStyle) throws {
        var inputs = _GraphInputs.invalid
        inputs[ButtonStyleInput.self] = .init(base: style.type)
        #expect(try selectedStyle(in: inputs) == style.type)
    }

    private func selectedStyle(in inputs: _GraphInputs) throws -> any PrimitiveButtonStyle.Type {
        let link = Link(destination: URL(string: "https://example.com")!) { EmptyView() }
        let modifier = Mirror(reflecting: link.body).descendant("modifier")
        #if os(macOS)
        let selection = try #require(modifier as? any LinkStyleSelection)
        return selection.selectedStyle(in: inputs)
        #else
        #expect(modifier == nil)
        return inputs[ButtonStyleInput.self].base
        #endif
    }

    enum ExplicitStyle: CaseIterable, Sendable {
        case plain, bordered, borderless, customPrimitive, custom
        #if os(macOS)
        case link
        #endif

        var type: any PrimitiveButtonStyle.Type {
            switch self {
            case .plain: PlainButtonStyle.self
            case .bordered: BorderedButtonStyle.self
            case .borderless: BorderlessButtonStyle.self
            case .customPrimitive: CustomPrimitiveStyle.self
            case .custom: WrappedButtonStyle<CustomStyle>.self
            #if os(macOS)
            case .link: LinkButtonStyle.self
            #endif
            }
        }
    }

    private struct CustomPrimitiveStyle: PrimitiveButtonStyle {
        func makeBody(configuration: Configuration) -> some View {
            configuration.label
        }
    }

    private struct CustomStyle: ButtonStyle {
        func makeBody(configuration: Configuration) -> some View {
            configuration.label
        }
    }
}

private protocol LinkStyleSelection {
    func selectedStyle(in inputs: _GraphInputs) -> any PrimitiveButtonStyle.Type
}

#if os(macOS)
extension StaticIf: LinkStyleSelection where
    TrueBody == PrimitiveButtonStyleContainerModifier<LinkButtonStyle>,
    FalseBody == EmptyModifier
{
    fileprivate func selectedStyle(in inputs: _GraphInputs) -> any PrimitiveButtonStyle.Type {
        Predicate.evaluate(inputs: inputs)
            ? type(of: trueBody.style)
            : inputs[ButtonStyleInput.self].base
    }
}
#endif
