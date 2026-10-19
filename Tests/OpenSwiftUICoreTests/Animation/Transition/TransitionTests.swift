//
//  TransitionTests.swift
//  OpenSwiftUICoreTests

import Foundation
import OpenAttributeGraphShims
@_spi(ForOpenSwiftUIOnly) @testable import OpenSwiftUICore
import OpenSwiftUITestsSupport
import Testing

@MainActor
@Suite(.tags(.aigc), .disabled(if: attributeGraphVendor == .oag))
struct TransitionTests {
    @Test
    func viewListCountWitnessPreservesBodyCount() {
        var bodyCalls = 0
        let count = viewListCount(
            ApplyTransitionModifier<IdentityTransition>.self,
            inputs: _ViewListCountInputs(.init(.invalid))
        ) { _ in
            bodyCalls += 1
            return 2
        }
        #expect(count == 2)
        #expect(bodyCalls == 1)
    }

    @Test(arguments: [TransitionPhase.willAppear, .identity, .didDisappear])
    func combinedTransitionPreservesContentLayout(phase: TransitionPhase) {
        checkLayout(
            transition: MoveTransition(edge: .leading).combined(with: .opacity),
            phase: phase
        )
    }

    @Test(arguments: [TransitionPhase.willAppear, .identity, .didDisappear])
    func asymmetricTransitionPreservesContentLayout(phase: TransitionPhase) {
        checkLayout(
            transition: AsymmetricTransition(
                insertion: MoveTransition(edge: .leading).combined(with: .opacity),
                removal: OpacityTransition()
            ),
            phase: phase
        )
    }

    private func checkLayout<T: Transition>(transition: T, phase: TransitionPhase) {
        let content = Color.red
            .frame(width: 32, height: 48)
            .modifier(ApplyTransitionModifier(transition: transition, phase: phase))
        Update.perform {
            let graph = ViewGraph(rootViewType: type(of: content), requestedOutputs: .layout)
            defer { graph.invalidate() }
            graph.setRootView(content)
            #expect(graph.sizeThatFits(.unspecified) == CGSize(width: 32, height: 48))
        }
    }

    private func viewListCount<M: ViewModifier>(
        _ modifier: M.Type,
        inputs: _ViewListCountInputs,
        body: (_ViewListCountInputs) -> Int?
    ) -> Int? {
        M._viewListCount(inputs: inputs, body: body)
    }
}
