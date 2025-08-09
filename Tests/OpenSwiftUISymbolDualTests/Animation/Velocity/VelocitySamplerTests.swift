//
//  VelocitySamplerTests.swift
//  OpenSwiftUISymbolDualTests

#if canImport(SwiftUI, _underlyingVersion: 6.5.4)
import Testing
@_spi(ForOpenSwiftUIOnly)
import OpenSwiftUICore

extension VelocitySampler {
    @_silgen_name("OpenSwiftUITestStub_VelocitySamplerInit")
    init(swiftUI: Void)

    @_silgen_name("OpenSwiftUITestStub_VelocitySamplerAddSample")
    mutating func swiftUI_addSample(_ sample: T, time: Time)

    @_silgen_name("OpenSwiftUITestStub_VelocitySamplerReset")
    mutating func swiftUI_reset()

    var swiftUI_isEmpty: Bool {
        @_silgen_name("OpenSwiftUITestStub_VelocitySamplerIsEmpty")
        get
    }

    var swiftUI_velocity: _Velocity<T> {
        @_silgen_name("OpenSwiftUITestStub_VelocitySamplerVelocity")
        get
    }

    var swiftUI_lastTime: Time? {
        @_silgen_name("OpenSwiftUITestStub_VelocitySamplerLastTime")
        get
    }
}

struct VelocitySamplerTests {
    @Test
    func initialization() {
        let sampler = VelocitySampler<Double>(swiftUI: ())
        #expect(sampler.swiftUI_lastTime == nil)
        #expect(sampler.swiftUI_isEmpty == false)
        #expect(sampler.swiftUI_velocity == .zero)
    }

    @Test
    func isEmptyLastTimeAndReset() {
        var sampler = VelocitySampler<Double>(swiftUI: ())
        #expect(sampler.swiftUI_lastTime == nil)
        #expect(sampler.swiftUI_isEmpty == false)
        #expect(sampler.swiftUI_velocity == .zero)

        let t1 = Time(seconds: 1.0)
        sampler.swiftUI_addSample(1.0, time: t1)
        #expect(sampler.swiftUI_lastTime == t1)
        #expect(sampler.swiftUI_isEmpty == true)
        #expect(sampler.swiftUI_velocity == .zero)

        sampler.swiftUI_reset()
        #expect(sampler.swiftUI_lastTime == nil)
        #expect(sampler.swiftUI_isEmpty == false)
        #expect(sampler.swiftUI_velocity == .zero)
    }

    @Test
    func invalidSample() {
        var sampler = VelocitySampler<Double>(swiftUI: ())
        let t1 = Time(seconds: 1.0)
        sampler.swiftUI_addSample(1.0, time: t1)
        #expect(sampler.swiftUI_lastTime == t1)
        let t0 = Time(seconds: 0.0)
        sampler.swiftUI_addSample(2.0, time: t0)
        #expect(sampler.swiftUI_lastTime == t1)
    }

    @Test
    func sampleSmallTimeUpdate() {
        var sampler = VelocitySampler<Double>(swiftUI: ())
        let t1 = Time(seconds: 1.0)
        sampler.swiftUI_addSample(1.0, time: t1)
        #expect(sampler.swiftUI_lastTime == t1)
        let t1u = t1 + Double.ulpOfOne * .ulpOfOne
        sampler.swiftUI_addSample(3.0, time: t1u)
        #expect(sampler.swiftUI_lastTime == t1)
        #expect(sampler.swiftUI_velocity == .zero)

        let t2 = Time(seconds: 2.0)
        sampler.swiftUI_addSample(4.0, time: t2)
        #expect(sampler.swiftUI_lastTime == t2)
        #expect(sampler.swiftUI_velocity.valuePerSecond.isApproximatelyEqual(to: 1.0))
    }

    @Test
    func velocityWithSharpTime() {
        var sampler = VelocitySampler<Double>(swiftUI: ())
        sampler.swiftUI_addSample(1.0, time: Time(seconds: 1.0))
        sampler.swiftUI_addSample(2.0, time: Time(seconds: 1.1))
        #expect(sampler.swiftUI_velocity.valuePerSecond.isApproximatelyEqual(to: 10.0))
    }

    @Test
    func multipleSamples() {
        var sampler = VelocitySampler<Double>(swiftUI: ())

        sampler.swiftUI_addSample(1.0, time: Time(seconds: 1.0))
        sampler.swiftUI_addSample(2.0, time: Time(seconds: 2.0))
        #expect(sampler.swiftUI_velocity.valuePerSecond.isAlmostEqual(to: 1.0))
        sampler.swiftUI_addSample(4.0, time: Time(seconds: 3.0))
        #expect(sampler.swiftUI_velocity.valuePerSecond.isAlmostEqual(to: 1.25))

        sampler.swiftUI_reset()

        sampler.swiftUI_addSample(1.0, time: Time(seconds: 1.0))
        sampler.swiftUI_addSample(2.0, time: Time(seconds: 2.0))
        #expect(sampler.swiftUI_velocity.valuePerSecond.isAlmostEqual(to: 1.0))
        sampler.swiftUI_addSample(4.0, time: Time(seconds: 4.0))
        #expect(sampler.swiftUI_velocity.valuePerSecond.isAlmostEqual(to: 1.0))
    }
}

#endif
