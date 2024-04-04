// TODO
struct SafeAreaInsets {
    var space: UniqueID
    var elements: [Element]
    var next: OptionalValue
    
    indirect enum OptionalValue {
        case insets(SafeAreaInsets)
        case empty
    }
    
    struct Element {
        var regions: SafeAreaRegions
        var insets: EdgeInsets
    }
}
