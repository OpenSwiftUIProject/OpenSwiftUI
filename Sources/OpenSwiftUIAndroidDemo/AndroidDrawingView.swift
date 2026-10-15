#if os(Android) && OPENSWIFTUI_ANDROID_UIKIT
import Foundation
import UIKit
import OpenQuartzCoreShims
import OpenRenderBoxShims
@_spi(DisplayList_ViewSystem) import OpenSwiftUICore

final class AndroidDrawingView: AndroidUIKitView, PlatformDrawable {
    nonisolated(unsafe) var options: PlatformDrawableOptions
    nonisolated static var allowsContentsMultiplyColor: Bool { false }
    private let label = UILabel(frame: .zero)
    private var text: PlatformTextContent?
    private var contentsScale: Double = 0

    init(options: PlatformDrawableOptions) {
        self.options = options
        super.init(frame: .zero)
        layer.anchorPoint = .zero
        label.layer.anchorPoint = .zero
        isUserInteractionEnabled = false
        addSubview(label)
    }

    nonisolated func update(content: PlatformDrawableContent?, required: Bool) -> Bool {
        MainActor.assumeIsolated {
            guard let content else {
                text = nil
                label.text = nil
                label.attributedText = nil
                return true
            }
            guard let next = content.textContent else {
                preconditionFailure("AndroidDrawingView currently supports text content only")
            }
            if required || text?.lineLimit != next.lineLimit || text?.string != next.string {
                text = next
                AndroidTextSystem.configure(label, string: next.string, lineLimit: next.lineLimit)
                setNeedsLayout()
            }
            return true
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        label.frame = bounds
        // Multi-line limits clip from the bottom, rather than centering an oversized texture.
        let naturalHeight = label.sizeThatFits(bounds.size).height
        if naturalHeight > bounds.height {
            label.frame.size.height = naturalHeight
        }
        label.clipsToBounds = true
    }

    nonisolated func setContentsScale(_ scale: Foundation.CGFloat) {
        MainActor.assumeIsolated {
            let resolvedScale = UIScreen.main?.scale ?? Double(scale)
            guard contentsScale != resolvedScale else { return }
            contentsScale = resolvedScale
            label.layer.contentsScale = resolvedScale
            label.setNeedsDisplay()
        }
    }

    nonisolated func makeAsyncUpdate(
        content: PlatformDrawableContent,
        required: Bool,
        layer: OpenQuartzCoreShims.CALayer,
        bounds: Foundation.CGRect
    ) -> (() -> Void)? { nil }

    nonisolated func drawForTesting(in list: ORBDisplayList) {
        preconditionFailure("Android text drawing uses UIKit/SDL, not an ORB display list")
    }
}
#endif
