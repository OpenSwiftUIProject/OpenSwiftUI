//
//  EnvironmentalView.swift
//  OpenSwiftUICore
//
//  Audited for iOS 18.0
//  Status: Complete

import OpenAttributeGraphShims

// MARK: - EnvironmentalView

@MainActor
@preconcurrency
package protocol EnvironmentalView: PrimitiveView, UnaryView {
    associatedtype EnvironmentBody: View
    func body(environment: EnvironmentValues) -> EnvironmentBody
}

extension EnvironmentalView {
    nonisolated public static func _makeView(view: _GraphValue<Self>, inputs: _ViewInputs) -> _ViewOutputs {
        let child = EnvironmentalViewChild(view: view.value, env: inputs.environment)
        return EnvironmentBody.makeDebuggableView(view: _GraphValue(child), inputs: inputs)
    }
}

// MARK: - EnvironmentalViewChild

struct EnvironmentalViewChild<V>: StatefulRule, AsyncAttribute, CustomStringConvertible where V: EnvironmentalView {
    @Attribute var view: V
    @Attribute var env: EnvironmentValues
    let tracker: PropertyList.Tracker
    
    init(view: Attribute<V>, env: Attribute<EnvironmentValues>) {
        _view = view
        _env = env
        tracker = .init()
    }
    
    typealias Value = V.EnvironmentBody
    
    func updateValue() {
        let (view, viewChanged) = $view.changedValue()
        let (env, envChanged) = $env.changedValue()
        
        let shouldReset: Bool
        if viewChanged {
            shouldReset = true
        } else if envChanged, tracker.hasDifferentUsedValues(env.plist) {
            shouldReset = true
        } else {
            shouldReset = !hasValue
        }
        guard shouldReset else { return }
        tracker.reset()
        tracker.initializeValues(from: env.plist)
        value = traceBody(V.self) {
            view.body(environment: env)
        }
    }
    
    var description: String {
        "EnvironmentReading: \(V.self)"
    }
}

// MARK: - EnvironmentReader

@MainActor
@preconcurrency
package struct EnvironmentReader<Content>: EnvironmentalView where Content: View {
    let content: (EnvironmentValues) -> Content
    
    package init(@ViewBuilder _ content: @escaping (EnvironmentValues) -> Content) {
        self.content = content
    }
    
    package func body(environment: EnvironmentValues) -> Content {
        content(environment)
    }
    
    nonisolated package static func _makeViewList(view: _GraphValue<Self>, inputs: _ViewListInputs) -> _ViewListOutputs {
        guard Semantics.EnvironmentReaderViewIsMulti.isEnabled else {
            return _ViewListOutputs.unaryViewList(view: view, inputs: inputs)
        }
        let child = EnvironmentalViewChild(view: view.value, env: inputs.base.environment)
        return EnvironmentBody.makeDebuggableViewList(view: _GraphValue(child), inputs: inputs)
    }
    
    nonisolated package static func _viewListCount(inputs: _ViewListCountInputs) -> Int? {
        guard Semantics.EnvironmentReaderViewIsMulti.isEnabled else {
            return 1
        }
        return Content._viewListCount(inputs: inputs)
    }
    
    package typealias Body = Never
    package typealias EnvironmentBody = Content
}
