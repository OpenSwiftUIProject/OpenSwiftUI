//
//  SpacerUITests.swift
//  OpenSwiftUIUITests

import Testing
import SnapshotTesting

@MainActor
@Suite(.snapshots(record: .never, diffTool: diffTool))
struct SpacerUITests {
    
    // MARK: - Basic Spacer in HStack
    
    @Test
    func spacerInHStack() {
        struct ContentView: View {
            var body: some View {
                HStack {
                    Color.red
                        .frame(width: 50, height: 50)
                    Spacer()
                    Color.blue
                        .frame(width: 50, height: 50)
                }
                .frame(width: 200, height: 80)
                .background(Color.gray.opacity(0.3))
            }
        }
        openSwiftUIAssertSnapshot(of: ContentView())
    }
    
    @Test
    func spacerInVStack() {
        struct ContentView: View {
            var body: some View {
                VStack {
                    Color.red
                        .frame(width: 50, height: 50)
                    Spacer()
                    Color.blue
                        .frame(width: 50, height: 50)
                }
                .frame(width: 80, height: 200)
                .background(Color.gray.opacity(0.3))
            }
        }
        openSwiftUIAssertSnapshot(of: ContentView())
    }
    
    // MARK: - Multiple Spacers
    
    @Test
    func multipleSpacersInHStack() {
        struct ContentView: View {
            var body: some View {
                HStack {
                    Color.red
                        .frame(width: 40, height: 50)
                    Spacer()
                    Color.blue
                        .frame(width: 40, height: 50)
                    Spacer()
                    Color.green
                        .frame(width: 40, height: 50)
                }
                .frame(width: 250, height: 80)
                .background(Color.gray.opacity(0.3))
            }
        }
        openSwiftUIAssertSnapshot(of: ContentView())
    }
    
    @Test
    func multipleSpacersInVStack() {
        struct ContentView: View {
            var body: some View {
                VStack {
                    Color.red
                        .frame(width: 50, height: 40)
                    Spacer()
                    Color.blue
                        .frame(width: 50, height: 40)
                    Spacer()
                    Color.green
                        .frame(width: 50, height: 40)
                }
                .frame(width: 80, height: 250)
                .background(Color.gray.opacity(0.3))
            }
        }
        openSwiftUIAssertSnapshot(of: ContentView())
    }
    
    // MARK: - Spacer with MinLength
    
    @Test
    func spacerWithMinLengthInHStack() {
        struct ContentView: View {
            var body: some View {
                HStack {
                    Color.red
                        .frame(width: 50, height: 50)
                    Spacer(minLength: 50)
                    Color.blue
                        .frame(width: 50, height: 50)
                }
                .frame(width: 180, height: 80)
                .background(Color.gray.opacity(0.3))
            }
        }
        openSwiftUIAssertSnapshot(of: ContentView())
    }
    
    @Test
    func spacerWithMinLengthInVStack() {
        struct ContentView: View {
            var body: some View {
                VStack {
                    Color.red
                        .frame(width: 50, height: 50)
                    Spacer(minLength: 30)
                    Color.blue
                        .frame(width: 50, height: 50)
                }
                .frame(width: 80, height: 160)
                .background(Color.gray.opacity(0.3))
            }
        }
        openSwiftUIAssertSnapshot(of: ContentView())
    }
    
    // MARK: - Spacer at Different Positions
    
    @Test
    func spacerAtStartInHStack() {
        struct ContentView: View {
            var body: some View {
                HStack {
                    Spacer()
                    Color.red
                        .frame(width: 50, height: 50)
                    Color.blue
                        .frame(width: 50, height: 50)
                }
                .frame(width: 200, height: 80)
                .background(Color.gray.opacity(0.3))
            }
        }
        openSwiftUIAssertSnapshot(of: ContentView())
    }
    
    @Test
    func spacerAtEndInHStack() {
        struct ContentView: View {
            var body: some View {
                HStack {
                    Color.red
                        .frame(width: 50, height: 50)
                    Color.blue
                        .frame(width: 50, height: 50)
                    Spacer()
                }
                .frame(width: 200, height: 80)
                .background(Color.gray.opacity(0.3))
            }
        }
        openSwiftUIAssertSnapshot(of: ContentView())
    }
    
