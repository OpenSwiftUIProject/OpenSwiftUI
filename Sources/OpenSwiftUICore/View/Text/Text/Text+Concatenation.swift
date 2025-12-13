//
//  Text+Concatenation.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: 3AC20F2C4A28F04412970732648A1058 (SwiftUICore)

// MARK: - Text + Text

@available(OpenSwiftUI_v1_0, *)
extension Text {
    package init(_ lhs: Text, _ rhs: Text) {
        self.init(anyTextStorage: ConcatenatedTextStorage(first: lhs, second: rhs))
    }

    public static func + (lhs: Text, rhs: Text) -> Text {
        Text(lhs, rhs)
    }
}

// MARK: - ConcatenatedTextStorage

private class ConcatenatedTextStorage: AnyTextStorage, @unchecked Sendable {
    let first: Text
    let second: Text

    init(first: Text, second: Text) {
        self.first = first
        self.second = second
    }

    override func resolve<T>(
        into result: inout T,
        in environment: EnvironmentValues,
        with options: Text.ResolveOptions
    ) where T : ResolvedTextContainer {
        first.resolve(into: &result, in: environment, with: options)
        second.resolve(into: &result, in: environment, with: options)
    }

    override func resolvesToEmpty(
        in environment: EnvironmentValues,
        with options: Text.ResolveOptions
    ) -> Bool {
        first.resolvesToEmpty(in: environment, with: options) &&
        second.resolvesToEmpty(in: environment, with: options)
    }

    override func isEqual(to other: AnyTextStorage) -> Bool {
        guard let other = other as? ConcatenatedTextStorage else {
            return false
        }
        return first == other.first &&
        second == other.second
    }

    override func isStyled(options: Text.ResolveOptions) -> Bool {
        first.isStyled(options: options) ||
        second.isStyled(options: options)
    }

    override func allowsTypesettingLanguage() -> Bool {
        first.allowsTypesettingLanguage() &&
        second.allowsTypesettingLanguage()
    }
}
