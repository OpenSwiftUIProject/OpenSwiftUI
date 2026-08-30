//
//  JindoKitExample.swift
//  Shared

#if !os(macOS)

#if OPENSWIFTUI
import OpenSwiftUI
#else
import SwiftUI
#endif

#if OPENSWIFTUI
@available(OpenSwiftUI_v4_1, *)
#else
@available(iOS 16.1, tvOS 18.0, watchOS 11.0, *)
#endif
@available(macOS, unavailable)
struct JindoKitExample: View {
    var body: some View {
        VStack(spacing: 16) {
            Text("JindoKit + Example")
                .font(.headline)

            island(mode: .expanded)

            HStack(spacing: 24) {
                VStack(spacing: 6) {
                    Text("Compact")
                    island(mode: .compact)
                }

                VStack(spacing: 6) {
                    Text("Minimal")
                    island(mode: .minimal)
                }
            }
        }
        .padding()
    }

    private func island(mode: DynamicIslandPreviewMode) -> some View {
        DynamicIsland {
            DynamicIslandExpandedRegion(.leading) {
                VStack(alignment: .leading, spacing: 2) {
                    Image(systemName: "timer")
                        .foregroundStyle(Color.mint)
                    Text("12 MIN")
                        .font(.caption)
                }
            }

            DynamicIslandExpandedRegion(.trailing) {
                Image(systemName: "figure.run")
                    .foregroundStyle(Color.blue)
            }

            DynamicIslandExpandedRegion(.bottom) {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Golden Gate Run")
                        Spacer()
                        Text("68%")
                    }
                    ProgressView(value: 0.68)
                        .tint(Color.mint)
                }
            }
        } compactLeading: {
            Text("12")
                .foregroundStyle(Color.mint)
        } compactTrailing: {
            Image(systemName: "figure.run")
                .foregroundStyle(Color.blue)
        } minimal: {
            Image(systemName: "figure.run")
                .foregroundStyle(Color.mint)
        }
        .contentMargins(.all, 20, for: .expanded)
        .previewMode(mode)
    }
}

#Preview {
    JindoKitExample()
}

#endif
