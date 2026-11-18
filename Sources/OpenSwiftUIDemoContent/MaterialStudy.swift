#if UIKIT_CROSS_PLATFORM
import Foundation
import OpenSwiftUI

struct MaterialStudy: View {
    @State private var level = 2
    @State private var coverage = 65.0
    @State private var dark = false

    private let materials: [Material] = [.ultraThin, .thin, .regular, .thick, .ultraThick]
    private let names = ["Ultra thin", "Thin", "Regular", "Thick", "Ultra thick"]
    private let stripes: [Color] = [
        Color(red: 0.10, green: 0.55, blue: 0.52), Color(red: 0.73, green: 0.87, blue: 0.38),
        Color(red: 1.00, green: 0.65, blue: 0.47), Color(red: 0.90, green: 0.34, blue: 0.37),
        Color(red: 0.42, green: 0.40, blue: 0.71)
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text(verbatim: "OpenSwiftUI on Android")
                .font(.system(size: 15))
            Text(verbatim: "Material study")
                .font(.system(size: 32)).fontWeight(.bold)
            GeometryReader { geometry in
                ZStack {
                    HStack(spacing: 0) {
                        ForEach(0..<5) { index in stripes[index] }
                    }
                    RoundedRectangle(cornerRadius: 8)
                        .fill(materials[level])
                        .frame(width: geometry.size.width * coverage / 100, height: 138)
                    Text(verbatim: names[level]).font(.title2).fontWeight(.semibold)
                }
                .frame(width: geometry.size.width, height: geometry.size.height)
            }
            .frame(height: 220)
            Stepper(value: $level, in: 0...4) { Text(verbatim: "Thickness") }
            HStack {
                Text(verbatim: "Coverage")
                Spacer()
                Text(verbatim: "\(Int(coverage))%").fontWeight(.semibold)
            }
            Slider(value: $coverage, in: 30...95, step: 5)
            Toggle(isOn: $dark) { Text(verbatim: "Dark appearance") }
            Spacer(minLength: 0)
        }
        .padding(24)
        .foregroundColor(dark ? .white : .black)
        .background { dark ? Color.black : Color.white }
        .environment(\.colorScheme, dark ? .dark : .light)
    }
}
#endif
