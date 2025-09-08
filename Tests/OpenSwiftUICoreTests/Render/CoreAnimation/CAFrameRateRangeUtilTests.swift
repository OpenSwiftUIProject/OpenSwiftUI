//
//  CAFrameRateRangeUtilTests.swift
//  OpenSwiftUICoreTests

#if (os(iOS) || os(visionOS)) && canImport(QuartzCore)
import Testing
@_spi(ForOpenSwiftUIOnly)
import OpenSwiftUICore
import QuartzCore

struct CAFrameRateRangeUtilTests {
    @Test(arguments: [
        (.zero, .default),
        (0.05, .init(minimum: 20, maximum: 60, preferred: 20)), // 20
        (0.025, .init(minimum: 40, maximum: 60, preferred: 40)), // 40
        (0.02, .default), // 50
        (0.0125, .init(minimum: 80, maximum: 80, preferred: 80)), // 80
    ] as [(Double, CAFrameRateRange)])
    func initWithInterval(interval: Double, expected: CAFrameRateRange) {
        let range = CAFrameRateRange(interval: interval)
        #expect(range == expected)
    }
}
#endif
