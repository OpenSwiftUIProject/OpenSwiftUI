//
//  TimeTests.swift
//  OpenSwiftUICoreTests

@_spi(ForOpenSwiftUIOnly)
import OpenSwiftUICore
import Testing
import Numerics

struct TimeTests {
    @Test
    func initialization() {
        let time1 = Time(seconds: 10)
        #expect(time1.seconds.isApproximatelyEqual(to: 10))

        let time2 = Time()
        #expect(time2.seconds.isApproximatelyEqual(to: 0))

        #expect(Time.zero.seconds.isApproximatelyEqual(to: 0))
        #expect(Time.infinity.seconds == Double.infinity)
    }

    @Test
    func systemUptime() {
        let uptime = Time.systemUptime
        #expect(uptime.seconds > 0)
    }

    @Test
    func negation() {
        let time = Time(seconds: 5)
        let negated = -time
        #expect(negated.seconds.isApproximatelyEqual(to: -5))
    }

    @Test
    func addition() {
        let time = Time(seconds: 5)
        let result1 = time + 3
        #expect(result1.seconds.isApproximatelyEqual(to: 8))

        let result2 = 3 + time
        #expect(result2.seconds.isApproximatelyEqual(to: 8))

        var time2 = Time(seconds: 5)
        time2 += 3
        #expect(time2.seconds.isApproximatelyEqual(to: 8))
    }

    @Test
    func subtraction() {
        let time = Time(seconds: 5)
        let result1 = time - 3
        #expect(result1.seconds.isApproximatelyEqual(to: 2))

        let time2 = Time(seconds: 8)
        let diff = time2 - time
        #expect(diff.isApproximatelyEqual(to: 3))

        var time3 = Time(seconds: 5)
        time3 -= 3
        #expect(time3.seconds.isApproximatelyEqual(to: 2))
    }

    @Test
    func multiplication() {
        let time = Time(seconds: 5)
        let result = time * 3
        #expect(result.seconds.isApproximatelyEqual(to: 15))

        var time2 = Time(seconds: 5)
        time2 *= 3
        #expect(time2.seconds.isApproximatelyEqual(to: 15))
    }

    @Test
    func division() {
        let time = Time(seconds: 15)
        let result = time / 3
        #expect(result.seconds.isApproximatelyEqual(to: 5))

        var time2 = Time(seconds: 15)
        time2 /= 3
        #expect(time2.seconds.isApproximatelyEqual(to: 5))
    }

    @Test
    func comparison() {
        let time1 = Time(seconds: 5)
        let time2 = Time(seconds: 10)
        let time3 = Time(seconds: 5)

        #expect(time1 < time2)
        #expect(time1 <= time2)
        #expect(time2 > time1)
        #expect(time2 >= time1)
        #expect(time1 == time3)
        #expect(time1 != time2)
    }

    @Test
    func hashable() {
        let time1 = Time(seconds: 5)
        let time2 = Time(seconds: 5)
        let time3 = Time(seconds: 10)

        var set = Set<Time>()
        set.insert(time1)
        set.insert(time2)
        set.insert(time3)

        #expect(set.count == 2)
    }

    @Test
    func sendable() {
        let time = Time(seconds: 5)
        Task {
            let copiedTime = time
            #expect(copiedTime.seconds.isApproximatelyEqual(to: 5))
        }
    }
}
