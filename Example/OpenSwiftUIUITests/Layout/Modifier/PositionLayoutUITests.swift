//
//  PositionLayoutUITests.swift
//  OpenSwiftUIUITests

import SnapshotTesting
import Testing

@MainActor
@Suite(.snapshots(record: .never, diffTool: diffTool))
struct PositionLayoutUITests {

    @Test
    func defaultPosition() {
        struct ContentView: View {
            var body: some View {
                Color.blue
                    .frame(width: 50, height: 30)
                    .position()
            }
        }
        openSwiftUIAssertSnapshot(of: ContentView())
    }
    
    @Test
    func specificXAxis() {
        struct ContentView: View {
            var body: some View {
                Color.blue
                    .frame(width: 50, height: 30)
                    .position(x: 30)
            }
        }
        openSwiftUIAssertSnapshot(of: ContentView())
    }
    
    
    @Test
    func specificYAxis() {
        struct ContentView: View {
            var body: some View {
                Color.blue
                    .frame(width: 50, height: 30)
                    .position(y: 40)
            }
        }
        openSwiftUIAssertSnapshot(of: ContentView())
    }
    
    @Test
    func specificPosition() {
        struct ContentView: View {
            var body: some View {
                Color.blue
                    .frame(width: 50, height: 30)
                    .position(x: 50, y: 60)
            }
        }
        openSwiftUIAssertSnapshot(of: ContentView())
    }
}
