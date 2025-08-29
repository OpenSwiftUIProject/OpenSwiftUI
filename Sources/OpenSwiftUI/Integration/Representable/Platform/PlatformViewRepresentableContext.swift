//
//  PlatformViewRepresentableContext.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete

import OpenAttributeGraphShims

// MARK: - RepresentableContextValues

struct RepresentableContextValues {
    static var current: RepresentableContextValues?

    var preferenceBridge: PreferenceBridge?

    var transaction: Transaction

    var environmentStorage: EnvironmentStorage

    enum EnvironmentStorage {
        case eager(EnvironmentValues)
        case lazy(Attribute<EnvironmentValues>, AnyRuleContext)
    }

    func asCurrent<V>(do action: () -> V) -> V {
        let old = Self.current
        Self.current = self
        defer { Self.current = old }
        return action()
    }
}

// MARK: - PlatformViewRepresentableContext

struct PlatformViewRepresentableContext<Content: PlatformViewRepresentable> {
    var values: RepresentableContextValues
    let coordinator: Content.Coordinator

    init(
        coordinator: Content.Coordinator,
        preferenceBridge: PreferenceBridge?,
        transaction: Transaction,
        environmentStorage: RepresentableContextValues.EnvironmentStorage
    ) {
        self.values = .init(
            preferenceBridge: preferenceBridge,
            transaction: transaction,
            environmentStorage: environmentStorage
        )
        self.coordinator = coordinator
    }

    @inlinable
    var environment: EnvironmentValues {
        switch values.environmentStorage {
        case let .eager(environmentValues):
            environmentValues
        case let .lazy(attribute, anyRuleContext):
            Update.ensure { anyRuleContext[attribute] }
        }
    }
}
