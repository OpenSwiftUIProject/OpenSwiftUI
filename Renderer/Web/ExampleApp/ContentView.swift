#if os(WASI) && !OPENSWIFTUI_SWIFTUI_RENDERER
@_spi(WebRenderer) import OpenSwiftUI

struct ContentView: View {
    @State private var tapCount = 0
    @State private var doubleTapCount = 0
    @State private var gestureTapCount = 0

    var body: some View {
        ZStack {
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [Color(red: 0.06, green: 0.12, blue: 0.23), .black],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            VStack(spacing: 14) {
                VStack(spacing: 4) {
                    Text("SwiftUI on the Web")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(.white)
                    JavaScriptReader(resolve: BrowserHostInfo.current) { host in
                        Text("Host: \(host.displayName)")
                            .font(.system(size: 15))
                            .foregroundStyle(.cyan)
                    }
                }

                HStack(spacing: 24) {
                    VStack(alignment: .leading, spacing: 12) {
                        Button("A") {
                            print("A")
                        }
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(.white)
                        ControlSamples()
                    }
                    .frame(width: 300)

                    GradientSamples()
                }
                TextStyleSamples()
            }
            .padding(20)
        }
    }
}

private struct ControlSamples: View {
    @State private var isSliderEnabled = true
    @State private var level = 25.0
    @State private var isEditing = false
    @State private var quantity = 2

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Toggle(isOn: $isSliderEnabled) {
                Text("Enable slider")
            }
            Slider(value: $level, in: 0...100, step: 5) {
                Text("Level: \(Int(level))")
            } minimumValueLabel: {
                Text("0")
            } maximumValueLabel: {
                Text("100")
            } onEditingChanged: { editing in
                isEditing = editing
            }
            .disabled(!isSliderEnabled)

            Text(isSliderEnabled ? (isEditing ? "Editing" : "Idle") : "Slider disabled")
                .foregroundStyle(isEditing ? Color.cyan : .gray)

            Stepper(value: $quantity, in: 0...5) {
                Text("Quantity: \(quantity)")
            }
        }
        .foregroundStyle(Color.white)
    }
}

private struct GradientSamples: View {
    private let spectrum: [Color] = [.pink, .orange, .yellow, .green, .cyan, .blue, .purple]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Gradients")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(.white)

            HStack(spacing: 10) {
                GradientTile(name: "Linear", style: LinearGradient(
                    colors: spectrum, startPoint: .topLeading, endPoint: .bottomTrailing
                ))
                GradientTile(name: "Radial", style: RadialGradient(
                    colors: spectrum, center: .center, startRadius: 0, endRadius: 70
                ))
            }
            HStack(spacing: 10) {
                GradientTile(name: "Elliptical", style: EllipticalGradient(
                    colors: spectrum, center: .center, startRadiusFraction: 0, endRadiusFraction: 0.6
                ))
                GradientTile(name: "Angular", style: AngularGradient(
                    colors: spectrum, center: .center, startAngle: .degrees(-45), endAngle: .degrees(225)
                ))
            }
            GradientTile(name: "Conic", style: AngularGradient(
                colors: spectrum + [.pink], center: .center, angle: .degrees(-45)
            ), isWide: true)
        }
    }
}

private struct GradientTile<Style: ShapeStyle>: View {
    var name: String
    var style: Style
    var isWide = false

    var body: some View {
        VStack(spacing: 3) {
            RoundedRectangle(cornerRadius: 10, style: .circular)
                .fill(style)
                .frame(width: isWide ? 282 : 136, height: 60)
            Text(verbatim: name)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(Color.white.opacity(0.85))
        }
    }
}

private struct TextStyleSamples: View {
    var body: some View {
        HStack(spacing: 20.0) {
            Text("Red Light")
                .fontWeight(.light)
                .foregroundStyle(.red)
            Text("Yellow Medium")
                .fontWeight(.medium)
                .foregroundStyle(.yellow)
            Text("Blue Heavy")
                .fontWeight(.heavy)
                .foregroundStyle(.blue)
            Text("Purple Black")
                .fontWeight(.black)
                .foregroundStyle(.purple)
        }
        .font(.system(size: 18.0))
    }
}
#endif
