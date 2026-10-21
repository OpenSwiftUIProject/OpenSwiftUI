import Foundation
package import OpenSwiftUI

package struct ContentView: View {
    package init() {}

    package var body: some View {
        if ProcessInfo.processInfo.environment["OPENSWIFTUI_DEMO"] == "static" {
            VStack(spacing: 10) {
                Color.red
                Color.blue
            }
            .frame(width: 320, height: 480)
        } else if ProcessInfo.processInfo.environment["OPENSWIFTUI_DEMO"] == "text" {
            TextExamples()
        } else if ProcessInfo.processInfo.environment["OPENSWIFTUI_DEMO"] == "breathing" {
            BreathingColorView()
        } else {
            KineticStudio()
        }
    }
}

private enum StudioInk {
    static let paper = Color(red: 0.95, green: 0.96, blue: 0.95)
    static let primary = Color(red: 0.08, green: 0.09, blue: 0.09)
    static let secondary = Color(red: 0.40, green: 0.43, blue: 0.42)
    static let line = Color(red: 0.82, green: 0.85, blue: 0.83)
    static let lime = Color(red: 0.82, green: 0.95, blue: 0.36)

    static func colors(_ palette: Int) -> [Color] {
        switch palette {
        case 1:
            [Color(red: 1, green: 0.35, blue: 0.28),
             Color(red: 1, green: 0.68, blue: 0.53),
             Color(red: 0.87, green: 0.91, blue: 0.69)]
        case 2:
            [Color(red: 0.34, green: 0.75, blue: 0.98),
             Color(red: 0.51, green: 0.48, blue: 0.94),
             Color(red: 0.86, green: 0.92, blue: 0.98)]
        default:
            [lime, Color(red: 0.36, green: 0.76, blue: 0.65),
             Color(red: 0.34, green: 0.49, blue: 1)]
        }
    }
}

private struct KineticStudio: View {
    @State private var study = 0
    @State private var palette = 0
    @State private var speedIndex = 1
    @State private var playing = true
    @State private var echo = true
    @State private var seed = 0
    @State private var elapsed = 0.0
    @State private var anchor = Date()

    private let speeds = [0.5, 1.0, 1.5, 2.0]
    private let studies = ["Flow", "Cascade", "Lattice"]
    private let palettes = ["Botanic", "Ember", "Iris"]

    private func phase(at date: Date) -> Double {
        elapsed + (playing ? date.timeIntervalSince(anchor) * speeds[speedIndex] : 0)
    }

    // Keep the current phase when pausing or changing tempo.
    private func checkpoint() {
        let now = Date()
        elapsed = phase(at: now)
        anchor = now
    }

    private var playback: Binding<Bool> {
        Binding(get: { playing }, set: { value in
            checkpoint()
            playing = value
        })
    }

