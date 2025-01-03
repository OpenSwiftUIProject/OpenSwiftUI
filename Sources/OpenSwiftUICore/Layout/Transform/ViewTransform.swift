//  ID: CE19A3CEA6B9730579C42CE4C3071E74

import Foundation

package struct ViewTransform {
    private var chunks: ContiguousArray<Chunk>
    var positionAdjustment: CGSize
    
    package init() {
        self.chunks = []
        self.positionAdjustment = .zero
    }
}


// MARK: - ViewTransform + Chunk

extension ViewTransform {
    @inlinable
    mutating func appendTranslation(_ size: CGSize) {
        if size != .zero {
            let chunk = mutableChunk()
            chunk.appendTranslation(size)
        }
    }
    
    private mutating func mutableChunk() -> Chunk {
        let lastIndex = chunks.count-1
        if lastIndex >= 0, isKnownUniquelyReferenced(&chunks[lastIndex]) {
            var chunks = chunks
            let chunk = chunks[chunks.count-1]
            // TODO
            return chunk
        } else {
            let chunk = Chunk()
            chunks = [chunk]
            return chunk
        }
    }
    
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

// MARK: - ViewTransform + Conversion

extension ViewTransform {
    enum Conversion {
        
        private func finished(at coordinateSpace: CoordinateSpace) -> Bool {
            // TODO
            .random()
        }
        
        private func shouldConvert(at coordinateSpace: CoordinateSpace) -> Bool {
            // TODO
            .random()
        }
    }
    
    func convert(_ conversion: ViewTransform.Conversion, space: CoordinateSpace, point: CGPoint) -> CGPoint {
        
    }

}

// MARK: AppyViewTransform

private protocol AppyViewTransform {
    mutating func convert(from coordinateSpace: CoordinateSpace, transform: ViewTransform)
}

extension CGPoint: AppyViewTransform {
    mutating func convert(from coordinateSpace: CoordinateSpace, transform: ViewTransform) {
        // TODO
    }
}
