//
//  AnySliderStyle.swift
//  OpenSwiftUI
//
//  Audited for iOS 15.5
//  Status: Complete
//  ID: 22A1D162CC670E67558243600080F90E

protocol SliderStyle {
    associatedtype Body: View
    func body(configuration: Slider<SliderStyleLabel, SliderStyleValueLabel>) -> Self.Body
}

private class AnyStyleBox {
    func body(configuration _: Slider<SliderStyleLabel, SliderStyleValueLabel>) -> AnyView {
        fatalError("")
    }
}

private final class StyleBox<Base: SliderStyle>: AnyStyleBox {
    let base: Base

    init(base: Base) {
        self.base = base
    }

    override func body(configuration: Slider<SliderStyleLabel, SliderStyleValueLabel>) -> AnyView {
        AnyView(base.body(configuration: configuration))
    }
}

struct AnySliderStyle: SliderStyle {
    private let box: AnyStyleBox

    func body(configuration: Slider<SliderStyleLabel, SliderStyleValueLabel>) -> AnyView {
        box.body(configuration: configuration)
    }

    private init(box: AnyStyleBox) {
        self.box = box
    }

    init(style: some SliderStyle) {
        self.box = StyleBox(base: style)
    }
}
