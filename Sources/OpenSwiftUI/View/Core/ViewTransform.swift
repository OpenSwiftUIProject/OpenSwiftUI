//  ID: CE19A3CEA6B9730579C42CE4C3071E74

import Foundation

struct ViewTransform {
    private var chunks: ContiguousArray<Chunk>
    var positionAdjustment: CGSize
}

extension ViewTransform {
    private class Chunk {
        var tags: [Tag]
        var values: [CGFloat]
        var spaces: [AnyHashable]
        init() {
            fatalError()
        }
        
        enum Tag {
            case translation
            case affine
            case affine_inverse
            case projection
            case projection_inverse
            case space
            case sized_space
            case scroll_layout
        }
    }
}
