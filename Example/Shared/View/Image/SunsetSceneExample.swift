//
//  SunsetSceneExample.swift
//  Shared

#if OPENSWIFTUI
import OpenSwiftUI
#else
import SwiftUI
#endif

// MARK: - Main Scene

struct SunsetSceneExample: View {
    var body: some View {
        ZStack {
            SkyBackground()
            SunView()
            StarsView()
            CloudsView()
            MountainsView()
            LakeView()
            TreesView()
            BirdsView()
            SwiftLogoView()
            BadgeView()
        }
    }
}

// MARK: - Sky Background

private struct SkyBackground: View {
    var body: some View {
        ZStack {
            Color.indigo
                .ignoresSafeArea()

            VStack(spacing: 0) {
                Color.purple.opacity(0.5)
                Color.orange.opacity(0.4)
                Color.yellow.opacity(0.3)
            }
            .ignoresSafeArea()
        }
    }
}

// MARK: - Sun

private struct SunView: View {
    @State private var sunOffset: CGFloat = 0
    @State private var glowing = false

    var body: some View {
        VStack {
            Spacer()

            ZStack {
                Circle()
                    .fill(Color.orange.opacity(0.12))
                    .frame(width: 200, height: 200)
                Circle()
                    .fill(Color.orange.opacity(0.2))
                    .frame(width: 150, height: 150)
                Circle()
                    .fill(Color.yellow.opacity(0.5))
                    .frame(width: 100, height: 100)
                Circle()
                    .fill(Color.white.opacity(0.9))
                    .frame(width: 55, height: 55)
            }
            .shadow(color: .orange.opacity(0.7), radius: glowing ? 50 : 20)
            .offset(y: sunOffset)
            .onAppear {
                withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
                    sunOffset = -10
                    glowing = true
                }
            }

            Spacer()
        }
    }
}

// MARK: - Stars

private struct StarsView: View {
    var body: some View {
        VStack {
            HStack(spacing: 60) {
                StarIcon(opacity: 0.8, size: 10)
                StarIcon(opacity: 0.5, size: 7)
                StarIcon(opacity: 0.7, size: 9)
            }
            .padding(.top, 30)

            HStack(spacing: 90) {
                StarIcon(opacity: 0.4, size: 5)
                StarIcon(opacity: 0.6, size: 8)
            }
            .padding(.top, 8)

            HStack(spacing: 120) {
                StarIcon(opacity: 0.3, size: 4)
                StarIcon(opacity: 0.5, size: 6)
                StarIcon(opacity: 0.4, size: 5)
            }
            .padding(.top, 6)

            Spacer()
        }
    }
}

private struct StarIcon: View {
    let opacity: Double
    let size: CGFloat

    var body: some View {
        Image(systemName: "star.fill")
            .foregroundStyle(.white.opacity(opacity))
            .font(.system(size: size))
    }
}

// MARK: - Clouds

private struct CloudsView: View {
    var body: some View {
        VStack {
            HStack {
                CloudIcon(size: 40, opacity: 0.18)
                Spacer()
                CloudIcon(size: 30, opacity: 0.12)
                    .offset(y: 15)
            }
            .padding(.horizontal, 30)
            .padding(.top, 50)

            HStack {
                Spacer()
                CloudIcon(size: 25, opacity: 0.1)
                    .padding(.trailing, 60)
            }
            .padding(.top, 5)

            Spacer()
        }
    }
}

private struct CloudIcon: View {
    let size: CGFloat
    let opacity: Double

    var body: some View {
        Image(systemName: "cloud.fill")
            .font(.system(size: size))
            .foregroundStyle(.white.opacity(opacity))
    }
}

// MARK: - Mountains

private struct MountainsView: View {
    var body: some View {
        VStack {
            Spacer()
            ZStack(alignment: .bottom) {
                BackMountainRange()
                FrontMountainRange()
                SnowCaps()
            }
            .frame(height: 220)
        }
        .ignoresSafeArea()
    }
}

private struct BackMountainRange: View {
    var body: some View {
        HStack(spacing: -20) {
            MountainPeak(size: 120, color: Color.indigo.opacity(0.7))
            MountainPeak(size: 150, color: Color.indigo.opacity(0.6))
            MountainPeak(size: 130, color: Color.indigo.opacity(0.7))
        }
        .offset(y: 40)
    }
}

private struct FrontMountainRange: View {
    var body: some View {
        HStack(spacing: -30) {
            MountainPeak(size: 130, color: Color(red: 0.1, green: 0.06, blue: 0.18))
            MountainPeak(size: 160, color: Color(red: 0.12, green: 0.07, blue: 0.2))
            MountainPeak(size: 140, color: Color(red: 0.1, green: 0.06, blue: 0.18))
        }
        .offset(y: 60)
    }
}

private struct MountainPeak: View {
    let size: CGFloat
    let color: Color

    var body: some View {
        Image(systemName: "triangle.fill")
            .font(.system(size: size))
            .foregroundStyle(color)
    }
}

private struct SnowCaps: View {
    var body: some View {
        HStack(spacing: -30) {
            SnowCap(size: 22, offset: CGPoint(x: -5, y: -70), opacity: 0.4)
            SnowCap(size: 26, offset: CGPoint(x: 15, y: -85), opacity: 0.35)
            SnowCap(size: 20, offset: CGPoint(x: 30, y: -75), opacity: 0.3)
        }
    }
}

