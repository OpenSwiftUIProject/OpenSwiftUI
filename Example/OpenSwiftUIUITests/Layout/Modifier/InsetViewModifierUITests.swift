//
//  InsetViewModifierUITests.swift
//  OpenSwiftUIUITests

import Testing

@MainActor
@Suite(.snapshots(record: .never, diffTool: diffTool))
struct InsetViewModifierUITests {
    
    @Test(.bug("https://github.com/OpenSwiftUIProject/OpenSwiftUI/issues/511"))
    func safeAreaPaddingWithEdgeInsets() {
        struct ContentView: View {
            var body: some View {
                Color.red
                    .safeAreaPadding(.init(top: 10, leading: 20, bottom: 30, trailing: 40))
            }
        }
        openSwiftUIAssertSnapshot(of: ContentView())
    }
    
    @Test
    func safeAreaInset() {
        struct ContentView: View {
            var body: some View {
                Color.red
                    .safeAreaInset(edge: .leading) {
                        Color.green.frame(width: 10)
                    }
                    .safeAreaInset(edge: .top) {
                        Color.blue.frame(height: 20)
                    }
                    .safeAreaInset(edge: .trailing) {
                        Color.gray.frame(width: 30)
                    }
                    .safeAreaInset(edge: .bottom) {
                        Color.yellow.frame(height: 40)
                    }
            }
        }
        openSwiftUIAssertSnapshot(of: ContentView())
    }
}
