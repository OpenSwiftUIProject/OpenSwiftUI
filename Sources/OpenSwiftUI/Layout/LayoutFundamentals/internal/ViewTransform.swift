//  ID: CE19A3CEA6B9730579C42CE4C3071E74

import Foundation

struct ViewTransform {
    private var chunks: ContiguousArray<Chunk>
    var positionAdjustment: CGSize
    
    init() {
        self.chunks = []
        self.positionAdjustment = .zero
    }
}

extension ViewTransform {
    private class Chunk {
        var tags: [Tag] = []
        var values: [CGFloat] = []
        var spaces: [AnyHashable] = []
        
        enum Tag: UInt8 {
            case translation
            case affine
            case affine_inverse
            case projection
            case projection_inverse
            case space
            case sized_space
            case scroll_layout
        }
        
        func appendTranslation(_ translation: CGSize) {
            tags.append(.translation)
            values.append(translation.width)
            values.append(translation.height)
            
        }
    }
}

extension ViewTransform {
    enum Item/*: Codable*/ {
        case translation(CGSize)
        #if canImport(Darwin)
        case affineTransform(CGAffineTransform, inverse: Bool)
        #endif
        case projectionTransform(ProjectionTransform, inverse: Bool)
        case coordinateSpace(name: AnyHashable)
        case sizedSpace(name: AnyHashable, size: CGSize)
        // case scrollLayout(_ScrollLayout)

        enum CodingKeys: CodingKey {
            case translation
            case affineTransform
            case projection
        }
    }
}
