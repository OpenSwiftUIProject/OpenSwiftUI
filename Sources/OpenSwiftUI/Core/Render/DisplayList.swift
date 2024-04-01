// FIXME
struct DisplayList {}

// FIXME
extension DisplayList {
    struct Key: PreferenceKey {
        static var defaultValue: Void = ()

        static func reduce(value _: inout Void, nextValue _: () -> Void) {}

        typealias Value = Void
    }
}
