//
//  LazyView.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete

// MARK: - ParameterizedLazyView

struct ParameterizedLazyView<Value, Content>: View where Content: View {
    var value: Value
    var content: (Value) -> Content

    init(value: Value, content: @escaping (Value) -> Content) {
        self.value = value
        self.content = content
    }

    var body: some View {
        content(value)
    }
}

// MARK: - LazyView

struct LazyView<Content>: View where Content: View {
    var content: () -> Content

    init(content: @escaping () -> Content) {
        self.content = content
    }

    var body: some View {
        content()
    }
}
