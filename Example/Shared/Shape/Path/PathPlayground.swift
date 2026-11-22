//
//  PathPlayground.swift
//  Shared

import Foundation
#if OPENSWIFTUI
import OpenSwiftUI
#else
import SwiftUI
#endif

struct PathPlayground: View {
    private var frameworkName: String {
        #if OPENSWIFTUI
        "OpenSwiftUI"
        #else
        "SwiftUI"
        #endif
    }

    var body: some View {
        ZStack {
            Color(red: 0.06, green: 0.07, blue: 0.12)
                .ignoresSafeArea()

            VStack(spacing: 12) {
                headerBar

                VStack(spacing: 10) {
                    HStack(spacing: 10) {
                        ShowcaseCard(title: "Bezier & forEach", subtitle: "addCurve · quadCurve") {
                            BezierInspectorArtwork()
                        }
                        ShowcaseCard(title: "Boolean CSG", subtitle: "xor · intersect · union") {
                            BooleanCSGArtwork()
                        }
                    }

                    HStack(spacing: 10) {
                        ShowcaseCard(title: "Line Clip & Hit-Test", subtitle: "lineIntersection · contains") {
                            LineClipAndContainsArtwork()
                        }
                        ShowcaseCard(title: "Trim, Arcs & Dashes", subtitle: "trim · StrokeStyle · applying") {
                            TrimAndDashesArtwork()
                        }
                    }

                    HStack(spacing: 10) {
                        ShowcaseCard(title: "String & Winding", subtitle: "Path(String) · eoFill") {
                            StringAndEvenOddArtwork()
                        }
                        ShowcaseCard(title: "Inset & Borders", subtitle: "strokeBorder · background(in:)") {
                            InsetAndBorderArtwork()
                        }
                    }
                }

                footerStrip
            }
            .padding(16)
        }
    }

    private var headerBar: some View {
        HStack(spacing: 10) {
            PathBrandEmblem()
                .frame(width: 34, height: 34)

            VStack(alignment: .leading, spacing: 2) {
                Text("Path & Shape")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(.white)
                Text("Complete API & Rendering Parity")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(.white.opacity(0.65))
            }

            Spacer()

            Text(frameworkName)
                .font(.system(size: 11, weight: .semibold, design: .monospaced))
                .foregroundStyle(.cyan)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(.cyan.opacity(0.15), in: Capsule(style: .continuous))
                .overlay {
                    Capsule(style: .continuous)
                        .strokeBorder(.cyan.opacity(0.5), lineWidth: 1)
                }
        }
        .frame(width: 350)
    }

    private var footerStrip: some View {
        Text("Curves · Arcs · Trim · Dashes · CSG · eoFill · String · Cross-Platform")
            .font(.system(size: 9.5, weight: .medium, design: .monospaced))
            .foregroundStyle(.white.opacity(0.5))
            .frame(width: 350)
    }
}

// MARK: - Card Container

private struct ShowcaseCard<Content: View>: View {
    let title: String
    let subtitle: String
    @ViewBuilder let content: () -> Content

    private let cardShape = RoundedRectangle(cornerRadius: 16, style: .continuous)

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            content()
                .frame(width: 150, height: 96)

            Text(title)
                .font(.system(size: 11.5, weight: .semibold))
                .foregroundStyle(.white)

            Text(subtitle)
                .font(.system(size: 9.5, weight: .regular, design: .monospaced))
                .foregroundStyle(.white.opacity(0.55))
        }
        .padding(10)
        .frame(width: 170, height: 148)
        .background(Color(red: 0.11, green: 0.13, blue: 0.20), in: cardShape)
        .overlay {
            cardShape
                .strokeBorder(.white.opacity(0.12), lineWidth: 1)
        }
    }
}

// MARK: - Header Emblem

private struct PathBrandEmblem: View {
    private let tile = RoundedRectangle(cornerRadius: 9, style: .continuous)

    private var spline: Path {
        Path { p in
            p.move(to: CGPoint(x: 8, y: 25))
            p.addCurve(
                to: CGPoint(x: 26, y: 9),
                control1: CGPoint(x: 8, y: 11),
                control2: CGPoint(x: 26, y: 23)
            )
        }
    }

