//
//  UIHostingViewBaseTests.swift
//  OpenSwiftUICoreTests

#if os(iOS) || os(visionOS)
import Foundation
import Testing
import OpenSwiftUI
@_spi(ForOpenSwiftUIOnly)
import OpenSwiftUICore
import UIKit
import OpenSwiftUITestsSupport

@MainActor
struct UIHostingViewBaseTests {
    @Test
    func startUpdateEnvironmentReturnsResolvedTraitEnvironment() {
        let uiView = UIView()
        let base = UIHostingViewBase(rootViewType: EmptyView.self, options: [])
        base.uiView = uiView
        base.traitCollectionOverride = UITraitCollection(traitsFrom: [
            UITraitCollection(layoutDirection: .rightToLeft),
            UITraitCollection(displayScale: 3.0),
        ])

        var inheritedEnvironment = EnvironmentValues()
        inheritedEnvironment.layoutDirection = .leftToRight
        inheritedEnvironment.displayScale = 1.0
        base.inheritedEnvironment = inheritedEnvironment

        let environment = base.startUpdateEnvironment()
        #expect(environment.layoutDirection == .rightToLeft)
        #expect(environment.displayScale == 3.0)
    }

    @Test(.bug(id: "#406"))
    func uiWindowSceneDeallocIssue() async throws {
        struct ContentView: View {
            @State private var showRed = false
            var body: some View {
                VStack {
                    Color(platformColor: showRed ? .red : .blue)
                        .frame(width: showRed ? 200 : 400, height: showRed ? 200 : 400)
                }
                .animation(.easeInOut(duration: 2), value: showRed)
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        showRed.toggle()
                    }
                }
            }
        }
        let hostingView = PlatformHostingController(rootView: ContentView())
        hostingView.triggerLayout()
    }
}

#endif
