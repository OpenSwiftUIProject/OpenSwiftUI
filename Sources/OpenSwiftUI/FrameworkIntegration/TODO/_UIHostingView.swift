#if os(iOS) || os(tvOS)
import UIKit

@available(macOS, unavailable)
@available(watchOS, unavailable)
open class _UIHostingView<Content>: UIView where Content: View {
    public final func _viewDebugData() -> [_ViewDebug.Data] {
        // viewGraph._viewDebugData()
        []
    }
}
#endif