private struct SnowCap: View {
    let size: CGFloat
    let offset: CGPoint
    let opacity: Double

    var body: some View {
        Image(systemName: "triangle.fill")
            .font(.system(size: size))
            .foregroundStyle(.white.opacity(opacity))
            .offset(x: offset.x, y: offset.y)
    }
}

// MARK: - Lake

private struct LakeView: View {
    var body: some View {
        VStack {
            Spacer()
            ZStack {
                Color(red: 0.15, green: 0.08, blue: 0.3).opacity(0.8)
                WaterShimmer()
            }
            .frame(height: 80)
        }
        .ignoresSafeArea()
    }
}

private struct WaterShimmer: View {
    var body: some View {
        VStack(spacing: 10) {
            ForEach(0..<4, id: \.self) { i in
                Capsule()
                    .fill(Color.orange.opacity(Double(4 - i) * 0.04))
                    .frame(width: CGFloat(30 + i * 15), height: 1.2)
            }
        }
    }
}

// MARK: - Trees

private struct TreesView: View {
    var body: some View {
        VStack {
            Spacer()
            HStack(alignment: .bottom) {
                TreeGroup(sizes: [28, 38, 24])
                Spacer()
                TreeGroup(sizes: [22, 30, 26])
                Spacer()
                TreeGroup(sizes: [32, 42, 28])
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 140)
        }
    }
}

private struct TreeGroup: View {
    let sizes: [CGFloat]

    var body: some View {
        HStack(spacing: -4) {
            ForEach(sizes, id: \.self) { size in
                TreeIcon(size: size)
            }
        }
    }
}

private struct TreeIcon: View {
    let size: CGFloat

    var body: some View {
        Image(systemName: "tree.fill")
            .font(.system(size: size))
            .foregroundStyle(.black.opacity(0.85))
    }
}

// MARK: - Birds

private struct BirdsView: View {
    var body: some View {
        VStack {
            HStack(spacing: 10) {
                BirdIcon(size: 11, offsetY: 0)
                BirdIcon(size: 8, offsetY: -4)
                BirdIcon(size: 10, offsetY: 2)
            }
            .foregroundStyle(.black.opacity(0.45))
            .padding(.top, 140)
            .padding(.leading, 50)

            Spacer()
        }
    }
}

private struct BirdIcon: View {
    let size: CGFloat
    let offsetY: CGFloat

    var body: some View {
        Image(systemName: "bird.fill")
            .font(.system(size: size))
            .offset(y: offsetY)
    }
}

// MARK: - Swift Logo (Colorful + Rotating)

private struct SwiftLogoView: View {
    var body: some View {
        VStack {
            ZStack {
                // Glow behind logo
                Circle()
                    .fill(Color.white.opacity(0.15))
                    .frame(width: 90, height: 90)

                // Layered colored swift icons to simulate a colorful look
                ZStack {
                    Image(systemName: "swift")
                        .font(.system(size: 52, weight: .bold))
                        .foregroundStyle(.red.opacity(0.6))
                        .offset(x: -2, y: -2)

                    Image(systemName: "swift")
                        .font(.system(size: 52, weight: .bold))
                        .foregroundStyle(.purple.opacity(0.5))
                        .offset(x: 2, y: -1)

                    Image(systemName: "swift")
                        .font(.system(size: 52, weight: .bold))
                        .foregroundStyle(.blue.opacity(0.4))
                        .offset(x: 1, y: 2)

                    Image(systemName: "swift")
                        .font(.system(size: 50, weight: .bold))
                        .foregroundStyle(.orange)
                }
                .shadow(color: .orange.opacity(0.5), radius: 8)
                .shadow(color: .red.opacity(0.3), radius: 16)

                // Sparkle accents around logo
                SparkleRing()
            }
            .padding(.top, 80)

            Spacer()
        }
    }
}

private struct SparkleRing: View {
    var body: some View {
        ZStack {
            Image(systemName: "sparkle")
                .font(.system(size: 10))
                .foregroundStyle(.yellow.opacity(0.8))
                .offset(x: -50, y: -10)

            Image(systemName: "sparkle")
                .font(.system(size: 7))
                .foregroundStyle(.orange.opacity(0.7))
                .offset(x: 48, y: 5)

            Image(systemName: "sparkle")
                .font(.system(size: 8))
                .foregroundStyle(.pink.opacity(0.6))
                .offset(x: 10, y: -48)

            Image(systemName: "sparkle")
                .font(.system(size: 9))
                .foregroundStyle(.white.opacity(0.5))
                .offset(x: -15, y: 46)
        }
    }
}

// MARK: - Badge

private struct BadgeView: View {
    var body: some View {
        VStack {
            Spacer()
            HStack(spacing: 8) {
                Image(systemName: "moon.stars.fill")
                    .foregroundStyle(.yellow)
                    .font(.system(size: 16))
                Image(systemName: "sparkles")
                    .foregroundStyle(.orange)
                    .font(.system(size: 16))
                Image(systemName: "mountain.2.fill")
                    .foregroundStyle(.white.opacity(0.8))
                    .font(.system(size: 16))
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 24)
            .background {
                Capsule()
                    .fill(Color.black.opacity(0.3))
            }
            // TODO: strokePath is not supported yet.
//            .overlay {
//                Capsule()
//                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
//            }
            .padding(.bottom, 40)
        }
    }
}