    private var nodes: Path {
        Path { p in
            p.addEllipse(in: CGRect(x: 5.5, y: 22.5, width: 5, height: 5))
            p.addEllipse(in: CGRect(x: 23.5, y: 6.5, width: 5, height: 5))
        }
    }

    var body: some View {
        ZStack {
            tile.fill(
                LinearGradient(
                    colors: [.cyan, .blue, .indigo],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            tile.strokeBorder(.white.opacity(0.35), lineWidth: 1)
            spline.stroke(.white, style: StrokeStyle(lineWidth: 2.4, lineCap: .round))
            nodes.fill(.white)
        }
    }
}

// MARK: - 1. Bezier & Element Iteration

private struct BezierInspectorArtwork: View {
    private var spline: Path {
        Path { p in
            p.move(to: CGPoint(x: 16, y: 72))
            p.addCurve(
                to: CGPoint(x: 88, y: 38),
                control1: CGPoint(x: 32, y: 12),
                control2: CGPoint(x: 62, y: 84)
            )
            p.addQuadCurve(
                to: CGPoint(x: 134, y: 24),
                control: CGPoint(x: 112, y: 8)
            )
        }
    }

    private var ribbonFill: Path {
        var p = spline
        p.addLine(to: CGPoint(x: 134, y: 84))
        p.addCurve(
            to: CGPoint(x: 16, y: 84),
            control1: CGPoint(x: 96, y: 68),
            control2: CGPoint(x: 52, y: 90)
        )
        p.closeSubpath()
        return p
    }

    private var echoWave: Path {
        spline.applying(CGAffineTransform(translationX: 0, y: 10))
    }

    private var inspectionOverlay: (handles: Path, controls: Path, anchors: Path) {
        var handles = Path()
        var controls = Path()
        var anchors = Path()
        var current = CGPoint.zero

        func addDot(_ point: CGPoint, radius: CGFloat, into target: inout Path) {
            target.addEllipse(
                in: CGRect(
                    x: point.x - radius,
                    y: point.y - radius,
                    width: radius * 2,
                    height: radius * 2
                )
            )
        }

        spline.forEach { element in
            switch element {
            case let .move(to: end):
                current = end
                addDot(end, radius: 3.2, into: &anchors)
            case let .line(to: end):
                current = end
                addDot(end, radius: 3.2, into: &anchors)
            case let .quadCurve(to: end, control: c):
                handles.move(to: current)
                handles.addLine(to: c)
                handles.addLine(to: end)
                addDot(c, radius: 2.8, into: &controls)
                addDot(end, radius: 3.2, into: &anchors)
                current = end
            case let .curve(to: end, control1: c1, control2: c2):
                handles.move(to: current)
                handles.addLine(to: c1)
                handles.move(to: end)
                handles.addLine(to: c2)
                addDot(c1, radius: 2.8, into: &controls)
                addDot(c2, radius: 2.8, into: &controls)
                addDot(end, radius: 3.2, into: &anchors)
                current = end
            case .closeSubpath:
                break
            }
        }
        return (handles, controls, anchors)
    }

    var body: some View {
        let overlay = inspectionOverlay
        ZStack {
            ribbonFill.fill(.cyan.opacity(0.22))
            echoWave.stroke(
                .indigo.opacity(0.75),
                style: StrokeStyle(lineWidth: 1.8, lineCap: .round)
            )
            overlay.handles.stroke(
                .white.opacity(0.45),
                style: StrokeStyle(lineWidth: 1, lineCap: .round, dash: [3, 3])
            )
            spline.stroke(
                .cyan,
                style: StrokeStyle(lineWidth: 3.2, lineCap: .round)
            )
            overlay.controls.fill(.orange)
            overlay.anchors.fill(.white)
        }
    }
}

// MARK: - 2. Boolean CSG

private struct BooleanCSGArtwork: View {
    private var leftCircle: Path {
        Path(ellipseIn: CGRect(x: 24, y: 10, width: 64, height: 64))
    }

    private var rightCircle: Path {
        Path(ellipseIn: CGRect(x: 62, y: 10, width: 64, height: 64))
    }

    private var lowerRoundedRect: Path {
        Path(
            roundedRect: CGRect(x: 43, y: 32, width: 64, height: 54),
            cornerRadius: 16,
            style: .continuous
        )
    }

    var body: some View {
        let xorFill = leftCircle
            .symmetricDifference(rightCircle)
            .symmetricDifference(lowerRoundedRect)
        let pairwiseLens = leftCircle
            .intersection(rightCircle)
            .subtracting(lowerRoundedRect)
        let tripleCore = leftCircle
            .intersection(rightCircle)
            .intersection(lowerRoundedRect)
        let unionContour = leftCircle
            .union(rightCircle)
            .union(lowerRoundedRect)

        ZStack {
            xorFill.fill(.orange.opacity(0.85))
            pairwiseLens.fill(.pink.opacity(0.65))
            tripleCore.fill(.yellow)
            unionContour.stroke(.white.opacity(0.8), lineWidth: 1.4)
        }
    }
}

// MARK: - 3. Line Clipping & Point Containment

private struct LineClipAndContainsArtwork: View {
    private var targetRegion: Path {
        let outer = Path(
            roundedRect: CGRect(x: 26, y: 10, width: 98, height: 76),
            cornerRadii: .init(topLeading: 26, bottomLeading: 10, bottomTrailing: 26, topTrailing: 10),
            style: .continuous
        )
        let hole = Path(ellipseIn: CGRect(x: 56, y: 29, width: 38, height: 38))
        return outer.subtracting(hole)
    }

    private var hatchLines: Path {
        let raw = Path { p in
            for x in stride(from: -36.0, through: 138.0, by: 9.0) {
                p.move(to: CGPoint(x: x, y: 88))
                p.addLine(to: CGPoint(x: x + 52, y: 8))
            }
        }
        let bounds = Path(CGRect(x: 12, y: 8, width: 126, height: 80))
        return raw.lineIntersection(bounds)
    }

    private var probePoints: (inside: Path, outside: Path) {
        let region = targetRegion
        var inside = Path()
        var outside = Path()
        for x in stride(from: 18.0, through: 132.0, by: 19.0) {
            let pt = CGPoint(x: x, y: 48)
            let dot = CGRect(x: pt.x - 2.6, y: pt.y - 2.6, width: 5.2, height: 5.2)
            if region.contains(pt) {
                inside.addEllipse(in: dot)
            } else {
                outside.addEllipse(in: dot)
            }
        }
        return (inside, outside)
    }

    var body: some View {
        let region = targetRegion
        let hatch = hatchLines
        let probes = probePoints

        ZStack {
            hatch.lineSubtraction(region)
                .stroke(.indigo.opacity(0.45), style: StrokeStyle(lineWidth: 1.4, lineCap: .round))

            hatch.lineIntersection(region)
                .stroke(.mint, style: StrokeStyle(lineWidth: 2.6, lineCap: .round))

            region.stroke(.cyan.opacity(0.45), lineWidth: 1.1)
            probes.outside.fill(.white.opacity(0.35))
            probes.inside.fill(.yellow)
        }
    }
}

// MARK: - 4. Trim, Arcs & Dashes

private struct TrimAndDashesArtwork: View {
    private var outerGauge: Path {
        Path { p in
            p.addArc(
                center: CGPoint(x: 75, y: 50),
                radius: 38,
                startAngle: .degrees(135),
                endAngle: .degrees(45),
                clockwise: false
            )
        }
    }

    private var middleOrbit: Path {
        Path { p in
            p.addArc(
                center: CGPoint(x: 75, y: 50),
                radius: 27,
                startAngle: .degrees(135),
                endAngle: .degrees(45),
                clockwise: false
            )
        }
    }

    private var infinityLoop: Path {
        Path { p in
            p.addLines([
                CGPoint(x: 0, y: 0),
                CGPoint(x: -1, y: -0.75),
                CGPoint(x: -1.8, y: 0),
                CGPoint(x: -1, y: 0.75),
                CGPoint(x: 1, y: -0.75),
                CGPoint(x: 1.8, y: 0),
                CGPoint(x: 1, y: 0.75),
                CGPoint(x: 0, y: 0),
            ])
        }
        .applying(CGAffineTransform(translationX: 75, y: 52).scaledBy(x: 10.5, y: 10.5))
    }

    var body: some View {
        ZStack {
            outerGauge.stroke(
                .white.opacity(0.12),
                style: StrokeStyle(lineWidth: 6, lineCap: .round)
            )
            outerGauge
                .trim(from: 0.0, to: 0.28)
                .stroke(.cyan, style: StrokeStyle(lineWidth: 6, lineCap: .round))
            outerGauge
                .trim(from: 0.34, to: 0.62)
                .stroke(.mint, style: StrokeStyle(lineWidth: 6, lineCap: .round))
            outerGauge
                .trim(from: 0.68, to: 0.88)
                .stroke(.orange, style: StrokeStyle(lineWidth: 6, lineCap: .round))

            middleOrbit
                .trim(from: 0.06, to: 0.94)
                .stroke(
                    .purple.opacity(0.9),
                    style: StrokeStyle(lineWidth: 2.4, lineCap: .round, dash: [5, 5])
                )

            infinityLoop
                .trim(from: 0.1, to: 0.92)
                .stroke(
                    .white,
                    style: StrokeStyle(lineWidth: 2.2, lineCap: .round, lineJoin: .round)
                )
        }
    }
}

// MARK: - 5. String Parsing & Even-Odd Winding

private struct StringAndEvenOddArtwork: View {
    private var starPath: Path {
        Path("75 11 m 98 81 l 38 38 l 112 38 l 52 81 l h") ?? Path()
    }

    private var compoundRosette: Path {
        let star = starPath
        return Path { p in
            p.addEllipse(in: CGRect(x: 35, y: 8, width: 80, height: 80))
            p.addPath(star)
            p.addEllipse(in: CGRect(x: 60, y: 33, width: 30, height: 30))
        }
    }

    var body: some View {
        let rosette = compoundRosette
        ZStack {
            rosette.fill(.purple.opacity(0.85), style: FillStyle(eoFill: true))
            starPath.stroke(.cyan.opacity(0.85), style: StrokeStyle(lineWidth: 1.3, lineJoin: .round))
            rosette.stroke(.white.opacity(0.35), lineWidth: 1)
        }
    }
}

// MARK: - 6. Insettable Shapes & Shape Background

private struct ChamferedPill: Shape {
    func path(in rect: CGRect) -> Path {
        let cut = min(rect.height * 0.32, 9)
        return Path { p in
            p.move(to: CGPoint(x: rect.minX + cut, y: rect.minY))
            p.addLine(to: CGPoint(x: rect.maxX - cut, y: rect.minY))
            p.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
            p.addLine(to: CGPoint(x: rect.maxX - cut, y: rect.maxY))
            p.addLine(to: CGPoint(x: rect.minX + cut, y: rect.maxY))
            p.addLine(to: CGPoint(x: rect.minX, y: rect.midY))
            p.closeSubpath()
        }
    }
}

private struct InsetAndBorderArtwork: View {
    private let outerFrame = UnevenRoundedRectangle(
        cornerRadii: .init(topLeading: 24, bottomLeading: 8, bottomTrailing: 24, topTrailing: 8),
        style: .continuous
    )

    var body: some View {
        ZStack {
            outerFrame
                .fill(.teal.opacity(0.16))
                .frame(width: 126, height: 78)

            outerFrame
                .strokeBorder(.teal, lineWidth: 3.5)
                .frame(width: 126, height: 78)

            outerFrame
                .inset(by: 9)
                .strokeBorder(
                    .mint.opacity(0.75),
                    style: StrokeStyle(lineWidth: 1.8, lineCap: .round, dash: [5, 4])
                )
                .frame(width: 126, height: 78)

            Text("1:1 PARITY")
                .font(.system(size: 10, weight: .bold, design: .monospaced))
                .foregroundStyle(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(.teal.opacity(0.45), in: ChamferedPill())
                .overlay {
                    ChamferedPill()
                        .stroke(.cyan.opacity(0.8), lineWidth: 1.2)
                }
        }
    }
}

#Preview {
    PathPlayground()
}
