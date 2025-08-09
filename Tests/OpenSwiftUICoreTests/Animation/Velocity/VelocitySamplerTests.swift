//
//  VelocitySamplerTests.swift
//  OpenSwiftUICoreTests

import Testing
@_spi(ForOpenSwiftUIOnly)
import OpenSwiftUICore

struct VelocitySamplerTests {
    @Test
    func initialization() {
        let sampler = VelocitySampler<Double>()
        #expect(sampler.lastTime == nil)
        #expect(sampler.isEmpty == false)
        #expect(sampler.velocity == .zero)
    }

    @Test
    func isEmptyLastTimeAndReset() {
        var sampler = VelocitySampler<Double>()
        #expect(sampler.lastTime == nil)
        #expect(sampler.isEmpty == false)
        #expect(sampler.velocity == .zero)

        let t1 = Time(seconds: 1.0)
        sampler.addSample(1.0, time: t1)
        #expect(sampler.lastTime == t1)
        #expect(sampler.isEmpty == true)
        #expect(sampler.velocity == .zero)

        sampler.reset()
        #expect(sampler.lastTime == nil)
        #expect(sampler.isEmpty == false)
        #expect(sampler.velocity == .zero)
    }

    @Test
    func invalidSample() {
        var sampler = VelocitySampler<Double>()
        let t1 = Time(seconds: 1.0)
        sampler.addSample(1.0, time: t1)
        #expect(sampler.lastTime == t1)
        let t0 = Time(seconds: 0.0)
        sampler.addSample(2.0, time: t0)
        #expect(sampler.lastTime == t1)
    }

    @Test
    func sampleSmallTimeUpdate() {
        var sampler = VelocitySampler<Double>()
        let t1 = Time(seconds: 1.0)
        sampler.addSample(1.0, time: t1)
        #expect(sampler.lastTime == t1)
        let t1u = t1 + Double.ulpOfOne * .ulpOfOne
        sampler.addSample(3.0, time: t1u)
        #expect(sampler.lastTime == t1)
        #expect(sampler.velocity == .zero)

        let t2 = Time(seconds: 2.0)
        sampler.addSample(4.0, time: t2)
        #expect(sampler.lastTime == t2)
        #expect(sampler.velocity.valuePerSecond.isApproximatelyEqual(to: 1.0))
    }

    @Test
    func velocityWithSharpTime() {
        var sampler = VelocitySampler<Double>()
        sampler.addSample(1.0, time: Time(seconds: 1.0))
        sampler.addSample(2.0, time: Time(seconds: 1.1))
        #expect(sampler.velocity.valuePerSecond.isApproximatelyEqual(to: 10.0))
    }

    @Test
    func multipleSamples() {
        var sampler = VelocitySampler<Double>()

        sampler.addSample(1.0, time: Time(seconds: 1.0))
        sampler.addSample(2.0, time: Time(seconds: 2.0))
        #expect(sampler.velocity.valuePerSecond.isAlmostEqual(to: 1.0))
        sampler.addSample(4.0, time: Time(seconds: 3.0))
        #expect(sampler.velocity.valuePerSecond.isAlmostEqual(to: 1.25))

        sampler.reset()

        sampler.addSample(1.0, time: Time(seconds: 1.0))
        sampler.addSample(2.0, time: Time(seconds: 2.0))
        #expect(sampler.velocity.valuePerSecond.isAlmostEqual(to: 1.0))
        sampler.addSample(4.0, time: Time(seconds: 4.0))
        #expect(sampler.velocity.valuePerSecond.isAlmostEqual(to: 1.0))
    }
}
