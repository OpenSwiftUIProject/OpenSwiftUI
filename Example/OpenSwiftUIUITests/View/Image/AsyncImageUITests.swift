//
//  AsyncImageUITests.swift
//  OpenSwiftUIUITests

import Foundation
import SnapshotTesting
import Testing

@MainActor
@Suite(.snapshots(record: .never, diffTool: diffTool))
struct AsyncImageUITests {
    @Test
    func localLogoImage() async throws {
        struct ContentView: View {
            var body: some View {
                AsyncImage(url: Bundle.main.url(forResource: "logo", withExtension: "png")) { phase in
                    switch phase {
                    case .empty:
                        Color.red
                    case .success(let image):
                        image
                            .resizable()
                            .frame(width: 100, height: 100)
                    case .failure:
                        Color.yellow
                    @unknown default:
                        Color.yellow
                    }
                }
            }
        }
        // FIXME:
        // 1. SUI can screenshot without manully set frame for placeholder state while OSUI need it
        // let controller = PlatformHostingController(rootView: ContentView())
        // openSwiftUIControllerAssertSnapshot(of: controller, as: .image, named: "placeholder")
        // openSwiftUIControllerAssertSnapshot(of: controller, as: .wait(for: 5, on: .image), named: "logo")
        // 2. OSUI can screenshot correctly using .wait(for: 1, on: .image) while SUI need to use try await Task.sleep
        // Those mismatch behavior is PlatformViewController issue
        let controller = PlatformHostingController(rootView: ContentView())
        controller.view.frame = CGRect(origin: .zero, size: CGSize(width: 200, height: 200))
        openSwiftUIControllerAssertSnapshot(of: controller, as: .image, named: "placeholder")
        try await Task.sleep(for: .seconds(1))
        openSwiftUIControllerAssertSnapshot(of: controller, as: .image, named: "logo")
    }
}
