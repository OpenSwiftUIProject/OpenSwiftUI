//
//  StaticIf.swift
//  OpenSwiftUI
//
//  Audited for iOS 15.5
//  Status: WIP

struct StaticIf<A, B, C> where A: ViewInputPredicate {
    var trueBody: B
    var falseBody: C
}

extension StaticIf: PrimitiveViewModifier, ViewModifier where B: ViewModifier, C: ViewModifier {
    init(_: A.Type, then: B, else: C) {
        trueBody = then
        falseBody = `else`
    }

    init(_: A.Type, then: B) where C == EmptyModifier {
        trueBody = then
        falseBody = EmptyModifier()
    }
}

extension StaticIf: PrimitiveView, View where B: View, C: View {
    init(_: A.Type, then: B, else: C) {
        trueBody = then
        falseBody = `else`
    }

//    init<A1>(in _: A1.Type, then: () -> B, else: () -> C) where A == StyleContextPredicate<A1>, A1: StyleContext {
//        trueBody = then()
//        falseBody = `else`()
//    }
}
