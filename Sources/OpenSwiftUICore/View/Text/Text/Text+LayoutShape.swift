//
//  Text+LayoutShape.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: 0B075DB77A31A3DA949C6F4F810CBA16 (SwiftUICore)

package import Foundation

package struct TextShape: Equatable {
    private enum Exclusion: Equatable {
        case excludeTop(HorizontalEdge, CGSize)
    }

    package static func excludeTop(
        _ edge: HorizontalEdge,
        size: CGSize
    ) -> TextShape {
        TextShape(exclusion: .excludeTop(edge, size))
    }

    package static var bounds: TextShape {
        TextShape(exclusion: nil)
    }

    private var exclusion: Exclusion?

    package struct Resolved: Equatable {
        package enum Kind: Equatable {
            case excludeTop(AbsoluteEdge, CGSize)
            case bounds
        }

        package var boundsSize: CGSize

        package var kind: TextShape.Resolved.Kind

        package init(
            boundsSize: CGSize,
            kind: TextShape.Resolved.Kind
        ) {
            self.boundsSize = boundsSize
            self.kind = kind
        }

        package init() {
            self.boundsSize = .zero
            self.kind = .bounds
        }

        package func adjustLayout(
            width: inout CGFloat,
            height: inout CGFloat,
            targetWidth: CGFloat?
        ) {
            guard case let .excludeTop(edge, size) = kind else {
                return
            }
            switch edge {
            case .left:
                if let targetWidth {
                    width = targetWidth
                }
                height = max(height, size.height)
            case .right:
                if let targetWidth {
                    width = targetWidth
                } else {
                    width = size.width + width
                }
                height = max(height, size.height)
            default: _openSwiftUIUnreachableCode()
            }
        }

        package var exclusionPaths: [Path] {
            guard case let .excludeTop(edge, size) = kind else {
                return []
            }
            let x = edge == .right ? boundsSize.width - size.width : .zero
            let rect = CGRect(origin: CGPoint(x: x, y: .zero), size: size)
            return [Path(rect)]
        }
    }

    package func resolve(
        in size: CGSize,
        layoutDirection: LayoutDirection
    ) -> Resolved {
        guard case let .excludeTop(edge, exclusionSize) = exclusion else {
            return Resolved(boundsSize: .zero, kind: .bounds)
        }
        let absoluteEdge: AbsoluteEdge = switch edge {
        case .leading: layoutDirection == .rightToLeft ? .right : .left
        case .trailing: layoutDirection == .rightToLeft ? .left : .right
        }
        return Resolved(
            boundsSize: CGSize(
                width: size.width == .infinity ? .greatestFiniteMagnitude : size.width,
                height: size.height == .infinity ? .greatestFiniteMagnitude : size.height
            ),
            kind: .excludeTop(absoluteEdge, exclusionSize)
        )
    }
}

extension EnvironmentValues {
    @Entry var textShape: TextShape = .bounds
}
