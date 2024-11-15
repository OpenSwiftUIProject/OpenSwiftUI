//
//  FB13341321.swift
//  Test
//
//  Created by Kyle on 2023/11/6.
//

// https://github.com/feedback-assistant/reports/issues/444
// (4 toggles: C1T1 C1T2 C2T1 C2T2 - C1T1&C2T1 use the same truth, C1T2&C2T2 use the same truth )
// macOS 14 behavior with SwiftUI
// C1T1's UI will only be updated at most 1 time if we only tap T1.
// C2T1 will always reflect the latest value in UI. A tap for T2 will make C1T1's UI up to data.
// Tap on C1T2 or C2T2 will update both toggle at the same time. (Expected)
//
// iOS 17 behavior with SwiftUI
// Tap on C2T1 will only update toggle C2T1 while the UI of C1T1 remains the same.
// Tap on C1T1 will update both toggle(C1T1 & C2T1) at the same time. (Expected)
// Tap on C1T2 or C2T2 will update both toggle at the same time. (Expected)
//
// iOS 15.5 behavior with SwiftUI
// Tap on C1T1 or C2T1 will update both toggle at the same time. (Expected)
// Tap on C1T2 or C2T2 will update both toggle at the same time. (Expected)
// But one is with transactino and the other is not.
//
// Status Update:
// Fixed on macOS 15.1

import SwiftUI
import Observation

@available(iOS 14, *)
enum FB13341321 {
    public struct Section: View {

        public let content: AnyView

        public init(
            @ViewBuilder content: @escaping () -> some View
        ) {

            self.content = content().eraseToAnyView()
        }

        public var body: some View {
            content
        }
    }

    @resultBuilder
    public struct SectionBuilder {
        public static func buildBlock(_ sections: Section...) -> [Section] {
            sections
        }
    }
    public struct Container: View {
        private let builder: () -> [Section]

        public init(
            @SectionBuilder builder: @escaping () -> [Section]
        ) {
            self.builder = builder
        }

        public var body: some View {
            let sections = builder()
            return sections[0]
        }
    }

    public struct Container2: View {
        private let sections: [Section]

        public init(
            sections: [Section] = []
        ) {
            self.sections = sections
        }

        public var body: some View {
            return sections[0]
        }
    }

    struct ContentView: View {
        @AppStorage("Test") private var toggle = false
        @State private var toggle2 = false
        var body: some View {
            Container {
                Section {
                    Toggle("Demo Toggle", isOn: $toggle)
                    Toggle("Demo Toggle2", isOn: $toggle2)
                }
            }
            Container2(sections: [
                Section {
                    Toggle("Demo Toggle", isOn: $toggle)
                    Toggle("Demo Toggle2", isOn: $toggle2)
                }
            ])
        }
    }
}

extension View {
    func eraseToAnyView() -> AnyView {
        AnyView(self)
    }
}

@available(iOS 14, *)
#Preview {
    FB13341321.ContentView()
        .padding(20)
}
