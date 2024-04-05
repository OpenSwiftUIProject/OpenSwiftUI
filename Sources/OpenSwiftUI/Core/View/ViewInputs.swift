internal import OpenGraphShims

public struct _ViewInputs {
    var base: _GraphInputs
    var preferences: PreferencesInputs
    var transform: Attribute<ViewTransform>
    var position: Attribute<ViewOrigin>
    var containerPosition: Attribute<ViewOrigin>
    var size: Attribute<ViewSize>
    var safeAreaInsets: OptionalAttribute<SafeAreaInsets>
    
    @inline(__always)
    func detechedEnvironmentInputs() -> Self {
        var newInputs = self
        newInputs.base = self.base.detechedEnvironmentInputs()
        return newInputs
    }
}
