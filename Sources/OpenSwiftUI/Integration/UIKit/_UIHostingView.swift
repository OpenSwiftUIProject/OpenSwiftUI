#if os(iOS)
import UIKit

@available(macOS, unavailable)
@available(watchOS, unavailable)
@MainActor(unsafe)
open class _UIHostingView<Content>: UIView where Content: View {
    @available(macOS, unavailable)
    @available(watchOS, unavailable)
    final public func _viewDebugData() -> [_ViewDebug.Data] {
        // TODO
        []
    }
}
#endif