    @Test
    func spacersAtBothEndsInHStack() {
        struct ContentView: View {
            var body: some View {
                HStack {
                    Spacer()
                    Color.red
                        .frame(width: 50, height: 50)
                    Color.blue
                        .frame(width: 50, height: 50)
                    Spacer()
                }
                .frame(width: 200, height: 80)
                .background(Color.gray.opacity(0.3))
            }
        }
        openSwiftUIAssertSnapshot(of: ContentView())
    }
    
    // MARK: - Nested Stacks with Spacers
    
    @Test
    func nestedStacksWithSpacers() {
        struct ContentView: View {
            var body: some View {
                VStack {
                    HStack {
                        Color.red
                            .frame(width: 40, height: 40)
                        Spacer()
                        Color.blue
                            .frame(width: 40, height: 40)
                    }
                    
                    Spacer()
                    
                    HStack {
                        Spacer()
                        Color.green
                            .frame(width: 40, height: 40)
                        Spacer()
                        Color.yellow
                            .frame(width: 40, height: 40)
                        Spacer()
                    }
                }
                .frame(width: 200, height: 200)
                .background(Color.gray.opacity(0.3))
            }
        }
        openSwiftUIAssertSnapshot(of: ContentView())
    }
    
    // MARK: - Spacer with Zero MinLength
    
    @Test
    func spacerWithZeroMinLength() {
        struct ContentView: View {
            var body: some View {
                HStack {
                    Color.red
                        .frame(width: 80, height: 50)
                    Spacer(minLength: 0)
                    Color.blue
                        .frame(width: 80, height: 50)
                }
                .frame(width: 160, height: 80)
                .background(Color.gray.opacity(0.3))
            }
        }
        openSwiftUIAssertSnapshot(of: ContentView())
    }
    
    // MARK: - Spacer with Large MinLength
    
    @Test
    func spacerWithLargeMinLength() {
        struct ContentView: View {
            var body: some View {
                HStack {
                    Color.red
                        .frame(width: 30, height: 50)
                    Spacer(minLength: 100)
                    Color.blue
                        .frame(width: 30, height: 50)
                }
                .frame(width: 200, height: 80)
                .background(Color.gray.opacity(0.3))
            }
        }
        openSwiftUIAssertSnapshot(of: ContentView())
    }
    
    // MARK: - Stack Without Frame Constraint
    
    @Test
    func spacerInHStackWithoutFrame() {
        struct ContentView: View {
            var body: some View {
                HStack {
                    Color.red
                        .frame(width: 50, height: 50)
                    Spacer()
                    Color.blue
                        .frame(width: 50, height: 50)
                }
                .background(Color.gray.opacity(0.3))
            }
        }
        openSwiftUIAssertSnapshot(of: ContentView())
    }
    
    @Test
    func spacerInVStackWithoutFrame() {
        struct ContentView: View {
            var body: some View {
                VStack {
                    Color.red
                        .frame(width: 50, height: 50)
                    Spacer()
                    Color.blue
                        .frame(width: 50, height: 50)
                }
                .background(Color.gray.opacity(0.3))
            }
        }
        openSwiftUIAssertSnapshot(of: ContentView())
    }
    
    // MARK: - Complex Layout
    
    @Test
    func complexLayoutWithMultipleSpacers() {
        struct ContentView: View {
            var body: some View {
                VStack(spacing: 20) {
                    HStack {
                        Color.red
                            .frame(width: 30, height: 30)
                        Spacer(minLength: 20)
                        Color.blue
                            .frame(width: 30, height: 30)
                        Spacer(minLength: 10)
                        Color.green
                            .frame(width: 30, height: 30)
                    }
                    
                    HStack {
                        Spacer()
                        Color.yellow
                            .frame(width: 60, height: 30)
                        Spacer()
                    }
                    
                    HStack {
                        Color.orange
                            .frame(width: 40, height: 30)
                        Spacer()
                        Color.purple
                            .frame(width: 40, height: 30)
                    }
                }
                .frame(width: 200, height: 180)
                .background(Color.gray.opacity(0.3))
            }
        }
        openSwiftUIAssertSnapshot(of: ContentView())
    }
}
