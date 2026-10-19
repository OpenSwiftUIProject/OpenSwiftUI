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
        } else {
            BreathingColorView()
        }
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
