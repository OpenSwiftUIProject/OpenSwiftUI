//
//  DisplayList.ViewUpdater.swift
//  OpenSwiftUICore
//
//  Audited for iOS 18.0
//  Status: WIP
//  ID: B86250B2E056EB47628ECF46032DFA4C (SwiftUICore)

private var printTree: Bool?

extension DisplayList {
    // FIXME
    final package class ViewUpdater: ViewRendererBase {
        init() {
            // preconditionFailure("TODO")
            platform = .init(rawValue: 0)
            exportedObject = nil
            viewCacheIsEmpty = false
        }
        
        init(platform: Platform, exportedObject: AnyObject? = nil, viewCacheIsEmpty: Bool) {
            self.platform = platform
            self.exportedObject = exportedObject
            self.viewCacheIsEmpty = viewCacheIsEmpty
        }
        
        var platform: Platform
        
        var exportedObject: AnyObject?
        
        func render(rootView: AnyObject, from list: DisplayList, time: Time, version: DisplayList.Version, maxVersion: DisplayList.Version, environment: DisplayList.ViewRenderer.Environment) -> Time {
            // TODO
            if printTree == nil {
                printTree = ProcessEnvironment.bool(forKey: "OPENSWIFTUI_PRINT_TREE")
            }
            if let printTree, printTree {
                print("View \(Unmanaged.passUnretained(rootView).toOpaque()) at \(time):\n\(list.description)")
            }
            return .zero
        }
        
        func renderAsync(to list: DisplayList, time: Time, targetTimestamp: Time?, version: DisplayList.Version, maxVersion: DisplayList.Version) -> Time? {
            nil
        }
        
        func destroy(rootView: AnyObject) {
        }
        
        var viewCacheIsEmpty: Bool
    }
}
