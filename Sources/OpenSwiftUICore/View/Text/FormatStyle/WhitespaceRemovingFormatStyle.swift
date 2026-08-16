//
//  WhitespaceRemovingFormatStyle.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: 3B28458A04B29D198EA185C6BA75366B (SwiftUICore)

package import Foundation

package struct WhitespaceRemovingFormatStyle<Format, Key>: FormatStyle
    where Format: FormatStyle,
    Key: DecodableAttributedStringKey,
    Key: EncodableAttributedStringKey,
    Format.FormatOutput == AttributedString,
    Key.Value: Decodable,
    Key.Value: Encodable
{
    var base: Format
    var prefixValue: Key.Value?
    var suffixValue: Key.Value?

    package func format(_ input: Format.FormatInput) -> AttributedString {
        base.format(input)
    }

    package func locale(_ locale: Locale) -> WhitespaceRemovingFormatStyle<Format, Key> {
        var style = self
        style.base = base.locale(locale)
        return style
    }

    private enum CodingKeys: String, CodingKey {
        case base
        case prefixValue
        case suffixValue
    }

    package func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(base, forKey: .base)
        try container.encodeIfPresent(prefixValue, forKey: .prefixValue)
        try container.encodeIfPresent(suffixValue, forKey: .suffixValue)
    }

    package init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        base = try container.decode(Format.self, forKey: .base)
        prefixValue = try container.decodeIfPresent(Key.Value.self, forKey: .prefixValue)
        suffixValue = try container.decodeIfPresent(Key.Value.self, forKey: .suffixValue)
    }
}

// MARK: - DiscreteFormatStyle

extension WhitespaceRemovingFormatStyle: DiscreteFormatStyle where Format: DiscreteFormatStyle {
    package func discreteInput(after input: Format.FormatInput) -> Format.FormatInput? {
        base.discreteInput(after: input)
    }

    package func discreteInput(before input: Format.FormatInput) -> Format.FormatInput? {
        base.discreteInput(before: input)
    }

    package func input(after input: Format.FormatInput) -> Format.FormatInput? {
        base.input(after: input)
    }

    package func input(before input: Format.FormatInput) -> Format.FormatInput? {
        base.input(before: input)
    }
}

// MARK: - SafelySerializableDiscreteFormatStyle

extension WhitespaceRemovingFormatStyle: SafelySerializableDiscreteFormatStyle
    where Format: SafelySerializableDiscreteFormatStyle
{
    package static func representation<S>(
        of resolvable: TimeDataFormatting.Resolvable<S, WhitespaceRemovingFormatStyle<Format, Key>>,
        for version: ArchivedViewInput.DeploymentVersion
    ) -> any ResolvableStringAttributeRepresentation
        where S: TimeDataSourceStorage, Format.FormatInput == S.Value
    {
        guard version <= .v5 else {
            return resolvable
        }
        return Format.representation(
            of: resolvable.replacingFormat(with: resolvable.format.base),
            for: version
        )
    }
}
