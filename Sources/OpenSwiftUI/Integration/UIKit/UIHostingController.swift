#if os(iOS)
import UIKit

@available(macOS, unavailable)
@available(watchOS, unavailable)
@MainActor(unsafe)
open class UIHostingController<Content> : UIViewController where Content : View {
    override open dynamic var keyCommands: [UIKeyCommand]? {
        fatalError("Unimplemented")
    }
}
#endif
