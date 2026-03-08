//
//  Text+Sizing.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: 22747AAF70EE5063D02F299CE90A18BE (SwiftUICore)

// MARK: TextSizingModifier

protocol TextSizingModifier: Equatable {
    func updateLayoutMargins(_ margins: inout EdgeInsets)
}

class AnyTextSizingModifier: Equatable, TextSizingModifier, @unchecked Sendable {
    static func == (lhs: AnyTextSizingModifier, rhs: AnyTextSizingModifier) -> Bool {
        lhs.isEqual(to: rhs)
    }

    func updateLayoutMargins(_ margins: inout EdgeInsets) {
        _openSwiftUIBaseClassAbstractMethod()
    }

    func isEqual(to other: AnyTextSizingModifier) -> Bool {
        _openSwiftUIBaseClassAbstractMethod()
    }
}

private class ConcreteTextSizingModifier<M>: AnyTextSizingModifier, @unchecked Sendable where M: TextSizingModifier {
    let modifier: M

    init(modifier: M) {
        self.modifier = modifier
    }

    override func updateLayoutMargins(_ margins: inout EdgeInsets) {
        modifier.updateLayoutMargins(&margins)
    }

    override func isEqual(to other: AnyTextSizingModifier) -> Bool {
        guard let other = other as? ConcreteTextSizingModifier else {
            return false
        }
        return modifier == other.modifier
    }
}


// MARK: - Text + Sizing

@_spi(Private)
@available(OpenSwiftUI_v5_0, *)
extension Text {
    public struct Sizing: Sendable, Equatable {
        package enum Storage: UInt8, Equatable {
            case standard

            case uniformLineHeight

            case adjustsForOversizedCharacters
        }

        package var storage: Text.Sizing.Storage

        private var modifiers: [AnyTextSizingModifier] = []

        package init(_ storage: Text.Sizing.Storage) {
            self.storage = storage
        }

        public static let standard: Text.Sizing = .init(.standard)

        public static let uniformLineHeight: Text.Sizing = .init(.uniformLineHeight)

        public static let adjustsForOversizedCharacters: Text.Sizing = .init(.adjustsForOversizedCharacters)
    }
}

//extension Text.Sizing {
//    func layoutMargins(
//        for: NSAttributedString,
//        metrics: inout NSAttributedString.EncodedFontMetrics?
//        layoutProperties: LayoutProperties
//    ) {
//        _openSwiftUIUnimplementedFailure()
//    }
//}

private struct TextSizingKey: EnvironmentKey {
    static let defaultValue: Text.Sizing = .standard
}

extension EnvironmentValues {
    package var textSizing: Text.Sizing {
        get { self[TextSizingKey.self] }
        set { self[TextSizingKey.self] = newValue }
    }
}

// MARK: - PreferTextLayoutManagerInput

private struct PreferTextLayoutManagerInputModifier: ViewInputsModifier {
    static func _makeViewInputs(
        modifier: _GraphValue<Self>,
        inputs: inout _ViewInputs
    ) {
        inputs.prefersTextLayoutManager = true
    }
}

package struct PreferTextLayoutManagerInput: ViewInput {
    package static var defaultValue: Bool { false }
}

extension _ViewInputs {
    @inline(__always)
    var prefersTextLayoutManager: Bool {
        get { self[PreferTextLayoutManagerInput.self] }
        set { self[PreferTextLayoutManagerInput.self] = newValue }
    }
}
