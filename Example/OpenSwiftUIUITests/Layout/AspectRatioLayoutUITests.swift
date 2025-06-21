//
//  AspectRatioLayoutUITests.swift
//  OpenSwiftUIUITests

import SnapshotTesting
import Testing

@MainActor
@Suite(.snapshots(record: .never, diffTool: diffTool))
struct AspectRatioLayoutUITests {
    @Test
    func aspectRatioHalfInRect() {
        struct ContentView: View {
            var body: some View {
                ZStack {
                    Color.red.opacity(0.5)
                        .aspectRatio(0.5, contentMode: .fit)
                        .frame(width: 100, height: 50)
                    Color.green.opacity(0.5)
                        .aspectRatio(0.5, contentMode: .fill)
                        .frame(width: 50, height: 100)
                }
                .frame(width: 100, height: 100)
                .background { Color.blue.opacity(0.5) }
            }
        }
        openSwiftUIAssertSnapshot(
            of: ContentView(),
            // FIXME: Workaround #340
            perceptualPrecision: 0.99
        )
    }

    @Test
    func aspectRatioTwoInSquare() {
        struct ContentView: View {
            var body: some View {
                ZStack {
                    Color.red.opacity(0.5)
                        .aspectRatio(CGSize(width: 2, height: 1), contentMode: .fit)
                        .frame(width: 100, height: 50)
                    Color.green.opacity(0.5)
                        .aspectRatio(CGSize(width: 20, height: 10), contentMode: .fill)
                        .frame(width: 50, height: 100)
                }
                .frame(width: 100, height: 100)
                .background { Color.blue.opacity(0.5) }
            }
        }
        openSwiftUIAssertSnapshot(
            of: ContentView(),
            // FIXME: Workaround #340
            perceptualPrecision: 0.99
        )
    }

    @Test
    func aspectRatioNilInSquare() {
        struct ContentView: View {
            var body: some View {
                ZStack {
                    Color.red.opacity(0.5)
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 100, height: 50)
                    Color.green.opacity(0.5)
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 50, height: 100)
                }
                .frame(width: 200, height: 200)
                .background { Color.blue.opacity(0.5) }
            }
        }
        openSwiftUIAssertSnapshot(
            of: ContentView(),
            // FIXME: Workaround #340
            perceptualPrecision: 0.99
        )
    }

}
