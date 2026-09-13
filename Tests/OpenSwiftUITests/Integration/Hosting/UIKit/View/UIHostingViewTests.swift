//
//  UIHostingViewTests.swift
//  OpenSwiftUITests

#if os(iOS) || os(visionOS)
import OpenSwiftUI
import OpenSwiftUICore
import OpenSwiftUITestsSupport
import Testing
import UIKit

@MainActor
struct UIHostingViewTests {
    @Test(containsRuntimeIssue("Adding '%s' as a subview of %s is not supported and may result in a broken view hierarchy. Add your view above %s in a common superview or insert it into your OpenSwiftUI content in a UIViewRepresentable instead."))
    func didAddSubviewRecordsRuntimeIssue() {
        let hostingView = _UIHostingView(rootView: EmptyView())
        let subview = UIView()

        Semantics.v7.test {
            hostingView.addSubview(subview)
        }

        #expect(subview.superview === hostingView)
    }
}
#endif
