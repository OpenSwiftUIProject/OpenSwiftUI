//
//  FrameLayoutTests.swift
//  OpenSwiftUICoreTests

import Foundation
import Numerics
@testable import OpenSwiftUICore
import OpenSwiftUITestsSupport
import Testing

// MARK: - FlexFrameLayoutTests

struct FlexFrameLayoutTests {
    // MARK: - Initialization Tests

    @Test(arguments: [
        (10.0, 20.0, 30.0, 15.0, 25.0, 35.0, Alignment.center),
        (0.0, 0.0, 0.0, 0.0, 0.0, 0.0, Alignment.topLeading),
        (100.0, 200.0, 300.0, 50.0, 100.0, 150.0, Alignment.bottomTrailing),
    ])
    func initializationWithValidConstraints(
        minWidth: Double, idealWidth: Double, maxWidth: Double,
        minHeight: Double, idealHeight: Double, maxHeight: Double,
        alignment: Alignment
    ) {
        let layout = _FlexFrameLayout(
            minWidth: minWidth,
            idealWidth: idealWidth,
            maxWidth: maxWidth,
            minHeight: minHeight,
            idealHeight: idealHeight,
            maxHeight: maxHeight,
            alignment: alignment
        )

        #expect(layout.minWidth?.isApproximatelyEqual(to: minWidth) == true)
        #expect(layout.idealWidth?.isApproximatelyEqual(to: idealWidth) == true)
        #expect(layout.maxWidth?.isApproximatelyEqual(to: maxWidth) == true)
        #expect(layout.minHeight?.isApproximatelyEqual(to: minHeight) == true)
        #expect(layout.idealHeight?.isApproximatelyEqual(to: idealHeight) == true)
        #expect(layout.maxHeight?.isApproximatelyEqual(to: maxHeight) == true)
        #expect(layout.alignment == alignment)
    }

    @Test(arguments: [
        Alignment.center,
        Alignment.topLeading,
        Alignment.bottomTrailing,
        Alignment.leading,
        Alignment.trailing
    ])
    func initializationWithNilValues(alignment: Alignment) {
        let layout = _FlexFrameLayout(alignment: alignment)

        #expect(layout.minWidth == nil)
        #expect(layout.idealWidth == nil)
        #expect(layout.maxWidth == nil)
        #expect(layout.minHeight == nil)
        #expect(layout.idealHeight == nil)
        #expect(layout.maxHeight == nil)
        #expect(layout.alignment == alignment)
    }

    @Test(arguments: [
        (-10.0, -5.0),
        (-100.0, -50.0),
        (-0.1, -0.001)
    ])
    func initializationClampsNegativeMinValues(minWidth: Double, minHeight: Double) {
        let layout = _FlexFrameLayout(
            minWidth: minWidth,
            minHeight: minHeight,
            alignment: .center
        )

        #expect(layout.minWidth?.isApproximatelyEqual(to: 0) == true)
        #expect(layout.minHeight?.isApproximatelyEqual(to: 0) == true)
    }

    @Test(arguments: [
        (20.0, 10.0, 30.0, 15.0),
        (50.0, 25.0, 100.0, 50.0),
        (100.0, 0.0, 200.0, 0.0)
    ])
    func initializationClampsIdealToMinimum(
        minWidth: Double, idealWidth: Double,
        minHeight: Double, idealHeight: Double
    ) {
        let layout = _FlexFrameLayout(
            minWidth: minWidth,
            idealWidth: idealWidth,
            minHeight: minHeight,
            idealHeight: idealHeight,
            alignment: .center
        )

        #expect(layout.idealWidth?.isApproximatelyEqual(to: minWidth) == true)
        #expect(layout.idealHeight?.isApproximatelyEqual(to: minHeight) == true)
    }

    @Test(arguments: [
        (30.0, 20.0, 40.0, 25.0),
        (100.0, 50.0, 200.0, 100.0),
        (50.0, 25.0, 75.0, 50.0)
    ])
    func initializationClampsMaxToIdeal(
        idealWidth: Double, maxWidth: Double,
        idealHeight: Double, maxHeight: Double
    ) {
        let layout = _FlexFrameLayout(
            idealWidth: idealWidth,
            maxWidth: maxWidth,
            idealHeight: idealHeight,
            maxHeight: maxHeight,
            alignment: .center
        )

        #expect(layout.maxWidth?.isApproximatelyEqual(to: idealWidth) == true)
        #expect(layout.maxHeight?.isApproximatelyEqual(to: idealHeight) == true)
    }

    // MARK: - Corner Cases with Special Float Values

    @Test(arguments: [
        Double.infinity,
        -Double.infinity,
        Double.nan
    ])
    func initializationWithInfinityAndNaNMinWidth(minWidth: Double) {
        let layout = _FlexFrameLayout(
            minWidth: minWidth,
            alignment: .center
        )
        if minWidth < 0 {
            #expect(layout.minWidth?.isApproximatelyEqual(to: 0) == true)
        } else if minWidth.isNaN {
            #expect(layout.minWidth?.isNaN == true)
        } else if minWidth.isInfinite {
            #expect(layout.minWidth?.isInfinite == true)
        }
        #expect(layout.idealWidth == nil)
        #expect(layout.maxWidth == nil)
    }

    @Test(arguments: [
        Double.infinity,
        -Double.infinity,
        Double.nan
    ])
    func initializationWithInfinityAndNaNMinHeight(minHeight: Double) {
        let layout = _FlexFrameLayout(
            minHeight: minHeight,
            alignment: .center
        )
        if minHeight < 0 {
            #expect(layout.minHeight?.isApproximatelyEqual(to: 0) == true)
        } else if minHeight.isNaN {
            #expect(layout.minHeight?.isNaN == true)
        } else if minHeight.isInfinite {
            #expect(layout.minHeight?.isInfinite == true)
        }
        #expect(layout.idealHeight == nil)
        #expect(layout.maxHeight == nil)
    }

    #if canImport(Darwin)
    @MainActor
    @Test
    func maxWidthInfinityExpandsToParentProposal() {
        struct ContentView: View {
            var body: some View {
                Color.red
                    .frame(maxWidth: .infinity)
                    .frame(width: 200, height: 200)
            }
        }
        let viewController = PlatformHostingController(rootView: ContentView())
        viewController.triggerLayout()
        let size = viewController.sizeThatFits(in: .zero)
        #expect(size == CGSize(width: 200, height: 200))
    }
    #endif
}
