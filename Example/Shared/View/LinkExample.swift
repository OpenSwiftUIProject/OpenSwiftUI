//
//  LinkExample.swift
//  Shared

import Foundation
#if OPENSWIFTUI
import OpenSwiftUI
#else
import SwiftUI
#endif

private let linkDestination = URL(string: "https://example.com")!

struct LinkExample: View {
    private let localizedTitle: LocalizedStringKey = "Localized title"
    private let title = "String title"

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Link(localizedTitle, destination: linkDestination)
            Link(title, destination: linkDestination)
            Link(destination: linkDestination) {
                HStack(spacing: 8) {
                    Color.orange
                        .frame(width: 16, height: 16)
                    Text("Custom label")
                }
            }
        }
        .padding()
    }
}

struct LinkButtonStyleExample: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Link("Default style", destination: linkDestination)
            Link("Automatic style", destination: linkDestination)
                .buttonStyle(.automatic)
            Link("Plain style", destination: linkDestination)
                .buttonStyle(.plain)
            Link("Bordered style", destination: linkDestination)
                .buttonStyle(.bordered)
            Link("Custom style", destination: linkDestination)
                .buttonStyle(ExampleLinkButtonStyle())
            #if os(macOS)
            Link("Explicit link style", destination: linkDestination)
                .buttonStyle(.link)
            Button("Link button style") {}
                .buttonStyle(.link)
            #endif
        }
        .padding()
    }
}

private struct ExampleLinkButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(.white)
            .padding(8)
            .background(.purple)
            .opacity(configuration.isPressed ? 0.5 : 1)
    }
}

struct LinkAppearanceExample: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Link("Default appearance", destination: linkDestination)
            Link("Tinted link", destination: linkDestination)
                .tint(.purple)
            Link("Foreground style", destination: linkDestination)
                .foregroundStyle(.orange)
            Link(destination: linkDestination) {
                Text("Styled label")
                    .font(.headline)
                    .foregroundStyle(.green)
            }
        }
        .padding()
    }
}

struct LinkShapeStyleExample: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Link foreground style")
                .foregroundStyle(.link)
            Rectangle()
                .fill(.link)
                .frame(height: 24)
        }
        .padding()
    }
}

#Preview("LinkExample") {
    LinkExample()
}

#Preview("LinkButtonStyleExample") {
    LinkButtonStyleExample()
}

#Preview("LinkAppearanceExample") {
    LinkAppearanceExample()
}

#Preview("LinkShapeStyleExample") {
    LinkShapeStyleExample()
}
