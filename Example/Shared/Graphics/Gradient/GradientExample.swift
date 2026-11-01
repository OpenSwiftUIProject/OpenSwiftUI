//
//  GradientExample.swift
//  Shared

#if OPENSWIFTUI
import OpenSwiftUI
#else
import SwiftUI
#endif

struct GradientExample: View {
    enum Kind: String, CaseIterable {
        case linear
        case radial
        case elliptical
        case angular
        case conic
    }

    enum Palette: String {
        case colors
        case stops
        case transparent
        case single
        case empty
    }

    var kind: Kind = .linear
    var palette: Palette = .colors
    var usesAnyGradient = false
    var colorSpace: Gradient.ColorSpace = .perceptual
    var alternate = false

    private var gradient: Gradient {
        let red = Color(red: 1, green: 0, blue: 0)
        let green = Color(red: 0, green: 1, blue: 0)
        let blue = Color(red: 0, green: 0, blue: 1)
        let colors = alternate ? [blue, green, red] : [red, green, blue]
        switch palette {
        case .colors:
            return Gradient(colors: colors)
        case .stops:
            return Gradient(stops: [
                .init(color: colors[0], location: 0),
                .init(color: colors[1], location: 0.35),
                .init(color: colors[2], location: 0.35),
                .init(color: colors[0], location: 1),
            ])
        case .transparent:
            return Gradient(stops: [
                .init(color: colors[0].opacity(0), location: 0),
                .init(color: colors[1].opacity(0.5), location: 0.4),
                .init(color: colors[2], location: 1),
            ])
        case .single:
            return Gradient(colors: [colors[0].opacity(0.5)])
        case .empty:
            return Gradient(colors: [])
        }
    }

    private var startPoint: UnitPoint { alternate ? .bottomLeading : .topLeading }
    private var endPoint: UnitPoint { alternate ? .topTrailing : .bottomTrailing }
    private var center: UnitPoint { alternate ? UnitPoint(x: 0.7, y: 0.6) : UnitPoint(x: 0.3, y: 0.4) }
    private var endRadius: CGFloat { alternate ? 60 : 110 }
    private var endRadiusFraction: CGFloat { alternate ? 0.4 : 0.7 }
    private var startAngle: Angle { .degrees(alternate ? 45 : -45) }
    private var endAngle: Angle { .degrees(alternate ? 225 : 270) }

    var body: some View {
        Group {
            if usesAnyGradient {
                erasedContent
            } else {
                concreteContent
            }
        }
        .frame(width: 160, height: 120)
        .background(Color(white: 0.9))
    }

    @ViewBuilder
    private var concreteContent: some View {
        switch kind {
        case .linear:
            Rectangle().fill(LinearGradient(gradient: gradient, startPoint: startPoint, endPoint: endPoint))
        case .radial:
            Rectangle().fill(RadialGradient(gradient: gradient, center: center, startRadius: 10, endRadius: endRadius))
        case .elliptical:
            Rectangle().fill(EllipticalGradient(gradient: gradient, center: center, startRadiusFraction: 0.1, endRadiusFraction: endRadiusFraction))
        case .angular:
            Rectangle().fill(AngularGradient(gradient: gradient, center: center, startAngle: startAngle, endAngle: endAngle))
        case .conic:
            Rectangle().fill(AngularGradient(gradient: gradient, center: center, angle: startAngle))
        }
    }

    @ViewBuilder
    private var erasedContent: some View {
        let gradient = gradient.colorSpace(colorSpace)
        switch kind {
        case .linear:
            Rectangle().fill(.linearGradient(gradient, startPoint: startPoint, endPoint: endPoint))
        case .radial:
            Rectangle().fill(.radialGradient(gradient, center: center, startRadius: 10, endRadius: endRadius))
        case .elliptical:
            Rectangle().fill(.ellipticalGradient(gradient, center: center, startRadiusFraction: 0.1, endRadiusFraction: endRadiusFraction))
        case .angular:
            Rectangle().fill(.angularGradient(gradient, center: center, startAngle: startAngle, endAngle: endAngle))
        case .conic:
            Rectangle().fill(.conicGradient(gradient, center: center, angle: startAngle))
        }
    }
}

struct GradientAnimationExample: View {
    var kind: GradientExample.Kind = .linear
    @State private var alternate = false

    var body: some View {
        GradientExample(kind: kind, alternate: alternate)
            .animation(.easeInOut(duration: 1), value: alternate)
            .onTapGesture { alternate.toggle() }
    }
}

struct GradientShowcaseExample: View {
    var body: some View {
        ZStack {
            Color(red: 0.05, green: 0.05, blue: 0.08)
                .ignoresSafeArea()
            VStack(spacing: 28) {
                VStack(spacing: 6) {
                    Text("OpenSwiftUI 0.25.0")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundStyle(Color.white)
                    Text("Gradients")
                        .font(.system(size: 17, weight: .medium))
                        .foregroundStyle(Color(white: 1, opacity: 0.6))
                }
                VStack(spacing: 18) {
                    HStack(spacing: 14) {
                        GradientTile(name: "Linear", style: GradientShowcase.linear)
                        GradientTile(name: "Radial", style: GradientShowcase.radial)
                    }
                    HStack(spacing: 14) {
                        GradientTile(name: "Elliptical", style: GradientShowcase.elliptical)
                        GradientTile(name: "Angular", style: GradientShowcase.angular)
                    }
                }
                Capsule()
                    .fill(.linearGradient(
                        colors: GradientShowcase.spectrum,
                        startPoint: .leading,
                        endPoint: .trailing
                    ))
                    .frame(height: 10)
            }
            .padding(20)
        }
    }
}

private struct GradientTile<Style: ShapeStyle>: View {
    var name: String
    var style: Style

    var body: some View {
        VStack(spacing: 8) {
            RoundedRectangle(cornerRadius: 16)
                .fill(style)
                .frame(width: 200, height: 144)
            Text(name)
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(Color(white: 1, opacity: 0.85))
        }
    }
}

private enum GradientShowcase {
    static var spectrum: [Color] {
        [.pink, .orange, .yellow, .green, .cyan, .blue, .purple, .pink]
    }

    static var linear: LinearGradient {
        LinearGradient(colors: spectrum, startPoint: .topLeading, endPoint: .bottomTrailing)
    }

    static var radial: RadialGradient {
        RadialGradient(colors: spectrum, center: .center, startRadius: 0, endRadius: 120)
    }

    static var elliptical: EllipticalGradient {
        EllipticalGradient(colors: spectrum, center: .center, startRadiusFraction: 0, endRadiusFraction: 0.7)
    }

    static var angular: AngularGradient {
        AngularGradient(colors: spectrum, center: .center)
    }
}

#Preview("Linear") {
    GradientExample()
}

#Preview("Radial") {
    GradientExample(kind: .radial)
}

#Preview("Elliptical") {
    GradientExample(kind: .elliptical)
}

#Preview("Angular") {
    GradientExample(kind: .angular)
}

#Preview("Conic") {
    GradientExample(kind: .conic)
}

#Preview("Repeated Stops") {
    GradientExample(palette: .stops)
}

#Preview("Transparency") {
    GradientExample(palette: .transparent)
}

#Preview("Device Color Space") {
    GradientExample(usesAnyGradient: true, colorSpace: .device)
}

#Preview("Perceptual Color Space") {
    GradientExample(usesAnyGradient: true, colorSpace: .perceptual)
}

#Preview("Tap to Animate") {
    GradientAnimationExample()
}

#Preview("Showcase") {
    GradientShowcaseExample()
}
