//
//  AccessibilityShims.swift
//  OpenSwiftUICore

#if !canImport(Accessibility)
public import Foundation

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
#endif
