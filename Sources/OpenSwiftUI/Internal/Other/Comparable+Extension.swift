extension Comparable {
    func clamped(to range: ClosedRange<Self>) -> Self {
        var value = self
        value.clamp(to: range)
        return value
    }

    mutating func clamp(to range: ClosedRange<Self>) {
        self = OpenSwiftUI.clamp(self, min: range.lowerBound, max: range.upperBound)
    }
}

func clamp<Value: Comparable>(_ value: Value, min minValue: Value, max maxValue: Value) -> Value {
    if value < minValue {
        minValue
    } else if value > maxValue {
        maxValue
    } else {
        value
    }
}
