//
//  DisplayList.ViewUpdater.swift
//  OpenSwiftUICore
//
//  Audited for iOS 18.0
//  Status: WIP

extension DisplayList {
    // FIXME
    final package class ViewUpdater: ViewRendererBase {
        init() {
            preconditionFailure("")
        }
        
        init(platform: Platform, exportedObject: AnyObject? = nil, viewCacheIsEmpty: Bool) {
            self.platform = platform
            self.exportedObject = exportedObject
            self.viewCacheIsEmpty = viewCacheIsEmpty
        }
        
        var platform: Platform
        
        var exportedObject: AnyObject?
        
        func render(rootView: AnyObject, from list: DisplayList, time: Time, version: DisplayList.Version, maxVersion: DisplayList.Version, environment: DisplayList.ViewRenderer.Environment) -> Time {
            .zero
        }
        
        func renderAsync(to list: DisplayList, time: Time, targetTimestamp: Time?, version: DisplayList.Version, maxVersion: DisplayList.Version) -> Time? {
            nil
        }
        
        func destroy(rootView: AnyObject) {
        }
        
        var viewCacheIsEmpty: Bool
    }
}
