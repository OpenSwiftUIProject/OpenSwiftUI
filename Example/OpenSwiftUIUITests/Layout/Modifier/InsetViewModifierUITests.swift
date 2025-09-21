//
//  InsetViewModifierUITests.swift
//  OpenSwiftUIUITests

import Testing

@MainActor
struct InsetViewModifierUITests {
    @Test(.bug("https://github.com/OpenSwiftUIProject/OpenSwiftUI/issues/511"))
    func safeAreaPaddingWithEdgeInsets() {
        struct ContentView: View {
            var body: some View {
                Color.red
                    .safeAreaPadding(.init(top: 10, leading: 20, bottom: 30, trailing: 40))
            }
        }
        #if OPENSWIFTUI
        withKnownIssue {
            openSwiftUIAssertSnapshot(of: ContentView())
        }
        #else
        openSwiftUIAssertSnapshot(of: ContentView())
        #endif
    }
}
