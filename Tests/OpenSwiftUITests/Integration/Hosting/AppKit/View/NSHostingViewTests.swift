//
//  NSHostingViewTests.swift
//  OpenSwiftUITests

#if os(macOS)
import AppKit
import OpenSwiftUI
import OpenSwiftUICore
import OpenSwiftUITestsSupport
import Testing

@MainActor
struct NSHostingViewTests {
    @Test(containsRuntimeIssue("Adding '%s' as a subview of %s is not supported and may result in a broken view hierarchy. Add your view above %s in a common superview or insert it into your OpenSwiftUI content in a NSViewRepresentable instead."))
    func didAddSubviewRecordsRuntimeIssue() {
        let hostingView = NSHostingView(rootView: EmptyView())
        let subview = NSView()

        Semantics.v7.test {
            hostingView.addSubview(subview)
        }

        #expect(subview.superview === hostingView)
    }
}
#endif
