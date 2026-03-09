//
//  NamedColorExample.swift
//  Shared

#if OPENSWIFTUI
import OpenSwiftUI
#else
import SwiftUI
#endif

struct NamedColorExample: View {
    let name = "custom"
    var body: some View {
        VStack(spacing: 0) {
            Color(name)
                .environment(\.colorScheme, .light)
                .environment(\._colorSchemeContrast, .standard)
            Color(name)
                .environment(\.colorScheme, .dark)
                .environment(\._colorSchemeContrast, .standard)
            Color(name)
                .environment(\.colorScheme, .light)
                .environment(\._colorSchemeContrast, .increased)
            Color(name)
                .environment(\.colorScheme, .dark)
                .environment(\._colorSchemeContrast, .increased)
        }
    }
}
