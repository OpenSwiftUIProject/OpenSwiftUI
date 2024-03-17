protocol ViewRendererHost {}

extension ViewRendererHost {
    func invalidateProperties(_ properties: ViewRendererHostProperties, mayDeferUpdate: Bool) {
        fatalError("TODO")
    }
    
    func startProfiling() {
        fatalError("TODO")
    }
    
    func stopProfiling() {
        fatalError("TODO")
    }
}


struct ViewRendererHostProperties: OptionSet {
    let rawValue: UInt16
}
