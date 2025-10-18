//
//  FlowLayout.swift
//  SharedExample

#if OPENSWIFTUI
import OpenSwiftUI
#else
import SwiftUI
#endif

struct FlowLayout: Layout {
    enum HorizontalAlignment {
        case leading, center, trailing
    }

    struct Cache {
        var frames: [CGRect] = []
        var containerSize: CGSize = .zero
        var proposalWidth: CGFloat? = nil
    }

    private let spacing: CGFloat
    private let rowSpacing: CGFloat
    private let alignment: HorizontalAlignment
    private let maxRowWidth: CGFloat?

    init(spacing: CGFloat = 8,
         rowSpacing: CGFloat = 8,
         alignment: HorizontalAlignment = .leading,
         maxRowWidth: CGFloat? = nil) {
        self.spacing = spacing
        self.rowSpacing = rowSpacing
        self.alignment = alignment
        self.maxRowWidth = maxRowWidth
    }

    func makeCache(subviews: Subviews) -> Cache { Cache() }

    func updateCache(_ cache: inout Cache, subviews: Subviews) {
        cache.frames.removeAll(keepingCapacity: true)
    }

    func sizeThatFits(proposal: ProposedViewSize,
                      subviews: Subviews,
                      cache: inout Cache) -> CGSize {
        let proposedWidth = maxRowWidth ?? proposal.width ?? .greatestFiniteMagnitude

        let result = layoutFrames(for: subviews, inWidth: proposedWidth, proposal: proposal)
        cache.frames = result.frames
        cache.containerSize = result.size
        cache.proposalWidth = proposedWidth
        return result.size
    }

    func placeSubviews(in bounds: CGRect,
                       proposal: ProposedViewSize,
                       subviews: Subviews,
                       cache: inout Cache) {
        let actualWidth = maxRowWidth ?? bounds.width
        if cache.frames.isEmpty || cache.proposalWidth != actualWidth {
            let result = layoutFrames(for: subviews, inWidth: actualWidth, proposal: proposal)
            cache.frames = result.frames
            cache.containerSize = result.size
            cache.proposalWidth = actualWidth
        }

        var lineStartIndex = 0
        while lineStartIndex < cache.frames.count {
            let y = cache.frames[lineStartIndex].origin.y
            var lineEndIndex = lineStartIndex
            while lineEndIndex + 1 < cache.frames.count &&
                  abs(cache.frames[lineEndIndex + 1].origin.y - y) < 0.5 {
                lineEndIndex += 1
            }

            let lineFrames = cache.frames[lineStartIndex...lineEndIndex]
            let lineWidth = lineFrames.last!.maxX - lineFrames.first!.minX
            let free = actualWidth - lineWidth
            let xOffset: CGFloat
            switch alignment {
            case .leading:  xOffset = 0
            case .center:   xOffset = max(0, free / 2)
            case .trailing: xOffset = max(0, free)
            }

            for (idx, frame) in zip(lineStartIndex...lineEndIndex, lineFrames) {
                let adjusted = frame.offsetBy(dx: xOffset, dy: 0)
                subviews[idx].place(at: CGPoint(x: bounds.minX + adjusted.minX,
                                                y: bounds.minY + adjusted.minY),
                                    proposal: .unspecified)
            }

            lineStartIndex = lineEndIndex + 1
        }
    }

    private func layoutFrames(for subviews: Subviews,
                              inWidth containerWidth: CGFloat,
                              proposal: ProposedViewSize) -> (frames: [CGRect], size: CGSize) {
        var frames: [CGRect] = []
        var cursorX: CGFloat = 0
        var cursorY: CGFloat = 0
        var lineHeight: CGFloat = 0

        func newLine() {
            cursorX = 0
            cursorY += lineHeight + rowSpacing
            lineHeight = 0
        }

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            let viewSize = CGSize(width: min(size.width, containerWidth), height: size.height)

            if cursorX > 0, cursorX + viewSize.width > containerWidth {
                newLine()
            }

            let frame = CGRect(x: cursorX, y: cursorY, width: viewSize.width, height: viewSize.height)
            frames.append(frame)

            cursorX += viewSize.width
            if subview != subviews.last {
                cursorX += spacing
            }
            lineHeight = max(lineHeight, viewSize.height)
        }

        let totalHeight = cursorY + lineHeight
        let totalWidth = containerWidth.isFinite ? containerWidth : (frames.last?.maxX ?? 0)
        return (frames, CGSize(width: totalWidth, height: totalHeight))
    }
}

struct FlowLayoutDemo: View {
    @State private var alignIndex: Int = 0
    private let alignments: [FlowLayout.HorizontalAlignment] = [.leading, .center, .trailing]

    private let tags: [String] = [
        "SwiftUI", "AttributeGraph", "DisplayList", "Transactions",
        "Layout Protocol", "FlowLayout", "ZStack", "HStack", "VStack",
        "Observation", "Preview", "GeometryReader", "AnyLayout", "ViewThatFits"
    ]

    var body: some View {
        VStack(spacing: 16) {
//            header

            FlowLayout(spacing: 8,
                       rowSpacing: 10,
                       alignment: alignments[alignIndex],
                       maxRowWidth: nil) {
//                ForEach(tags, id: \.self) { tag in
//                    TagChip(text: tag)
//                }
                TagChip(text: tags[0])
                TagChip(text: tags[1])
            }
            .padding()
//            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16))

//            GroupBox("Fixed width container (320)") {
//                FlowLayout(spacing: 8, rowSpacing: 8, alignment: .center, maxRowWidth: 320) {
//                    ForEach(tags, id: \.self) { TagChip(text: $0) }
//                }
//                .padding(.vertical, 8)
//            }
        }
        .padding()
        .animation(.snappy, value: alignIndex)
    }

//    private var header: some View {
//        HStack {
//            Text("FlowLayout Demo")
//                .font(.title2).bold()
//
//            Spacer()
//
//            Picker("Alignment", selection: $alignIndex) {
//                Text("Leading").tag(0)
//                Text("Center").tag(1)
//                Text("Trailing").tag(2)
//            }
//            .pickerStyle(.segmented)
//            .frame(maxWidth: 280)
//        }
//    }
}

private struct TagChip: View {
    let text: String
    var body: some View {
//        Text(text)
//            .font(.callout)
//            .padding(.horizontal, 12)
//            .padding(.vertical, 6)
//            .background(Color.accentColor.opacity(0.12), in: Capsule())
//            .overlay {
//                Capsule().strokeBorder(Color.accentColor.opacity(0.35))
//            }
        Color.red
    }
}
