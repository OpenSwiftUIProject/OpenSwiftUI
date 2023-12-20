import _OpenGraph

public func compareValues<Value>(_ lhs: Value, _ rhs: Value, mode: OGComparisonMode = ._3) -> Bool {
    withUnsafePointer(to: lhs) { p1 in
        withUnsafePointer(to: rhs) { p2 in
            withUnsafePointer(to: Value.self) { metatype in
                OGCompareValues(p1, p2, metatype, mode)
            }
        }
    }
}
