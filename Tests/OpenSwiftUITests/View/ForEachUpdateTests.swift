//
//  ForEachUpdateTests.swift
//  OpenSwiftUITests

import Foundation
import OpenAttributeGraphShims
@testable import OpenSwiftUI
@_spi(ForOpenSwiftUIOnly) import OpenSwiftUICore
import Testing

@MainActor
struct ForEachUpdateTests {
    @Test(.disabled(if: attributeGraphVendor == .oag), .bug("https://github.com/OpenSwiftUIProject/Game2048/issues/2"))
    func replacingBoardTilesPreservesRemainingTiles() {
        struct Board: View {
            let tiles: [Int]

            var body: some View {
                ZStack(alignment: .topLeading) {
                    ForEach(0..<16) { position in
                        Color.gray
                            .frame(width: 20, height: 20)
                            .offset(x: CGFloat(position % 4) * 24, y: CGFloat(position / 4) * 24)
                    }
                    ForEach(tiles, id: \.self) { tile in
                        Color.orange
                            .frame(width: 20, height: 20)
                            .offset(x: CGFloat(tile % 4) * 24, y: CGFloat((tile / 4) % 4) * 24)
                            .zIndex(1)
                    }
                }
            }
        }

        let graph = ViewGraph(rootViewType: Board.self, requestedOutputs: [.layout, .displayList])
        graph.instantiateOutputs()
        graph.setProposedSize(CGSize(width: 96, height: 96))
        for turn in 0..<20 {
            graph.setRootView(Board(tiles: Array(turn..<(turn + 16))))
            graph.updateOutputs(at: Time(seconds: Double(turn)))
            let (list, _) = graph.displayList()
            #expect(list.items.count == 32)
        }
    }
}
