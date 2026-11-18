#if UIKIT_CROSS_PLATFORM
import Foundation
import UIKit
import OpenQuartzCoreShims
@_spi(DisplayList_ViewSystem) import OpenSwiftUICore

class UIKitCrossPlatformView: UIView {
    // The shared cache requires layer identity; drawing uses UIKit's native layer.
    let displayListLayer = OpenQuartzCoreShims.CALayer()
}

private final class UIKitCrossPlatformShapeView: UIKitCrossPlatformView {
    let fillView = UIKitCrossPlatformGradientView(frame: .zero)

    override init(frame: UIKit.CGRect) {
        super.init(frame: frame)
        fillView.isUserInteractionEnabled = false
        addSubview(fillView)
    }
}

final class UIKitCrossPlatformViewDefinition: PlatformViewDefinition, @unchecked Sendable {
    override static var system: System { .uiView }

    override static func makeView(kind: ViewKind) -> AnyObject {
        MainActor.assumeIsolated {
            let view = kind == .shape ? UIKitCrossPlatformShapeView(frame: .zero) : UIKitCrossPlatformView(frame: .zero)
            view.layer.anchorPoint = .zero
            view.isUserInteractionEnabled = false
            return view
        }
    }

    override static func makeLayerView(type: OpenQuartzCoreShims.CALayer.Type, kind: ViewKind) -> AnyObject {
        makeView(kind: kind)
    }

    override static func makeDrawingView(options: PlatformDrawableOptions) -> any PlatformDrawable {
        MainActor.assumeIsolated { UIKitCrossPlatformDrawingView(options: options) }
    }

    override static func setShape(_ path: Path, color: Color.Resolved, style: FillStyle, of view: AnyObject) -> Bool {
        MainActor.assumeIsolated {
            guard let view = view as? UIKitCrossPlatformShapeView else { return false }
            let rect: Foundation.CGRect
            let radius: Foundation.CGFloat
            switch path.storage {
            case .empty:
                rect = .zero
                radius = 0
            case let .rect(bounds):
                rect = bounds
                radius = 0
            case let .ellipse(bounds) where bounds.width == bounds.height:
                rect = bounds
                radius = bounds.width / 2
            case let .roundedRect(rounded) where rounded.isUniform:
                rect = rounded.rect
                radius = rounded.clampedCornerRadius
            default:
                return false
            }
            view.fillView.frame = rect.uiRect
            view.fillView.layer.cornerRadius = Double(radius)
            view.fillView.gradient = nil
            setBackgroundColor(color, of: view.fillView)
            return true
        }
    }

    override static func setShape(
        _ path: Path,
        gradient: PlatformGradient,
        style: FillStyle,
        of view: AnyObject
    ) -> Bool {
        MainActor.assumeIsolated {
            guard let view = view as? UIKitCrossPlatformShapeView else { return false }
            switch path.storage {
            case .rect, .roundedRect, .ellipse, .empty:
                view.fillView.frame = path.boundingRect.isNull ? .zero : path.boundingRect.uiRect
                view.fillView.layer.cornerRadius = 0
                view.fillView.backgroundColor = .clear
                view.fillView.gradient = .init(path: path, paint: gradient, antialias: style.isAntialiased)
                return true
            default:
                return false
            }
        }
    }

    override static func viewLayer(_ view: AnyObject) -> OpenQuartzCoreShims.CALayer {
        MainActor.assumeIsolated { (view as! UIKitCrossPlatformView).displayListLayer }
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
        MainActor.assumeIsolated { (view as! UIView).clipsToBounds = clips || view is UIKitCrossPlatformDrawingView }
    }

    override static func setGeometry(position: Foundation.CGPoint, bounds: Foundation.CGRect, of view: AnyObject) {
        MainActor.assumeIsolated {
            let view = view as! UIView
            view.bounds = bounds.uiRect
            view.layer.position = UIKit.CGPoint(x: Double(position.x), y: Double(position.y))
            view.setNeedsLayout()
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
