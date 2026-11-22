//
//  PathExample.swift
//  Shared

import Foundation
#if OPENSWIFTUI
import OpenSwiftUI
#else
import SwiftUI
#endif

struct PathTrimExample: View {
    enum RangeKind: String, CaseIterable {
        case full
        case threeQuarters
        case leftLobe

        var fractions: (start: CGFloat, end: CGFloat) {
            switch self {
            case .full: (0.0, 1.0)
            case .threeQuarters: (0.25, 1.0)
            case .leftLobe: (0.0, 0.5)
            }
        }
    }

    var range: RangeKind = .threeQuarters

    var body: some View {
        let fractions = range.fractions
        Path { path in
            path.addLines([
                .init(x: 2, y: 1),
                .init(x: 1, y: 0),
                .init(x: 0, y: 1),
                .init(x: 1, y: 2),
                .init(x: 3, y: 0),
                .init(x: 4, y: 1),
                .init(x: 3, y: 2),
                .init(x: 2, y: 1),
            ])
        }
        .applying(CGAffineTransform(translationX: 20, y: 60).scaledBy(x: 40, y: 40))
        .trim(from: fractions.start, to: fractions.end)
        .stroke(Color.primary, lineWidth: 3)
        .frame(width: 200, height: 200)
    }
}

struct PathArcSectorExample: View {
    var body: some View {
        Path { path in
            path.move(to: CGPoint(x: 40, y: 40))
            path.addLine(to: CGPoint(x: 160, y: 40))
            path.addArc(
                center: CGPoint(x: 40, y: 40),
                radius: 120,
                startAngle: .zero,
                endAngle: .degrees(90),
                clockwise: false
            )
            path.closeSubpath()
        }
        .fill(.orange)
        .stroke(.red, lineWidth: 4)
        .frame(width: 200, height: 200)
    }
}

struct PathTrapezoidBackgroundExample: View {
    enum StyleKind: String, CaseIterable {
        case explicitTeal
        case defaultBackground
    }

    var styleKind: StyleKind = .explicitTeal

    private var trapezoid: Path {
        Path { path in
            path.move(to: .zero)
            path.addLine(to: CGPoint(x: 90, y: 0))
            path.addLine(to: CGPoint(x: 80, y: 50))
            path.addLine(to: CGPoint(x: 10, y: 50))
            path.closeSubpath()
        }
    }

    private var flagIcon: some View {
        Path { path in
            path.move(to: CGPoint(x: 2, y: 1))
            path.addLine(to: CGPoint(x: 2, y: 15))
            path.move(to: CGPoint(x: 2, y: 2))
            path.addLine(to: CGPoint(x: 14, y: 5))
            path.addLine(to: CGPoint(x: 2, y: 9))
            path.closeSubpath()
        }
        .fill(.primary)
        .stroke(.primary, lineWidth: 1.5)
        .frame(width: 16, height: 16)
    }

    var body: some View {
        switch styleKind {
        case .explicitTeal:
            HStack(spacing: 6) {
                flagIcon
                Text("Flag")
            }
            .frame(width: 90, height: 50)
            .background(.teal, in: trapezoid)
        case .defaultBackground:
            ZStack {
                Color.teal
                HStack(spacing: 6) {
                    flagIcon
                    Text("Flag")
                }
                .frame(width: 90, height: 50)
                .background(in: trapezoid)
            }
            .frame(width: 160, height: 100)
        }
    }
}

struct PathCurvesAndFillRuleExample: View {
    enum Variant: String, CaseIterable {
        case bezierBadge
        case evenOddRings
        case nonZeroRings
        case starFromString
    }

    var variant: Variant = .bezierBadge

    private var concentricRings: Path {
        Path { path in
            path.addEllipse(in: CGRect(x: 30, y: 30, width: 140, height: 140))
            path.addEllipse(in: CGRect(x: 65, y: 65, width: 70, height: 70))
        }
    }