    var body: some View {
        GeometryReader { geometry in
            let compact = geometry.size.width < 760
            let padding: CGFloat = compact ? 20 : 32
            ZStack(alignment: .topLeading) {
                StudioInk.paper
                VStack(alignment: .leading, spacing: compact ? 16 : 28) {
                    header(compact: compact)
                    if compact {
                        stage(height: min(310, max(180, geometry.size.height - 410)))
                        controls(compact: true)
                    } else {
                        HStack(alignment: .top, spacing: 32) {
                            stage(height: 470)
                            controls(compact: false).frame(width: 232)
                        }
                    }
                    footer
                }
                .padding(padding)
                .frame(width: geometry.size.width, alignment: .topLeading)
            }
        }
        .foregroundColor(StudioInk.primary)
        .onAppear {
            guard let value = ProcessInfo.processInfo.environment["OPENSWIFTUI_DEMO_TOGGLE_DELAY"],
                  let delay = Double(value), delay.isFinite, delay >= 0 else { return }
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) { palette = 1 }
        }
    }

    private func header(compact: Bool) -> some View {
        HStack(alignment: .center, spacing: 12) {
            VStack(spacing: 4) {
                HStack(spacing: 4) {
                    StudioInk.primary
                    StudioInk.colors(palette)[0]
                }
                HStack(spacing: 4) {
                    StudioInk.colors(palette)[1]
                    StudioInk.colors(palette)[2]
                }
            }
            .frame(width: 34, height: 34)
            VStack(alignment: .leading, spacing: 3) {
                Text(verbatim: "OpenSwiftUI")
                    .font(.system(size: compact ? 25 : 29))
                    .fontWeight(.bold)
                Text(verbatim: "Kinetic Studio")
                    .font(.system(size: 13))
                    .foregroundColor(StudioInk.secondary)
            }
            Spacer(minLength: 0)
            if !compact {
                VStack(alignment: .trailing, spacing: 4) {
                    Text(verbatim: "MOTION STUDIES")
                        .font(.system(size: 11))
                        .fontWeight(.semibold)
                    Text(verbatim: "Collection 001")
                        .font(.system(size: 13))
                        .foregroundColor(StudioInk.secondary)
                }
            }
        }
        .frame(height: 52)
    }

    private func stage(height: CGFloat) -> some View {
        TimelineView(.animation) { timeline in
            StudioStage(
                study: study, palette: palette, seed: seed,
                time: phase(at: timeline.date), playing: playing, echo: echo
            )
        }
        .frame(height: height)
    }

    private func controls(compact: Bool) -> some View {
        VStack(alignment: .leading, spacing: compact ? 12 : 22) {
            if !compact {
                VStack(alignment: .leading, spacing: 5) {
                    Text(verbatim: "Find your rhythm.")
                        .font(.system(size: 24))
                        .fontWeight(.semibold)
                    Text(verbatim: String(format: "COMPOSITION %02d", seed + 1))
                        .font(.system(size: 11))
                        .foregroundColor(StudioInk.secondary)
                }
            }
            VStack(alignment: .leading, spacing: 10) {
                sectionLabel("Study", value: String(format: "%02d", study + 1))
                HStack(spacing: 3) {
                    ForEach(0..<3) { index in
                        Button { study = index } label: {
                            Text(verbatim: studies[index])
                                .font(.system(size: 12))
                                .fontWeight(.semibold)
                                .foregroundColor(study == index ? .white : StudioInk.secondary)
                                .frame(maxWidth: .infinity)
                                .frame(height: 36)
                                .background { study == index ? StudioInk.primary : StudioInk.paper }
                                .cornerRadius(5)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(3)
                .background { StudioInk.line }
                .cornerRadius(7)
            }
            if compact {
                HStack(alignment: .top, spacing: 16) {
                    paletteControl
                    tempoControl(compact: true)
                }
            } else {
                paletteControl
                tempoControl(compact: false)
            }
            if compact {
                HStack(spacing: 16) {
                    motionToggle
                    echoToggle
                }
            } else {
                VStack(spacing: 2) {
                    motionToggle
                    echoToggle
                }
            }
            Button {
                seed += 1
            } label: {
                HStack {
                    Text(verbatim: "New composition")
                        .font(.system(size: 14))
                        .fontWeight(.semibold)
                    Spacer()
                    Text(verbatim: "+").font(.system(size: 22))
                }
                .padding(.horizontal, 16)
                .frame(height: 46)
                .background { StudioInk.lime }
                .cornerRadius(6)
            }
            .buttonStyle(.plain)
        }
    }

    private var paletteControl: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionLabel("Palette", value: palettes[palette])
            HStack(spacing: 8) {
                ForEach(0..<3) { index in
                    let shades = StudioInk.colors(index)
                    Button { palette = index } label: {
                        HStack(spacing: 0) {
                            shades[0]
                            shades[1]
                            shades[2]
                        }
                        .frame(height: 28)
                        .cornerRadius(3)
                        .padding(4)
                        .background { palette == index ? StudioInk.primary : StudioInk.line }
                        .cornerRadius(6)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private func tempoControl(compact: Bool) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionLabel("Tempo", value: String(format: "%.1fx", speeds[speedIndex]))
            HStack(spacing: 8) {
                tempoButton("-", step: -1)
                HStack(alignment: .center, spacing: 3) {
                    ForEach(0..<(compact ? 4 : 12)) { index in
                        (index < (speedIndex + 1) * (compact ? 1 : 3) ? StudioInk.primary : StudioInk.line)
                            .frame(width: compact ? 4 : 5, height: CGFloat(8 + index * (compact ? 6 : 2)))
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 36)
                tempoButton("+", step: 1)
            }
        }
    }

    private var motionToggle: some View {
        Toggle(isOn: playback) {
            Text(verbatim: "Motion").font(.system(size: 14))
        }
        .toggleStyle(StudioToggleStyle())
    }

    private var echoToggle: some View {
        Toggle(isOn: $echo) {
            Text(verbatim: "Echo layers").font(.system(size: 14))
        }
        .toggleStyle(StudioToggleStyle())
    }

    private func sectionLabel(_ title: String, value: String) -> some View {
        HStack {
            Text(verbatim: title).fontWeight(.semibold)
            Spacer()
            Text(verbatim: value).foregroundColor(StudioInk.secondary)
        }
        .font(.system(size: 12))
    }

    private func tempoButton(_ title: String, step: Int) -> some View {
        Button {
            checkpoint()
            speedIndex = min(speeds.count - 1, max(0, speedIndex + step))
        } label: {
            Text(verbatim: title)
                .font(.system(size: 22))
                .frame(width: 36, height: 36)
                .background { Color.white }
                .cornerRadius(5)
        }
        .buttonStyle(.plain)
        .opacity((step < 0 && speedIndex == 0) || (step > 0 && speedIndex == speeds.count - 1) ? 0.35 : 1)
        .disabled((step < 0 && speedIndex == 0) || (step > 0 && speedIndex == speeds.count - 1))
    }

    private var footer: some View {
        VStack(spacing: 14) {
            StudioInk.line.frame(height: 1)
            HStack(spacing: 6) {
                Circle().fill(StudioInk.colors(palette)[1]).frame(width: 6, height: 6)
                Text(verbatim: playing ? "In motion" : "Paused")
                Spacer()
                Text(verbatim: "24 elements / 3 studies")
            }
            .font(.system(size: 11))
            .foregroundColor(StudioInk.secondary)
        }
    }
}

private struct StudioStage: View {
    let study: Int
    let palette: Int
    let seed: Int
    let time: Double
    let playing: Bool
    let echo: Bool

    private var colors: [Color] { StudioInk.colors(palette) }

    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height
            ZStack {
                Color(red: 0.075, green: 0.08, blue: 0.08)
                VStack(spacing: 0) {
                    ForEach(0..<7) { _ in
                        Color.white.opacity(0.06).frame(height: 1)
                        Spacer(minLength: 0)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 70)
                if study == 2 {
                    lattice(width: width, height: height)
                } else {
                    ribbons(width: width, height: height)
                }
                VStack(alignment: .leading, spacing: 0) {
                    HStack {
                        Text(verbatim: ["01 / FLOW", "02 / CASCADE", "03 / LATTICE"][study])
                            .fontWeight(.semibold)
                        Spacer()
                        Circle().fill(playing ? colors[0] : .gray).frame(width: 5, height: 5)
                        Text(verbatim: playing ? "LIVE" : "HOLD")
                    }
                    .font(.system(size: 10))
                    Spacer()
                    HStack(alignment: .bottom) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(verbatim: ["Continuous flow", "Ordered chaos", "Small revolutions"][study])
                                .font(.system(size: width < 400 ? 20 : 27))
                                .fontWeight(.medium)
                            Text(verbatim: String(format: "N %02d     /     %@", seed + 1, ["BOTANIC", "EMBER", "IRIS"][palette]))
                                .font(.system(size: 10))
                                .foregroundColor(Color.white.opacity(0.45))
                        }
                        Spacer(minLength: 8)
                        HStack(alignment: .bottom, spacing: 3) {
                            ForEach(0..<9) { index in
                                colors[index % 3]
                                    .frame(width: 3, height: 6 + 18 * abs(sin(time + Double(index) * 0.4)))
                            }
                        }
                        .frame(width: 51, height: 24, alignment: .bottom)
                    }
                }
                .foregroundColor(.white)
                .padding(24)
            }
        }
    }

    private func ribbons(width: CGFloat, height: CGFloat) -> some View {
        let gap: CGFloat = width < 400 ? 3 : 5
        let barWidth = max(2, (width - 64 - gap * 23) / 24)
        let available = height - 150
        return HStack(alignment: .center, spacing: gap) {
            ForEach(0..<24) { index in
                let p = Double(index) * (study == 0 ? 0.24 : 0.61) + Double(seed) * 1.7
                let wave = sin(time * 1.4 + p)
                let length = available * (0.24 + 0.63 * (wave + 1) / 2)
                let drift = study == 0 ? cos(time * 0.7 + p) * available * 0.12 : (available - length) / 2
                ZStack {
                    if echo {
                        colors[(index / 8 + 1) % 3]
                            .opacity(0.18)
                            .frame(width: barWidth, height: length * 0.8)
                            .cornerRadius(barWidth / 2)
                            .offset(y: drift + 18)
                    }
                    colors[(index / 8 + seed) % 3]
                        .opacity(0.65 + 0.35 * (wave + 1) / 2)
                        .frame(width: barWidth, height: length)
                        .cornerRadius(barWidth / 2)
                        .offset(y: drift - 8)
                }
                .frame(width: barWidth, height: available)
            }
        }
        .frame(width: width, height: height)
        .offset(y: -10)
    }

    private func lattice(width: CGFloat, height: CGFloat) -> some View {
        let cell = min((width - 60) / 6, (height - 150) / 4)
        return VStack(spacing: 5) {
            ForEach(0..<4) { row in
                HStack(spacing: 5) {
                    ForEach(0..<6) { column in
                        let index = row * 6 + column
                        let wave = sin(time * 1.3 + Double(index) * 0.38 + Double(seed))
                        let size = cell * (0.42 + 0.23 * (wave + 1) / 2)
                        ZStack {
                            if echo {
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(colors[(row + 1) % 3].opacity(0.2))
                                    .frame(width: size, height: size)
                                    .rotationEffect(.degrees(-wave * 45))
                            }
                            RoundedRectangle(cornerRadius: column % 2 == 0 ? 4 : size / 2)
                                .fill(colors[(row + column + seed) % 3])
                                .frame(width: size, height: size)
                                .rotationEffect(.degrees(wave * 75))
                        }
                        .frame(width: cell, height: cell)
                    }
                }
            }
        }
        .frame(width: width, height: height)
        .offset(y: -12)
    }
}

private struct StudioToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        Button { configuration.isOn.toggle() } label: {
            HStack {
                configuration.label
                Spacer()
                ZStack {
                    (configuration.isOn ? StudioInk.primary : StudioInk.line)
                        .frame(width: 38, height: 23)
                        .cornerRadius(12)
                    Circle()
                        .fill(configuration.isOn ? StudioInk.lime : .white)
                        .frame(width: 17, height: 17)
                        .offset(x: configuration.isOn ? 7.5 : -7.5)
                }
                .frame(width: 38, height: 23)
            }
            .frame(height: 34)
        }
        .buttonStyle(.plain)
    }
}

