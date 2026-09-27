//
//  PaddingLayoutUITests.swift
//  OpenSwiftUIUITests

import SnapshotTesting
import Testing

@MainActor
@Suite(.snapshots(record: .never, diffTool: diffTool))
struct PaddingLayoutUITests {
    // MARK: - Basic Padding

    @Test
    func defaultPadding() {
        struct ContentView: View {
            var body: some View {
                Color.blue
                    .frame(width: 50, height: 30)
                    .padding()
                    .background(Color.red)
            }
        }
        openSwiftUIAssertSnapshot(of: ContentView())
    }

    @Test
    func specificAmountPadding() {
        struct ContentView: View {
            var body: some View {
                Color.blue
                    .frame(width: 50, height: 30)
                    .padding(20)
                    .background(Color.red)
            }
        }
        openSwiftUIAssertSnapshot(of: ContentView())
    }

    @Test
    func zeroPadding() {
        struct ContentView: View {
            var body: some View {
                Color.blue
                    .frame(width: 50, height: 30)
                    .padding(0)
                    .background(Color.red)
            }
        }
        openSwiftUIAssertSnapshot(of: ContentView())
    }

    // MARK: - Edge-Specific Padding

    @Test
    func topPadding() {
        struct ContentView: View {
            var body: some View {
                Color.blue
                    .frame(width: 50, height: 30)
                    .padding(.top, 30)
                    .background(Color.red)
            }
        }
        openSwiftUIAssertSnapshot(of: ContentView())
    }

    @Test
    func bottomPadding() {
        struct ContentView: View {
            var body: some View {
                Color.blue
                    .frame(width: 50, height: 30)
                    .padding(.bottom, 30)
                    .background(Color.red)
            }
        }
        openSwiftUIAssertSnapshot(of: ContentView())
    }

    @Test
    func leadingPadding() {
        struct ContentView: View {
            var body: some View {
                Color.blue
                    .frame(width: 50, height: 30)
                    .padding(.leading, 30)
                    .background(Color.red)
            }
        }
        openSwiftUIAssertSnapshot(of: ContentView())
    }

    @Test
    func trailingPadding() {
        struct ContentView: View {
            var body: some View {
                Color.blue
                    .frame(width: 50, height: 30)
                    .padding(.trailing, 30)
                    .background(Color.red)
            }
        }
        openSwiftUIAssertSnapshot(of: ContentView())
    }

    @Test
    func horizontalPadding() {
        struct ContentView: View {
            var body: some View {
                Color.blue
                    .frame(width: 50, height: 30)
                    .padding(.horizontal, 40)
                    .background(Color.red)
            }
        }
        openSwiftUIAssertSnapshot(of: ContentView())
    }

    @Test
    func verticalPadding() {
        struct ContentView: View {
            var body: some View {
                Color.blue
                    .frame(width: 50, height: 30)
                    .padding(.vertical, 40)
                    .background(Color.red)
            }
        }
        openSwiftUIAssertSnapshot(of: ContentView())
    }

    @Test
    func multipleEdgesPadding() {
        struct ContentView: View {
            var body: some View {
                Color.blue
                    .frame(width: 50, height: 30)
                    .padding([.top, .trailing], 25)
                    .background(Color.red)
            }
        }
        openSwiftUIAssertSnapshot(of: ContentView())
    }

    // MARK: - EdgeInsets Padding

    @Test
    func edgeInsetsPadding() {
        struct ContentView: View {
            var body: some View {
                Color.blue
                    .frame(width: 50, height: 30)
                    .padding(EdgeInsets(top: 10, leading: 20, bottom: 30, trailing: 15))
                    .background(Color.red)
            }
        }
        openSwiftUIAssertSnapshot(of: ContentView())
    }

    @Test
    func asymmetricEdgeInsets() {
        struct ContentView: View {
            var body: some View {
                Color.blue
                    .frame(width: 50, height: 30)
                    .padding(EdgeInsets(top: 5, leading: 50, bottom: 10, trailing: 5))
                    .background(Color.red)
            }
        }
        openSwiftUIAssertSnapshot(of: ContentView())
    }

    // MARK: - Nested Padding

    @Test
    func nestedPadding() {
        struct ContentView: View {
            var body: some View {
                Color.blue
                    .frame(width: 50, height: 30)
                    .padding(10)
                    .background(Color.green)
                    .padding(20)
                    .background(Color.red)
            }
        }
        openSwiftUIAssertSnapshot(of: ContentView())
    }

    @Test
    func multiplePaddingEdges() {
        struct ContentView: View {
            var body: some View {
                Color.blue
                    .frame(width: 50, height: 30)
                    .padding(.leading, 30)
                    .background(Color.green)
                    .padding(.top, 20)
                    .background(Color.red)
            }
        }
        openSwiftUIAssertSnapshot(of: ContentView())
    }

    // MARK: - Padding with HVStack

    @Test
    func paddingInVStack() {
        struct ContentView: View {
            var body: some View {
                VStack(spacing: 0) {
                    Color.blue
                        .frame(height: 30)
                        .padding(.bottom, 20)
                        .background(Color.red)

                    Color.green
                        .frame(height: 30)
                        .padding(.top, 15)
                        .background(Color.yellow)
                }
            }
        }
        openSwiftUIAssertSnapshot(of: ContentView())
    }

    @Test
    func paddingInHStack() {
        struct ContentView: View {
            var body: some View {
                HStack(spacing: 0) {
                    Color.blue
                        .frame(width: 50)
                        .padding(.trailing, 25)
                        .background(Color.red)

                    Color.green
                        .frame(width: 50)
                        .padding(.leading, 15)
                        .background(Color.yellow)
                }
            }
        }
        openSwiftUIAssertSnapshot(of: ContentView())
    }
}
