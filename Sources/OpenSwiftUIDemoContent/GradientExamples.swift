#if UIKIT_CROSS_PLATFORM
import OpenSwiftUI

struct GradientExamples: View {
    var body: some View {
        VStack(spacing: 18) {
            Text(verbatim: "GradientExample")
                .font(.system(size: 26, weight: .bold))
            HStack(spacing: 12) {
                sample("Linear", GradientExample(kind: .linear))
                sample("Radial", GradientExample(kind: .radial))
            }
            HStack(spacing: 12) {
                sample("Elliptical", GradientExample(kind: .elliptical))
                sample("Angular", GradientExample(kind: .angular))
            }
            HStack(spacing: 12) {
                sample("Conic", GradientAnimationExample(kind: .conic))
                sample("Repeated stops", GradientExample(palette: .stops))
            }
            HStack(spacing: 12) {
                sample("Transparency", GradientExample(palette: .transparent))
                sample("AnyGradient / Device", GradientExample(usesAnyGradient: true, colorSpace: .device))
            }
        }
        .foregroundStyle(Color.white)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(red: 0.05, green: 0.05, blue: 0.08).ignoresSafeArea())
    }

    private func sample<Sample: View>(_ title: String, _ sample: Sample) -> some View {
        VStack(spacing: 5) {
            sample
            Text(verbatim: title).font(.system(size: 13))
        }
    }
}
#endif
