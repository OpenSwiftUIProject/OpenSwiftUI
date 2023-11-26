#if os(iOS)
import CoreGraphics

@available(macOS, unavailable)
public protocol _UIHostingViewable: AnyObject {
    var rootView: AnyView { get set }
    func _render(seconds: Swift.Double)
    func _forEachIdentifiedView(body: (_IdentifiedViewProxy) -> Void)
    func sizeThatFits(in size: CGSize) -> CGSize
    var _disableSafeArea: Bool { get set }
//    var _rendererConfiguration: _RendererConfiguration { get set }
    var _rendererObject: AnyObject? { get }
}

//@available(macOS, unavailable)
//extension UIHostingController : _UIHostingViewable where Content == AnyView {
//}

@available(macOS, unavailable)
public func _makeUIHostingController(_ view: AnyView) -> NSObject & _UIHostingViewable {
    fatalError("TODO")

}

@available(macOS, unavailable)
public func _makeUIHostingController(_ view: AnyView, tracksContentSize: Swift.Bool) -> NSObject & _UIHostingViewable {
    fatalError("TODO")
}
#endif
