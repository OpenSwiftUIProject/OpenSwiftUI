//
//  StaticIf.swift
//  OpenSwiftUI
//
//  Audited for iOS 18.0
//  Status: Complete

import OpenSwiftUICore

/// A container view that conditionally renders one of two views based on a `ViewInputPredicate`.
///
/// `StaticIf` makes view selection decisions based on the evaluation of a `ViewInputPredicate`
/// against view inputs. Unlike regular conditional logic, the `ViewInputPredicate` is
/// specifically designed to only depend on view input parameters rather than arbitrary
/// runtime state.
///
/// This view facilitates optimizations in the view hierarchy by allowing the framework
/// to make view structure decisions based on stable view properties rather than
/// arbitrary runtime values.
///
/// Use this when you need conditional views based on input parameters like
/// environment values, interface idioms, or view context properties.
package struct StaticIf<Predicate, TrueBody, FalseBody> where Predicate: ViewInputPredicate {
    package var trueBody: TrueBody
    package var falseBody: FalseBody
}

extension StaticIf: PrimitiveView, View where TrueBody: View, FalseBody: View {
    /// Creates a new instance that statically selects between two views based on a predicate type.
    ///
    /// - Parameters:
    ///   - predicate: The predicate type used to evaluate against view inputs.
    ///   - then: A closure that returns the view to display when the predicate evaluates to `true`.
    ///   - else: A closure that returns the view to display when the predicate evaluates to `false`.
    package init(_ predicate: Predicate.Type, then: () -> TrueBody, else: () -> FalseBody) {
        trueBody = then()
        falseBody = `else`()
    }

    /// Creates a new instance that statically selects between two views based on a predicate instance.
    ///
    /// - Parameters:
    ///   - predicate: The predicate instance used to evaluate against view inputs.
    ///   - then: A closure that returns the view to display when the predicate evaluates to `true`.
    ///   - else: A closure that returns the view to display when the predicate evaluates to `false`.
    package init(_ predicate: Predicate, then: () -> TrueBody, else: () -> FalseBody) {
        trueBody = then()
        falseBody = `else`()
    }

    /// Creates a new instance that statically selects between two views based on an interface idiom.
    ///
    /// - Parameters:
    ///   - idiom: The interface idiom to evaluate against the current environment.
    ///   - then: A closure that returns the view to display when the current device matches the specified idiom.
    ///   - else: A closure that returns the view to display when the current device doesn't match the specified idiom.
    init<I>(idiom: I, then: () -> TrueBody, else: () -> FalseBody) where Predicate == InterfaceIdiomPredicate<I>, I: InterfaceIdiom {
        trueBody = then()
        falseBody = `else`()
    }

    /// Creates a new instance that statically selects between two views based on a style context.
    ///
    /// - Parameters:
    ///   - context: The style context to evaluate against the current environment.
    ///   - then: A closure that returns the view to display when the current context accepts the specified style.
    ///   - else: A closure that returns the view to display when the current context doesn't accept the specified style.
    package init<Context>(in context: Context, then: () -> TrueBody, else: () -> FalseBody) where Predicate == StyleContextAcceptsPredicate<Context>, Context: StyleContext {
        trueBody = then()
        falseBody = `else`()
    }

    nonisolated package static func _makeView(view: _GraphValue<Self>, inputs: _ViewInputs) -> _ViewOutputs {
        if Predicate.evaluate(inputs: inputs.base) {
            TrueBody._makeView(view: view[offset: { .of(&$0.trueBody) }], inputs: inputs)
        } else {
            FalseBody._makeView(view: view[offset: { .of(&$0.falseBody) }], inputs: inputs)
        }
    }

    nonisolated package static func _makeViewList(view: _GraphValue<Self>, inputs: _ViewListInputs) -> _ViewListOutputs {
        if Predicate.evaluate(inputs: inputs.base) {
            TrueBody._makeViewList(view: view[offset: { .of(&$0.trueBody) }], inputs: inputs)
        } else {
            FalseBody._makeViewList(view: view[offset: { .of(&$0.falseBody) }], inputs: inputs)
        }
    }

    nonisolated package static func _viewListCount(inputs: _ViewListCountInputs) -> Int? {
        if Predicate.evaluate(inputs: inputs.base) {
            TrueBody._viewListCount(inputs: inputs)
        } else {
            FalseBody._viewListCount(inputs: inputs)
        }
    }
}

extension StaticIf: PrimitiveViewModifier, ViewModifier where TrueBody: ViewModifier, FalseBody: ViewModifier {
    /// Creates a new modifier that statically applies one of two modifiers based on a predicate type.
    ///
    /// - Parameters:
    ///   - predicate: The predicate type used to evaluate against view inputs.
    ///   - then: The modifier to apply when the predicate evaluates to `true`.
    ///   - else: The modifier to apply when the predicate evaluates to `false`.
    package init(_ predicate: Predicate.Type, then: TrueBody, else: FalseBody) {
        trueBody = then
        falseBody = `else`
    }

    /// Creates a new modifier that statically applies a modifier when the predicate is true,
    /// and applies no modification when false.
    ///
    /// - Parameters:
    ///   - predicate: The predicate type used to evaluate against view inputs.
    ///   - then: The modifier to apply when the predicate evaluates to `true`.
    package init(_ predicate: Predicate.Type, then: TrueBody) where FalseBody == EmptyModifier {
        trueBody = then
        falseBody = EmptyModifier()
    }

