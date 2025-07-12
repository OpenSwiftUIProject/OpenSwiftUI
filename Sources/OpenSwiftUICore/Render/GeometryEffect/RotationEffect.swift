import Foundation

struct _RotationEffect: GeometryEffect {
    func effectValue(size: CGSize) -> ProjectionTransform {
        .init()
    }
}
