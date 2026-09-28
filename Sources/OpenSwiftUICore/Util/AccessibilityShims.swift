//
//  AccessibilityShims.swift
//  OpenSwiftUICore

#if !canImport(Accessibility)
public import Foundation

// MARK: - AXChartDescriptor

public final class AXChartDescriptor: NSObject {
    private let dictionary: [AnyHashable: Any]

    init(dictionary: [AnyHashable: Any]) {
        self.dictionary = dictionary
        super.init()
    }

    func dictionaryRepresentation() -> [AnyHashable: Any] {
        dictionary
    }
}

func _AXOpenSwiftUIUnarchiveChartDescriptor(_ data: Data) -> Any? {
    try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data)
}

// MARK: - AXCustomContent

extension AXCustomContent {
    public enum Importance: UInt, @unchecked Sendable {
        case `default` = 0
        case high = 1
    }
}

open class AXCustomContent: NSObject, NSCopying, NSSecureCoding {
    private var _label: String?
    private var _attributedLabel: NSAttributedString?
    private var _value: String?
    private var _attributedValue: NSAttributedString?

    public init(label: String, value: String) {
        _label = label
        _value = value
        super.init()
    }

    public init(attributedLabel label: NSAttributedString, attributedValue value: NSAttributedString) {
        _attributedLabel = label.copy() as? NSAttributedString
        _attributedValue = value.copy() as? NSAttributedString
        super.init()
    }

    open var label: String {
        _label ?? _attributedLabel?.string ?? ""
    }

    open var attributedLabel: NSAttributedString {
        _attributedLabel ?? NSAttributedString(string: label)
    }

    open var value: String {
        _value ?? _attributedValue?.string ?? ""
    }

    open var attributedValue: NSAttributedString {
        _attributedValue ?? NSAttributedString(string: value)
    }

    open var importance: Importance = .default

    open func copy(with zone: NSZone? = nil) -> Any {
        // The platform implementation preserves object identity when copied.
        self
    }

    open class var supportsSecureCoding: Bool {
        true
    }

    public required init?(coder: NSCoder) {
        _label = coder.decodeObject(of: NSString.self, forKey: "label") as String?
        _attributedLabel = coder.decodeObject(of: NSAttributedString.self, forKey: "attributedLabel")?.copy() as? NSAttributedString
        _value = coder.decodeObject(of: NSString.self, forKey: "value") as String?
        _attributedValue = coder.decodeObject(of: NSAttributedString.self, forKey: "attributedValue")?.copy() as? NSAttributedString
        importance = Importance(rawValue: UInt(bitPattern: coder.decodeInteger(forKey: "importance"))) ?? .default
        super.init()
    }

    open func encode(with coder: NSCoder) {
        coder.encode(label, forKey: "label")
        coder.encode(attributedLabel, forKey: "attributedLabel")
        coder.encode(value, forKey: "value")
        coder.encode(attributedValue, forKey: "attributedValue")
        coder.encode(Int(importance.rawValue), forKey: "importance")
    }

    open override func isEqual(_ object: Any?) -> Bool {
        guard let other = object as? AXCustomContent else {
            return false
        }
        return (label as NSString).isEqual(to: other.label)
            && (value as NSString).isEqual(to: other.value)
            && attributedLabel.isEqual(to: other.attributedLabel)
            && attributedValue.isEqual(to: other.attributedValue)
            && importance == other.importance
    }

    open override var hash: Int {
        var hasher = Hasher()
        hasher.combine((label as NSString).hash)
        hasher.combine((value as NSString).hash)
        hasher.combine(attributedLabel.hash)
        hasher.combine(attributedValue.hash)
        hasher.combine(importance)
        return hasher.finalize()
    }
}
#endif
