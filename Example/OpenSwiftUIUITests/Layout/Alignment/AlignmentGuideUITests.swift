//
//  AlignmentGuideUITests.swift
//  OpenSwiftUIUITests

import SnapshotTesting
import Testing

@MainActor
@Suite(.snapshots(record: .never, diffTool: diffTool))
struct AlignmentGuideUITests {
    @Test
    func alignmentGuideOnXY() {
        struct ContentView: View {
            var body: some View {
                VStack(alignment: .leading) {
                    ForEach(0 ..< 4) { index in
                        Color.red.opacity(Double(index) / 6.0 )
                            .alignmentGuide(.leading) { _ in CGFloat(index) * -10 }
                    }
                }
                
                VStack(alignment: .leading) {
                    ForEach(0 ..< 4) { index in
                        Color.red.opacity(Double(index) / 6.0 )
                            .alignmentGuide(.trailing) { _ in CGFloat(index) * 10 }
                    }
                }
                
                HStack(alignment: .top) {
                    ForEach(0 ..< 4) { index in
                        Color.red.opacity(Double(index) / 6.0 )
                            .alignmentGuide(.top) { _ in CGFloat(index) * -10 }
                    }
                }
                
                HStack(alignment: .top) {
                    ForEach(0 ..< 4) { index in
                        Color.red.opacity(Double(index) / 6.0 )
                            .alignmentGuide(.bottom) { _ in CGFloat(index) * 10 }
                    }
                }
            }
        }
        openSwiftUIAssertSnapshot(of: ContentView())
    }
}
