//
//  ViewInputPredicate.swift
//  OpenSwiftUICore
//
//  Audited for iOS 18.0
//  Status: Complete

// MARK: - ViewInputPredicate

package protocol ViewInputPredicate {
    static func evaluate(inputs: _GraphInputs) -> Bool
}

// MARK: - ViewInputFlag

package protocol ViewInputFlag: ViewInputPredicate, _GraphInputsModifier {
    associatedtype Input: ViewInput where Input.Value: Equatable
    static var value: Input.Value { get }
    init()
}

extension ViewInputFlag {
    package static func evaluate(inputs: _GraphInputs) -> Bool {
        inputs[Input.self] == value
    }
    
    package static func _makeInputs(modifier _: _GraphValue<Self>, inputs: inout _GraphInputs) {
        inputs[Input.self] = value
    }
}

extension ViewInput where Self: ViewInputFlag {
    package typealias Input = Self
}

// MARK: - ViewInputBoolFlag

package protocol ViewInputBoolFlag: ViewInput, ViewInputFlag where Value == Bool {}


extension ViewInputBoolFlag {
    @inlinable
    package static var defaultValue: Bool { false }
    
    @inlinable
    package static var value: Bool { true }
}

// MARK: - ViewInputPredicate + Extension

extension ViewInputPredicate {
    package static prefix func ! (predicate: Self) -> some ViewInputPredicate {
        InvertedViewInputPredicate<Self>()
    }

    package static func || <Other>(lhs: Self, rhs: Other) -> some ViewInputPredicate where Other: ViewInputPredicate {
        OrOperationViewInputPredicate<Self, Other>()
    }
  
    package typealias Inverted = InvertedViewInputPredicate<Self>
}

// MARK: - InvertedViewInputPredicate

package struct InvertedViewInputPredicate<Base>: ViewInputPredicate where Base: ViewInputPredicate {
    package static func evaluate(inputs: _GraphInputs) -> Bool {
        !Base.evaluate(inputs: inputs)
    }
}

extension InvertedViewInputPredicate where Base: Feature {
    package static var isEnabled: Bool {
        !Base.isEnabled
    }
}
extension InvertedViewInputPredicate: ViewInputBoolFlag, ViewInputFlag, _GraphInputsModifier, ViewInput, GraphInput, PropertyKey where Base: ViewInputBoolFlag {
    @inlinable
    package static var value: Bool { false }
    
    @inlinable
    package init() {}
    
    package typealias Value = Bool
}

// MARK: - OrOperationViewInputPredicate

package struct OrOperationViewInputPredicate<Left, Right>: ViewInputPredicate where Left: ViewInputPredicate, Right: ViewInputPredicate {
    package static func evaluate(inputs: _GraphInputs) -> Bool {
        Left.evaluate(inputs: inputs) || Right.evaluate(inputs: inputs)
    }
    
    @inlinable
    package init() {}
}

// MARK: - AndOperationViewInputPredicate

package struct AndOperationViewInputPredicate<Left, Right>: ViewInputPredicate where Left: ViewInputPredicate, Right: ViewInputPredicate {
    package static func evaluate(inputs: _GraphInputs) -> Bool {
        Left.evaluate(inputs: inputs) && Right.evaluate(inputs: inputs)
    }
    
    @inlinable
    package init() {}
}

package struct TypesMatch<Left, Right>: ViewInputPredicate {
    package static func evaluate(inputs: _GraphInputs) -> Bool {
        Left.self == Right.self
    }
    
    @inlinable
    package init() {}
}

package struct IsVisionEnabledPredicate: ViewInputPredicate {
    package static func evaluate(inputs: _GraphInputs) -> Bool {
        #if os(macOS)
        false
        #else
        inputs.interfaceIdiom.accepts(.vision)
        #endif
    }
    
    package init() {}
}

extension _ViewInputs {
    package var isVisionEnabled: Bool {
        IsVisionEnabledPredicate.evaluate(inputs: base)
    }
}
extension _ViewListInputs {
    package var isVisionEnabled: Bool {
        IsVisionEnabledPredicate.evaluate(inputs: base)
    }
}