    /// Creates a new modifier that statically applies one of two modifiers based on an interface idiom.
    ///
    /// - Parameters:
    ///   - idiom: The interface idiom to evaluate against the current environment.
    ///   - then: The modifier to apply when the current device matches the specified idiom.
    ///   - else: The modifier to apply when the current device doesn't match the specified idiom.
    package init<I>(idiom: I, then: TrueBody, else: FalseBody) where Predicate == InterfaceIdiomPredicate<I>, I: InterfaceIdiom {
        trueBody = then
        falseBody = `else`
    }

    nonisolated package static func _makeView(modifier: _GraphValue<Self>, inputs: _ViewInputs, body: @escaping (_Graph, _ViewInputs) -> _ViewOutputs) -> _ViewOutputs {
        if Predicate.evaluate(inputs: inputs.base) {
            TrueBody._makeView(modifier: modifier[offset: { .of(&$0.trueBody) }], inputs: inputs, body: body)
        } else {
            FalseBody._makeView(modifier: modifier[offset: { .of(&$0.falseBody) }], inputs: inputs, body: body)
        }
    }

    nonisolated package static func _makeViewList(modifier: _GraphValue<Self>, inputs: _ViewListInputs, body: @escaping (_Graph, _ViewListInputs) -> _ViewListOutputs) -> _ViewListOutputs {
        if Predicate.evaluate(inputs: inputs.base) {
            TrueBody._makeViewList(modifier: modifier[offset: { .of(&$0.trueBody) }], inputs: inputs, body: body)
        } else {
            FalseBody._makeViewList(modifier: modifier[offset: { .of(&$0.falseBody) }], inputs: inputs, body: body)
        }
    }

    nonisolated package static func _viewListCount(inputs: _ViewListCountInputs, body: (_ViewListCountInputs) -> Int?) -> Int? {
        if Predicate.evaluate(inputs: inputs.base) {
            TrueBody._viewListCount(inputs: inputs, body: body)
        } else {
            FalseBody._viewListCount(inputs: inputs, body: body)
        }
    }
}

extension View {
    /// Conditionally applies a modifier to a view based on a predicate type.
    ///
    /// Use this method when you want to apply a specific modifier only when the predicate
    /// evaluates to true based on view inputs, and leave the view unmodified otherwise.
    ///
    /// - Parameters:
    ///   - predicate: The predicate type used to evaluate against view inputs.
    ///   - trueModifier: A closure that takes the current view and returns a modified view when the predicate evaluates to true.
    /// - Returns: Either the modified view or the original view, depending on the predicate result.
    package func staticIf<Predicate, TrueBody>(
        _ predicate: Predicate.Type,
        trueModifier: (Self) -> TrueBody
    ) -> some View where Predicate: ViewInputPredicate, TrueBody: View {
        StaticIf(predicate) {
            trueModifier(self)
        } else: {
            self
        }
    }

    /// Conditionally applies one of two modifiers to a view based on a predicate type.
    ///
    /// Use this method when you want to apply different modifiers based on the evaluation
    /// of a predicate against view inputs.
    ///
    /// - Parameters:
    ///   - predicate: The predicate type used to evaluate against view inputs.
    ///   - trueModifier: A closure that takes the current view and returns a modified view when the predicate evaluates to true.
    ///   - falseModifier: A closure that takes the current view and returns a modified view when the predicate evaluates to false.
    /// - Returns: A view that's been modified by either the true modifier or false modifier.
    package func staticIf<Predicate, TrueBody, FalseBody>(
        _ predicate: Predicate.Type,
        trueModifier: (Self) -> TrueBody,
        falseModifier: (Self) -> FalseBody
    ) -> some View where Predicate: ViewInputPredicate, TrueBody: View, FalseBody: View {
        StaticIf(predicate) {
            trueModifier(self)
        } else: {
            falseModifier(self)
        }
    }

    /// Conditionally applies one of two modifiers to a view based on a style context.
    ///
    /// Use this method when you want to apply different modifiers based on whether
    /// the current style context accepts a specific style.
    ///
    /// - Parameters:
    ///   - context: The style context to evaluate against the current environment.
    ///   - trueModifier: A closure that takes the current view and returns a modified view when the context accepts the style.
    ///   - falseModifier: A closure that takes the current view and returns a modified view when the context doesn't accept the style.
    /// - Returns: A view that's been modified by either the true modifier or false modifier based on the context.
    package func staticIf<Context, TrueBody, FalseBody>(
        context: Context,
        trueModifier: (Self) -> TrueBody,
        falseModifier: (Self) -> FalseBody
    ) -> some View where Context: StyleContext, TrueBody: View, FalseBody: View {
        staticIf(
            StyleContextAcceptsPredicate<Context>.self,
            trueModifier: trueModifier,
            falseModifier: falseModifier
        )
    }
}

extension ViewModifier {
    /// Creates a conditional modifier that only applies when a predicate evaluates to true.
    ///
    /// Use this method to create a modifier that is only applied when certain view input
    /// conditions are met. If the predicate evaluates to false, an empty modifier is applied instead.
    ///
    /// - Parameter predicate: The predicate type used to evaluate against view inputs.
    /// - Returns: A conditional modifier that applies the current modifier only when the predicate is true.
    package func requiring<Predicate>(_ predicate: Predicate.Type) -> StaticIf<Predicate, Self, EmptyModifier> where Predicate: ViewInputPredicate {
        StaticIf(predicate, then: self)
    }
}
