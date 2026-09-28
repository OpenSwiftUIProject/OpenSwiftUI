//
//  AccessibilityLabelStorage.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete

// MARK: - AccessibilityLabelStorage

package struct AccessibilityLabelStorage: Equatable {
    package enum Placement: Equatable {
        case prefix
        case suffix
        case assign
        case optional
    }

    package var texts: [Text]

    package var placement: Placement

    package init(texts: [Text], placement: Placement = .assign) {
        self.texts = texts
        self.placement = placement
    }

    @discardableResult
    package mutating func removing(_ text: Text) -> Bool {
        guard let index = texts.firstIndex(of: text) else {
            return false
        }
        texts.remove(at: index)
        return true
    }
}

// MARK: - AccessibilityLabelStorage + AccessibilityCombinable

extension AccessibilityLabelStorage: AccessibilityCombinable {
    package mutating func merge(with child: AccessibilityLabelStorage) -> Bool {
        switch (placement, child.placement) {
        case (.optional, .prefix), (.optional, .suffix), (.optional, .assign):
            self = child
            return true
        case (_, .optional), (.assign, .assign):
            return false
        case (_, .prefix), (.suffix, _):
            texts.insert(contentsOf: child.texts, at: 0)
            return true
        case (_, .suffix), (.prefix, _):
            texts.append(contentsOf: child.texts)
            return true
        }
    }
}
