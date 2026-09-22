#if os(Android) && OPENSWIFTUI_ANDROID_UIKIT
import Foundation
import UIKit
import OpenQuartzCoreShims
@_spi(DisplayList_ViewSystem) import OpenSwiftUICore

class AndroidUIKitView: UIView {
    // The shared cache requires layer identity; drawing uses UIKit's native layer.
    let displayListLayer = OpenQuartzCoreShims.CALayer()
}

final class AndroidUIViewPlatformViewDefinition: PlatformViewDefinition, @unchecked Sendable {
    override static var system: System { .uiView }

    override static func makeView(kind: ViewKind) -> AnyObject {
        MainActor.assumeIsolated {
            let view = AndroidUIKitView(frame: .zero)
            view.layer.anchorPoint = .zero
            view.isUserInteractionEnabled = false
            return view
        }
    }

    override static func makeLayerView(type: OpenQuartzCoreShims.CALayer.Type, kind: ViewKind) -> AnyObject {
        makeView(kind: kind)
    }

    override static func viewLayer(_ view: AnyObject) -> OpenQuartzCoreShims.CALayer {
        MainActor.assumeIsolated { (view as! AndroidUIKitView).displayListLayer }
    }

    override static func subviews(_ view: AnyObject) -> [AnyObject] {
        MainActor.assumeIsolated { (view as! UIView).subviews }
    }

    override static func removeFromSuperview(_ view: AnyObject) {
        MainActor.assumeIsolated { (view as! UIView).removeFromSuperview() }
    }

    override static func addSubview(_ child: AnyObject, to parent: AnyObject, at index: Int) {
        MainActor.assumeIsolated { (parent as! UIView).insertSubview(child as! UIView, at: index) }
    }

    override static func setFrame(_ frame: Foundation.CGRect, of view: AnyObject) {
        MainActor.assumeIsolated { (view as! UIView).frame = frame.uiRect }
    }

    override static func frame(of view: AnyObject) -> Foundation.CGRect? {
        MainActor.assumeIsolated { (view as! UIView).frame.foundationRect }
    }

    override static func bounds(of view: AnyObject) -> Foundation.CGRect? {
        MainActor.assumeIsolated { (view as! UIView).bounds.foundationRect }
    }

    override static func maskView(_ view: AnyObject) -> AnyObject? {
        MainActor.assumeIsolated { (view as! UIView).mask }
    }

    override static func setClipsToBounds(_ clips: Bool, of view: AnyObject) {
        MainActor.assumeIsolated { (view as! UIView).clipsToBounds = clips }
    }

    override static func setGeometry(position: Foundation.CGPoint, bounds: Foundation.CGRect, of view: AnyObject) {
        MainActor.assumeIsolated {
            let view = view as! UIView
            view.bounds = bounds.uiRect
            view.layer.position = UIKit.CGPoint(x: Double(position.x), y: Double(position.y))
        }
    }

    override static func setTransform(_ transform: OpenQuartzCoreShims.CGAffineTransform, of view: AnyObject) {
        MainActor.assumeIsolated {
            (view as! UIView).transform = UIKit.CGAffineTransform(
                m11: Double(transform.a), m12: Double(transform.b),
                m21: Double(transform.c), m22: Double(transform.d),
                tX: Double(transform.tx), tY: Double(transform.ty)
            )
        }
    }

    override static func setBackgroundColor(_ color: Color.Resolved, of view: AnyObject) {
        MainActor.assumeIsolated {
            (view as! UIView).backgroundColor = UIColor(
                red: Double(color.red), green: Double(color.green),
                blue: Double(color.blue), alpha: Double(color.opacity)
            )
        }
    }

    override static func setOpacity(_ opacity: Float, of view: AnyObject) {
        MainActor.assumeIsolated { (view as! UIView).alpha = Double(opacity) }
    }

    override static func setCornerRadius(_ radius: Foundation.CGFloat, of view: AnyObject) {
        MainActor.assumeIsolated { (view as! UIView).layer.cornerRadius = Double(radius) }
    }

    override static func setIgnoresEvents(_ state: Bool, of view: AnyObject) {
        MainActor.assumeIsolated { (view as! UIView).isUserInteractionEnabled = !state }
    }
}

extension Foundation.CGRect {
    var uiRect: UIKit.CGRect {
        .init(x: Double(origin.x), y: Double(origin.y), width: Double(width), height: Double(height))
    }
}

extension UIKit.CGRect {
    var foundationRect: Foundation.CGRect {
        .init(x: origin.x, y: origin.y, width: width, height: height)
    }
}
#endif