    var body: some View {
        Group {
            switch variant {
            case .bezierBadge:
                Path { path in
                    path.move(to: CGPoint(x: 30, y: 110))
                    path.addQuadCurve(
                        to: CGPoint(x: 170, y: 110),
                        control: CGPoint(x: 100, y: 20)
                    )
                    path.addCurve(
                        to: CGPoint(x: 30, y: 110),
                        control1: CGPoint(x: 150, y: 185),
                        control2: CGPoint(x: 50, y: 185)
                    )
                    path.closeSubpath()
                }
                .fill(.indigo)
                .stroke(.cyan, lineWidth: 4)
            case .evenOddRings:
                concentricRings
                    .fill(.teal, style: FillStyle(eoFill: true))
            case .nonZeroRings:
                concentricRings
                    .fill(.teal, style: FillStyle(eoFill: false))
            case .starFromString:
                (Path("100 25 m 123 165 l 30 78 l 170 78 l 77 165 l h") ?? Path())
                    .fill(.purple, style: FillStyle(eoFill: true))
            }
        }
        .frame(width: 200, height: 200)
    }
}

struct PathBooleanExample: View {
    enum Operation: String, CaseIterable {
        case union
        case intersection
        case subtracting
        case symmetricDifference
        case lineIntersection
        case lineSubtraction
    }

    var operation: Operation = .symmetricDifference

    private var circlePath: Path {
        Path(ellipseIn: CGRect(x: 25, y: 45, width: 110, height: 110))
    }

    private var roundedRectPath: Path {
        Path(roundedRect: CGRect(x: 65, y: 45, width: 110, height: 110), cornerRadius: 24)
    }

    private var stripeLines: Path {
        Path { path in
            for y in stride(from: 45.0, through: 155.0, by: 18.0) {
                path.move(to: CGPoint(x: 20, y: y))
                path.addLine(to: CGPoint(x: 180, y: y))
            }
        }
    }

    var body: some View {
        Group {
            switch operation {
            case .union:
                circlePath.union(roundedRectPath)
                    .fill(.blue)
            case .intersection:
                circlePath.intersection(roundedRectPath)
                    .fill(.green)
            case .subtracting:
                circlePath.subtracting(roundedRectPath)
                    .fill(.orange)
            case .symmetricDifference:
                circlePath.symmetricDifference(roundedRectPath)
                    .fill(.pink)
            case .lineIntersection:
                stripeLines.lineIntersection(circlePath)
                    .stroke(.teal, style: StrokeStyle(lineWidth: 4, lineCap: .round))
            case .lineSubtraction:
                stripeLines.lineSubtraction(circlePath)
                    .stroke(.indigo, style: StrokeStyle(lineWidth: 4, lineCap: .round))
            }
        }
        .frame(width: 200, height: 200)
    }
}

#Preview("Trim Infinity") {
    VStack {
        PathTrimExample(range: .threeQuarters)
        PathTrimExample(range: .leftLobe)
    }
}

#Preview("Arc Sector") {
    PathArcSectorExample()
}

#Preview("Trapezoid Background") {
    VStack(spacing: 16) {
        PathTrapezoidBackgroundExample(styleKind: .explicitTeal)
        PathTrapezoidBackgroundExample(styleKind: .defaultBackground)
    }
    .padding()
}

#Preview("Curves & Fill Rules") {
    VStack {
        HStack {
            PathCurvesAndFillRuleExample(variant: .bezierBadge)
            PathCurvesAndFillRuleExample(variant: .starFromString)
        }
        HStack {
            PathCurvesAndFillRuleExample(variant: .evenOddRings)
            PathCurvesAndFillRuleExample(variant: .nonZeroRings)
        }
    }
}

#Preview("Boolean Operations") {
    VStack {
        HStack {
            PathBooleanExample(operation: .union)
            PathBooleanExample(operation: .intersection)
        }
        HStack {
            PathBooleanExample(operation: .subtracting)
            PathBooleanExample(operation: .symmetricDifference)
        }
        HStack {
            PathBooleanExample(operation: .lineIntersection)
            PathBooleanExample(operation: .lineSubtraction)
        }
    }
}
