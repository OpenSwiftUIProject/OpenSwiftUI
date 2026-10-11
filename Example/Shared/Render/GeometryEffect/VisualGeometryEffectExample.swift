//
//  VisualGeometryEffectExample.swift
//  Shared

#if OPENSWIFTUI
import OpenSwiftUI
#else
import SwiftUI
#endif

struct VisualGeometryEffectExample: View {
    enum Effect: String, CaseIterable {
        case affineTransform
        case projectionTransform
        case scalarScale
        case sizeScale
        case xyScale
        case rotation
        case rotation3D
        case sizeOffset
        case xyOffset
        case scaleThenOffset
        case offsetThenScale
    }

    var effect: Effect = .affineTransform

    var body: some View {
        effectContent
            .background(Color(white: 0.8))
    }

    @ViewBuilder
    private var effectContent: some View {
        let sample = GeometryEffectSample()
        switch effect {
        case .affineTransform:
            sample.visualEffect { content, _ in
                content.transformEffect(TransformEffectExample.transform)
            }
        case .projectionTransform:
            sample.visualEffect { content, _ in
                content.transformEffect(ProjectionEffectExample.transform)
            }
        case .scalarScale:
            sample.visualEffect { content, _ in
                content.scaleEffect(0.65, anchor: .bottomTrailing)
            }
        case .sizeScale:
            sample.visualEffect { content, _ in
                content.scaleEffect(CGSize(width: 0.6, height: 1.3), anchor: .topLeading)
            }
        case .xyScale:
            sample.visualEffect { content, _ in
                content.scaleEffect(x: 0.6, y: 1.3, anchor: .topLeading)
            }
        case .rotation:
            sample.visualEffect { content, _ in
                content.rotationEffect(.degrees(25), anchor: .bottomLeading)
            }
        case .rotation3D:
            sample.visualEffect { content, _ in
                content.rotation3DEffect(
                    .degrees(50),
                    axis: (x: 1, y: 2, z: 0.5),
                    anchor: .topTrailing,
                    anchorZ: 12,
                    perspective: 0.7
                )
            }
        case .sizeOffset:
            sample.visualEffect { content, proxy in
                content.offset(CGSize(width: proxy.size.width / 4, height: proxy.size.height / 5))
            }
        case .xyOffset:
            sample.visualEffect { content, proxy in
                content.offset(x: proxy.size.width / 4, y: proxy.size.height / 5)
            }
        case .scaleThenOffset:
            sample.visualEffect { content, proxy in
                content
                    .scaleEffect(x: 0.65, y: 1.2, anchor: .topLeading)
                    .offset(x: proxy.size.width / 4, y: proxy.size.height / 5)
            }
        case .offsetThenScale:
            sample.visualEffect { content, proxy in
                content
                    .offset(x: proxy.size.width / 4, y: proxy.size.height / 5)
                    .scaleEffect(x: 0.65, y: 1.2, anchor: .topLeading)
            }
        }
    }
}

#Preview {
    VisualGeometryEffectExample()
        .frame(width: 200, height: 200)
}
