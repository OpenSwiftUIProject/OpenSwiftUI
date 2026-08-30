//
//  ProgressViewExample.swift
//  Shared

import Foundation
#if OPENSWIFTUI
import OpenSwiftUI
#else
import SwiftUI
#endif

struct ProgressViewExample: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            ProgressView(value: 0.25)
            ProgressView("Downloading", value: 0.5)
            ProgressView(value: 0.75) {
                Text("Installing")
            } currentValueLabel: {
                Text("75%")
            }
            .tint(.blue)
        }
        .padding()
    }
}

struct IndeterminateProgressViewExample: View {
    private let localizedTitle: LocalizedStringKey = "Localized label"
    private let title = "String label"

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            ProgressView()
            ProgressView {
                Text("Custom label")
            }
            ProgressView(localizedTitle)
            ProgressView(title)
        }
        .padding()
    }
}

struct DefaultDateProgressLabelExample: View {
    private let timerInterval = Date(timeIntervalSinceReferenceDate: 0)...Date(
        timeIntervalSinceReferenceDate: 90
    )

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            ProgressView(timerInterval: timerInterval) {
                Text("Countdown")
            }
            ProgressView(
                timerInterval: timerInterval,
                countsDown: false
            )
        }
        .padding()
    }
}

struct FoundationProgressViewExample: View {
    private let progress: Progress

    init() {
        let progress = Progress(totalUnitCount: 100)
        progress.completedUnitCount = 40
        progress.localizedDescription = "Downloading"
        progress.localizedAdditionalDescription = "40%"
        self.progress = progress
    }

    var body: some View {
        ProgressView(progress)
            .padding()
    }
}

#Preview("ProgressViewExample") {
    ProgressViewExample()
}

#Preview("IndeterminateProgressViewExample") {
    IndeterminateProgressViewExample()
}

#Preview("DefaultDateProgressLabelExample") {
    DefaultDateProgressLabelExample()
}

#Preview("FoundationProgressViewExample") {
    FoundationProgressViewExample()
}
