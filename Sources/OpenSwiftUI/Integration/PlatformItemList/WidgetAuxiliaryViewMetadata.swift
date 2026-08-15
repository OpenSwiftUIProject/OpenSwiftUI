//
//  WidgetAuxiliaryViewMetadata.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: WIP
//  ID: 5D203C4BCF4ED90873E64430FDF30283 (SwiftUI)

import Foundation
import OpenAttributeGraphShims
@_spi(ForOpenSwiftUIOnly)
@_spi(Private)
import OpenSwiftUICore

// MARK: - WidgetAuxiliaryViewMetadata

struct WidgetAuxiliaryViewMetadata {
    var item: PlatformItemList.Item?
    var progress: Progress?
    var url: URL?
    var accessibility: Accessibility?

    init(
        item: PlatformItemList.Item?,
        url: URL?,
        accessibility: Accessibility?,
        child: WidgetAuxiliaryViewMetadata?
    ) {
        self.item = item ?? child?.item
        self.progress = child?.progress
        self.url = url ?? child?.url
        self.accessibility = accessibility ?? child?.accessibility
    }

    init(progress: Progress?) {
        item = nil
        self.progress = progress
        url = nil
        accessibility = nil
    }

    static func tint(from environment: EnvironmentValues) -> ResolvedGradient? {
        // TODO: ResolvedGradient
        nil
    }

    static func reduce(
        _ lhs: WidgetAuxiliaryViewMetadata?,
        _ rhs: WidgetAuxiliaryViewMetadata?
    ) -> WidgetAuxiliaryViewMetadata? {
        guard var result = lhs else {
            return rhs
        }
        guard let rhs else {
            return result
        }
        result.item = rhs.item ?? result.item
        result.progress = rhs.progress ?? result.progress
        result.url = rhs.url ?? result.url
        result.accessibility = rhs.accessibility ?? result.accessibility
        return result
    }

    struct Progress {
        enum Kind {
            case absolute(Double?, Bool)
            case date(ClosedRange<Date>, Bool)

            @inline(__always)
            init(_ value: ProgressViewValue) {
                switch value {
                case let .absolute(fractionCompleted, alwaysIndeterminate):
                    self = .absolute(fractionCompleted, alwaysIndeterminate)
                case let .dateRelative(interval, countdown):
                    self = .date(interval, countdown)
                }
            }
        }

        var kind: Kind
        private var _labelBox: MutableBox<WidgetAuxiliaryViewMetadata?>
        private var _currentValueLabelBox: MutableBox<WidgetAuxiliaryViewMetadata?>
        private var _tint: ResolvedGradient?

        var label: WidgetAuxiliaryViewMetadata? {
            get { _labelBox.wrappedValue }
            set { _labelBox.wrappedValue = newValue }
        }

        var currentValueLabel: WidgetAuxiliaryViewMetadata? {
            get { _currentValueLabelBox.wrappedValue }
            set { _currentValueLabelBox.wrappedValue = newValue }
        }

        init(
            kind: Kind,
            label: WidgetAuxiliaryViewMetadata?,
            currentValueLabel: WidgetAuxiliaryViewMetadata?,
            tint: ResolvedGradient?
        ) {
            self.kind = kind
            _labelBox = MutableBox(label)
            _currentValueLabelBox = MutableBox(currentValueLabel)
            _tint = tint
        }
    }

    struct Accessibility {
        var label: String?
        var value: String?
        var identifier: String?
        var hint: String?
    }

    struct Key: HostPreferenceKey {
        static var defaultValue: WidgetAuxiliaryViewMetadata?

        static func reduce(
            value: inout WidgetAuxiliaryViewMetadata?,
            nextValue: () -> WidgetAuxiliaryViewMetadata?
        ) {
            value = WidgetAuxiliaryViewMetadata.reduce(value, nextValue())
        }
    }
}

extension PreferencesInputs {
    @inline(__always)
    func containsWidgetAuxiliaryViewMetadata() -> Bool {
        contains(WidgetAuxiliaryViewMetadata.Key.self)
    }
}

// MARK: - Widget auxiliary text and image metadata

struct WidgetAuxiliaryTextImagePreference {
    var list: PlatformItemList?
}

struct LazyWidgetAuxiliaryMetadataTextImage<Content>: StatefulRule where Content: View {
    let subgraph: Subgraph
    @Attribute var content: Content
    let inputs: _ViewInputs
    @OptionalAttribute var textImagePref: WidgetAuxiliaryTextImagePreference??

    init(content: Attribute<Content>, inputs: _ViewInputs) {
        subgraph = Subgraph.current!
        _content = content
        self.inputs = inputs
        _textImagePref = OptionalAttribute()
    }

    typealias Value = WidgetAuxiliaryTextImagePreference?

    static var initialValue: WidgetAuxiliaryTextImagePreference?? { nil }

    mutating func updateValue() {
        if $textImagePref == nil {
            $textImagePref = subgraph.apply {
                makeTextImage()
            }
        }
        value = textImagePref ?? nil
    }

    private func makeTextImage() -> Attribute<WidgetAuxiliaryTextImagePreference?> {
        var inputs = inputs
        inputs.addPlatformItemListKey(
            flags: WidgetMetadataPlatformItemListFlags.self,
            editOperation: .replace
        )
        inputs.hasWidgetMetadata = true
        let outputs = Content.makeDebuggableView(
            view: _GraphValue($content),
            inputs: inputs
        )
        return Attribute(
            WidgetAuxiliaryMetadataTextImageWriter(
                list: WeakAttribute(outputs.preferences.platformItemList)
            )
        )
    }
}

private struct WidgetAuxiliaryMetadataTextImageWriter: Rule, AsyncAttribute {
    @WeakAttribute var list: PlatformItemList?

    var value: WidgetAuxiliaryTextImagePreference? {
        list.map { WidgetAuxiliaryTextImagePreference(list: $0) }
    }
}
