//
//  ObservationInteractionTests.swift
//  OpenSwiftUIInteractionTests

#if OPENSWIFTUI
import OpenObservation
import OpenSwiftUI
#else
import Observation
import SwiftUI
#endif
import SnapshotTesting
import Testing

@MainActor
@Suite(.tags(.interaction), .snapshots(record: .never, diffTool: diffTool))
struct ObservationInteractionTests {
    @Test
    func stateModelMutationUpdatesBody() async throws {
        let model = CounterModel()
        let content = CounterView(model: model)

        try await withInteractionTestHost(of: content, size: .init(width: 400, height: 400)) { host in
            try await host.assertSnapshot(named: "tap-\(model.count)")
            for count in 1...2 {
                try await host.tap()
                #expect(model.count == count)
                try await host.assertSnapshot(named: "tap-\(count)")
            }
        }
    }
}

@Observable
private final class CounterModel {
    var count = 0
}

private struct CounterView: View {
    @State private var model: CounterModel

    init(model: CounterModel) {
        self.model = model
    }

    var body: some View {
        let count = model.count
        Text("\(count)")
            .onTapGesture {
                model.count += 1
            }
    }
}
