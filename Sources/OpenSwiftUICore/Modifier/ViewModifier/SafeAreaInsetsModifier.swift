//
//  ViewBuilder.swift
//  OpenSwiftUI
//
//  Audited for RELEASE_2023
//  Status: WIP

struct _SafeAreaInsetsModifier: PrimitiveViewModifier/*, MultiViewModifier*/ {
    var elements: [SafeAreaInsets.Element]
    var nextInsets: SafeAreaInsets.OptionalValue?
    
    var insets: EdgeInsets = .init() // FIXME
}
