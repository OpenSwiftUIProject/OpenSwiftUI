//
//  DisplayListUtil.swift
//  OpenSwiftUITestsSupport

import Foundation
#if OPENSWIFTUI
package import OpenSwiftUICore
#else
package import SwiftUI_SPI
#endif

package enum DisplayListUtil {
    package static func renderDisplayList<Content: View>(_ content: Content) -> String {
        let graph = ViewGraph(
            rootViewType: Content.self,
            requestedOutputs: [.displayList]
        )
        graph.instantiateOutputs()
        graph.setRootView(content)
        graph.setProposedSize(CGSize(width: 100, height: 100))
        let (displayList, _) = graph.displayList()
        return displayList.description
    }

    package static func containsAnyColor(_ displayList: String) -> Bool {
        displayList.contains("(color #")
    }

    package static func containsColor(_ color: String, in displayList: String) -> Bool {
        displayList.contains("(color \(color))")
    }
}
