extension ClosedRange where Bound: Strideable {
    var minimumValue: AccessibilityNumeric? {
        guard let value = lowerBound as? AccessibilityNumeric,
              value.isValidMinValue else {
            return nil
        }
        return value
    }

    var maximumValue: AccessibilityNumeric? {
        guard let value = upperBound as? AccessibilityNumeric,
              value.isValidMaxValue else {
            return nil
        }
        return value
    }
}
