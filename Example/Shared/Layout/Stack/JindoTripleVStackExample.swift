//
//  JindoTripleVStackExample.swift
//  Shared

#if OPENSWIFTUI
@_spi(Jindo) import OpenSwiftUI
#else
import SwiftUI_SPI
#endif

#if !os(macOS)
struct JindoExample: View {
    var body: some View {
        VStack {
            JindoTripleVStackExample()
            JindoBuildDashboardExample()
            JindoDynamicIslandExample()
        }
    }
}

struct JindoTripleVStackExample: View {
    var body: some View {
        JindoTripleVStack(
            configuration: .init(
                notchSize: CGSize(width: 120, height: 36),
                horizontalSizing: .split,
                layoutMargins: EdgeInsets(
                    top: 8,
                    leading: 16,
                    bottom: 16,
                    trailing: 16
                )
            )
        ) {
            region("Leading", color: .blue)
                .jindoPosition(.leading)

            region("Center", color: .purple)
                .jindoPosition(.center)

            region("Trailing", color: .orange)
                .jindoPosition(.trailing)

            Capsule()
                .fill(.black)
                .jindoPosition(.notch)

            Text("Bottom content shared by all three stacks")
                .frame(maxWidth: .infinity)
                .padding(12)
                .background(Color.green)
                .jindoPosition(.bottom)
        }
        .frame(maxWidth: .infinity)
        .background(Color.gray.opacity(0.15))
        .padding()
    }

    private func region(_ title: String, color: Color) -> some View {
        Text(title)
            .frame(maxWidth: .infinity)
            .padding(8)
            .background(color)
    }
}

struct JindoBuildDashboardExample: View {
    var body: some View {
        JindoTripleVStack(
            configuration: .init(
                notchSize: CGSize(width: 132, height: 40),
                horizontalSizing: .split,
                layoutMargins: EdgeInsets(
                    top: 12,
                    leading: 16,
                    bottom: 16,
                    trailing: 16
                )
            )
        ) {
            projectSummary
                .jindoPosition(.leading)

            buildSummary
                .jindoPosition(.center)

            weatherSummary
                .jindoPosition(.trailing)

            buildStatus
                .jindoPosition(.notch)

            recentActivity
                .jindoPosition(.bottom)
        }
        .frame(maxWidth: .infinity)
        .background(Color.gray.opacity(0.08))
        .padding()
    }

    private var projectSummary: some View {
        VStack(alignment: .leading, spacing: 6) {
            Image("logo")
                .resizable()
                .frame(width: 48, height: 48)
                .clipShape(RoundedRectangle(cornerRadius: 12))

            Text("OpenSwiftUI")
                .font(.headline)

            HStack(spacing: 4) {
                Circle()
                    .fill(Color.green)
                    .frame(width: 7, height: 7)
                Text("Community build")
                    .font(.caption)
                    .foregroundStyle(Color.gray)
            }
        }
        .padding(12)
        .background(Color.blue.opacity(0.10))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var buildSummary: some View {
        VStack(spacing: 6) {
            Image(systemName: "hammer.fill")
                .font(.system(size: 24))
                .foregroundStyle(Color.purple)

            Text("Nightly")
                .font(.headline)

            Text("Build #2148")
                .font(.caption)
                .foregroundStyle(Color.gray)
        }
        .frame(width: 112)
        .padding(.vertical, 12)
        .background(Color.purple.opacity(0.10))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var weatherSummary: some View {
        VStack(alignment: .trailing, spacing: 5) {
            Image(systemName: "cloud.sun.fill")
                .font(.system(size: 24))
                .foregroundStyle(Color.orange)

            Text("24°")
                .font(.headline)

            Text("Shanghai")
                .font(.caption)
                .foregroundStyle(Color.gray)
        }
        .padding(12)
        .background(Color.orange.opacity(0.10))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var buildStatus: some View {
        HStack(spacing: 6) {
            Image(systemName: "waveform")
                .foregroundStyle(Color.green)
            Text("Building")
                .font(.caption)
                .foregroundStyle(Color.white)
        }
        .frame(width: 132, height: 40)
        .background(Color.black)
        .clipShape(Capsule())
    }

    private var recentActivity: some View {
        HStack(spacing: 12) {
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 30))
                .foregroundStyle(Color.green)

            VStack(alignment: .leading, spacing: 3) {
                Text("All checks passed")
                    .font(.headline)
                Text("Layout parity verified 2 minutes ago")
                    .font(.caption)
                    .foregroundStyle(Color.gray)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundStyle(Color.gray)
        }
        .padding(14)
        .background(Color.green.opacity(0.10))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

/// Demonstrates the reference Dynamic Island-style Jindo layout.
struct JindoDynamicIslandExample: View {
    var body: some View {
        JindoTripleVStack(
            configuration: .init(
                notchSize: CGSize(width: 126, height: 80),
                horizontalSizing: .split,
                layoutMargins: EdgeInsets(
                    top: 0,
                    leading: 16,
                    bottom: 16,
                    trailing: 16
                )
            )
        ) {
            Image(systemName: "timer")
                .jindoPosition(.leading)

            Text("2:45")
                .font(.caption)
                .jindoPosition(.leading)

            Image(systemName: "music.note")
                .jindoPosition(.trailing)

            Text("Now Playing")
                .font(.caption)
                .jindoPosition(.trailing)

            Text("Main Content")
                .jindoPosition(.center)

            Text("Bottom Section")
                .jindoPosition(.bottom)

            Text("Wide content here")
                .jindoVerticalPlacement(.belowNotchIfTooWide)
                .jindoPosition(.leading)
        }
        .colorScheme(.dark)
        .background(Color.pink.opacity(0.8))
        .padding()
    }
}
#endif
