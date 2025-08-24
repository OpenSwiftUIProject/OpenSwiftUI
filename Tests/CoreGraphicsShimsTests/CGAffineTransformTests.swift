import Testing
import CoreGraphicsShims
import Numerics

@Suite
struct CGAffineTransformTests {

    // MARK: - Identity

    @Test
    func identityIsIdentity() {
        let t = CGAffineTransform.identity
        #expect(t.isIdentity)
    }

    // MARK: - Translation

    @Test
    func translationAppliesToPoint() {
        let t = CGAffineTransform(translationX: 10, y: 20)
        let p = CGPoint(x: 1, y: 2)
        let res = p.applying(t)
        #expect(res.x.isApproximatelyEqual(to: 11.0))
        #expect(res.y.isApproximatelyEqual(to: 22.0))
    }

    @Test
    func translationInvert() {
        let t = CGAffineTransform(translationX: 10, y: 20)
        let inv = t.inverted()
        #expect(inv.tx.isApproximatelyEqual(to: -10.0))
        #expect(inv.ty.isApproximatelyEqual(to: -20.0))
    }

    // MARK: - Scale

    @Test
    func scaleInvert() {
        let s = CGAffineTransform(scaleX: 2, y: 4)
        let inv = s.inverted()
        #expect(inv.a.isApproximatelyEqual(to: 1.0 / 2.0))
        #expect(inv.d.isApproximatelyEqual(to: 1.0 / 4.0))
    }

    // MARK: - Rotation

    @Test
    func rotation90MapsPoint() {
        let r = CGAffineTransform(rotationAngle: .pi / 2)
        #expect(r.a.isApproximatelyEqual(to: 0.0, absoluteTolerance: 0.001))
        #expect(r.b.isApproximatelyEqual(to: 1.0, absoluteTolerance:
            0.001))
        #expect(r.c.isApproximatelyEqual(to: -1.0, absoluteTolerance: 0.001))
        #expect(r.d.isApproximatelyEqual(to: 0.0, absoluteTolerance: 0.001))
        #expect(r.tx.isApproximatelyEqual(to: 0.0, absoluteTolerance: 0.001))
        #expect(r.ty.isApproximatelyEqual(to: 0.0, absoluteTolerance: 0.001))

        let p = CGPoint(x: 1, y: 0)
        let res = p.applying(r)
        #expect(res.x.isApproximatelyEqual(to: 0.0, absoluteTolerance: 0.001))
        #expect(res.y.isApproximatelyEqual(to: 1.0, absoluteTolerance: 0.001))
    }

    // MARK: - Concatenation

    @Test
    func concatenationAppliesInCorrectOrder() {
        let t = CGAffineTransform(translationX: 5, y: 7)
        let s = CGAffineTransform(scaleX: 2, y: 3)
        let concatenated = s.concatenating(t)
        let p = CGPoint(x: 1, y: 1)
        let sequential = p.applying(s).applying(t)
        let combined = p.applying(concatenated)
        #expect(sequential.x.isApproximatelyEqual(to: combined.x))
        #expect(sequential.y.isApproximatelyEqual(to: combined.y))
    }

    // MARK: - Non-invertible

    @Test
    func nonInvertibleReturnsSame() {
        var singular = CGAffineTransform.identity
        singular.a = 0
        singular.d = 0
        let inv = singular.inverted()
        #expect(inv.a.isApproximatelyEqual(to: singular.a))
        #expect(inv.d.isApproximatelyEqual(to: singular.d))
        #expect(inv.tx.isApproximatelyEqual(to: singular.tx))
        #expect(inv.ty.isApproximatelyEqual(to: singular.ty))
    }
}
