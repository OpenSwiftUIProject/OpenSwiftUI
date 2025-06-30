import Foundation

struct _Rotation3DEffect: GeometryEffect {
    func effectValue(size: CGSize) -> ProjectionTransform {
        .init()
    }
}