private struct TextExamples: View {
    var body: some View {
        VStack(spacing: 24) {
            Text(verbatim: "OpenSwiftUI on Android")
                .font(.title2)
                .fontWeight(.bold)
            Text(verbatim: "with UIKit-cross-platform")
                .font(.system(size: 17))
                .foregroundColor(.blue)
            Text(verbatim: "This sentence wraps using measured font metrics, not a fixed text size.")
                .font(.system(size: 18))
                .multilineTextAlignment(.center)
                .frame(width: 220)
            Text(verbatim: "A long single line should end with an ellipsis.")
                .font(.system(size: 18))
                .lineLimit(1)
                .frame(width: 220)
            TimelineView(.periodic(from: .now, by: 1)) { timeline in
                let expanded = Int(timeline.date.timeIntervalSince1970) % 2 == 0
                Text(verbatim: expanded ? "Text changes and relayouts" : "Short text")
                    .font(.system(size: expanded ? 20 : 16))
                    .foregroundColor(expanded ? .red : .blue)
            }
        }
        .foregroundColor(.white)
        .padding()
    }
}

package struct BreathingColorView: View {
    @State private var count = 0
    @State private var usesBlue = true

    package var body: some View {
        TimelineView(.animation) { timeline in
            let time = timeline.date.timeIntervalSince1970
            let breathe = (sin(time) + 1.0) / 2.0
            let color: Color = usesBlue ? .blue : .red

            VStack(spacing: 24.0) {
                Text(verbatim: "Breathing Colors")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)

                Text(verbatim: "OpenSwiftUI on Android\nwith UIKit-cross-platform")
                    .font(.system(size: 17))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)

                color.opacity(0.3 + breathe * 0.7)
                    .frame(width: 200.0, height: 200.0)
                    .scaleEffect(0.8 + breathe * 0.4)

                color
                    .frame(width: 200.0, height: 20.0)
                    .opacity(0.3 + breathe * 0.7)
                    .cornerRadius(10.0)

                Button {
                    count += 1
                } label: {
                    Text(verbatim: "Count: \(count)")
                        .font(.system(size: 18))
                        .frame(width: 240, height: 44)
                        .background { Color.blue }
                        .cornerRadius(8)
                }
                .buttonStyle(.plain)

                Toggle(isOn: $usesBlue) {
                    Text(verbatim: "Blue colors")
                        .font(.system(size: 18))
                }
                .toggleStyle(DemoSwitchToggleStyle())
                .frame(width: 240)
            }
            .foregroundColor(.white)
            .padding()
        }
        .onAppear {
            guard let value = ProcessInfo.processInfo.environment["OPENSWIFTUI_DEMO_TOGGLE_DELAY"],
                  let delay = Double(value), delay.isFinite, delay >= 0 else {
                return
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                usesBlue = false
            }
        }
    }
}

// Android has no native SwitchToggleStyle yet; this stays in the DisplayList path.
private struct DemoSwitchToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        Button {
            configuration.isOn.toggle()
        } label: {
            HStack {
                configuration.label
                Spacer()
                ZStack(alignment: configuration.isOn ? .trailing : .leading) {
                    (configuration.isOn ? Color.green : Color.gray)
                        .frame(width: 52, height: 32)
                        .cornerRadius(16)
                    Color.white
                        .frame(width: 28, height: 28)
                        .cornerRadius(14)
                        .padding(2)
                }
            }
            .frame(height: 44)
            .background { Color.black }
        }
        .buttonStyle(.plain)
    }
}
