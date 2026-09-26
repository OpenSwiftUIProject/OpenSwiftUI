//
//  ObservationUXTests.swift
//  OpenSwiftUIUXTests

#if OPENSWIFTUI
import OpenObservation
import OpenSwiftUI
#else
import Observation
import SwiftUI
#endif
import Testing

@MainActor
@Suite
struct ObservationUXTests {
    @Test
    func stateModelMutationUpdatesBody() async throws {
        var displayedCounts: [Int] = []
        let content = CounterView { displayedCounts.append($0) }

        try await withUXTestHost(of: content) { host in
            try await host.waitUntil(displayedCounts == [0])
            for count in 1...2 {
                try await host.tap()
                try await host.waitUntil(displayedCounts.last == count)
                #expect(displayedCounts == Array(0...count))
            }
        }
    }
}

@Observable
private final class CounterModel {
    var count = 0
}

private struct CounterView: View {
    @State private var model = CounterModel()
    let onChange: (Int) -> Void

    var body: some View {
        let count = model.count
        Text("\(count)")
            .onTapGesture {
                model.count += 1
            }
            .onChange(of: count, initial: true) { _, newValue in
                onChange(newValue)
            }
    }
}
