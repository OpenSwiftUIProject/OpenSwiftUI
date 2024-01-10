#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

class TestingAppDelegate: DelegateBaseClass {
    static var performanceTests: [_PerformanceTest]?
    
    #if os(iOS)
    static var connectCallback: ((UIWindow) -> Void)?
    #endif
}
