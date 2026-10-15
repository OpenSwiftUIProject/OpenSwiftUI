//
//  JindoTripleVStackUITests.swift
//  OpenSwiftUIUITests

#if !os(macOS)
#if OPENSWIFTUI
@_spi(Jindo) import OpenSwiftUI
#else
@_spi(Jindo) import SwiftUI_SPI
#endif
import SnapshotTesting
import Testing

private let islandSize = CGSize(width: 360, height: 140)

private let configuration = JindoTripleVStack.Configuration(
    notchSize: CGSize(width: 126, height: 37),
    horizontalSizing: .split,
    layoutMargins: EdgeInsets()
)

/// Hosts one subview and reports zero spacing preferences for it.
private struct ZeroSpacingLayout: Layout {
    func sizeThatFits(
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) -> CGSize {
        subviews.first?.sizeThatFits(proposal) ?? .zero
    }

    func placeSubviews(
        in bounds: CGRect,
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) {
        subviews.first?.place(at: bounds.origin, anchor: .topLeading, proposal: proposal)
    }

    func spacing(subviews: Subviews, cache: inout ()) -> ViewSpacing {
        .zero
    }
}

@MainActor
@Suite(.snapshots(record: .never, diffTool: diffTool))
struct JindoTripleVStackUITests {
    /// A trailing child with a trailing content margin ends inside the
    /// trailing edge by the margin instead of touching the edge.
    @Test
    func trailingContentMarginsInsetFromTrailingEdge() {
        struct ContentView: View {
            var body: some View {
                JindoTripleVStack(configuration: configuration) {
                    Color.red
                        .frame(width: 60, height: 24)
                        .jindoPosition(.leading)
                    Color.blue
                        .frame(width: 60, height: 24)
                        .jindoPosition(.trailing)
                        .jindoContentMargins(
                            JindoTripleVStack.ContentMargins(trailing: 12)
                        )
                    Color.green
                        .frame(height: 20)
                        .jindoPosition(.bottom)
                }
            }
        }
        openSwiftUIAssertSnapshot(of: ContentView(), size: islandSize)
    }

    /// Horizontal content margins on a center child stay centered when the
    /// side stacks switch to full-width mode.
    @Test
    func centerContentMarginsIgnoredInFullWidthStack() {
        struct ContentView: View {
            var body: some View {
                JindoTripleVStack(configuration: configuration) {
                    Color.red
                        .frame(width: 60, height: 24)
                        .jindoPosition(.leading)
                    Color.purple
                        .frame(width: 80, height: 20)
                        .jindoPosition(.center)
                        .jindoContentMargins(
                            JindoTripleVStack.ContentMargins(leading: 20, trailing: 20)
                        )
                    Color.green
                        .frame(height: 20)
                        .jindoPosition(.bottom)
                }
            }
        }
        openSwiftUIAssertSnapshot(of: ContentView(), size: islandSize)
    }

    /// The spacing between the side stacks and the center comes from the
    /// top children only, so a zero-spacing bottom child does not remove the
    /// default spacing between the side children and the center child.
    @Test
    func bottomChildSpacingIgnoredForSideSpacing() {
        struct ContentView: View {
            var body: some View {
                JindoTripleVStack(configuration: configuration) {
                    Color.red
                        .frame(height: 24)
                        .jindoPosition(.leading)
                    Color.purple
                        .frame(width: 140, height: 20)
                        .jindoPosition(.center)
                    Color.blue
                        .frame(height: 24)
                        .jindoPosition(.trailing)
                    ZeroSpacingLayout {
                        Color.green.frame(height: 20)
                    }
                    .jindoPosition(.bottom)
                }
            }
        }
        openSwiftUIAssertSnapshot(of: ContentView(), size: islandSize)
    }

    /// A leading child that moves below the notch when too wide stops the
    /// minimum width scan, so the later leading child does not shrink the
    /// center proposal.
    @Test
    func belowNotchChildStopsMinimumWidthScan() {
        struct ContentView: View {
            var body: some View {
                JindoTripleVStack(configuration: configuration) {
                    Color.red
                        .frame(width: 140, height: 20)
                        .jindoPosition(.leading)
                        .jindoVerticalPlacement(.belowNotchIfTooWide)
                    Color.orange
                        .frame(width: 90, height: 20)
                        .jindoPosition(.leading)
                    Color.purple
                        .frame(height: 20)
                        .jindoPosition(.center)
                    Color.blue
                        .frame(width: 30, height: 20)
                        .jindoPosition(.trailing)
                    Color.green
                        .frame(height: 20)
                        .jindoPosition(.bottom)
                }
            }
        }
        openSwiftUIAssertSnapshot(of: ContentView(), size: islandSize)
    }
}
#endif
