//
//  InterfaceIdiomPredicate.swift
//  OpenSwiftUICore
//
//  Audited for iOS 18.0
//  Status: Complete

package struct InterfaceIdiomPredicate<Idiom>: ViewInputPredicate where Idiom: InterfaceIdiom {
    package init() {}
    
    package static func evaluate(inputs: _GraphInputs) -> Bool {
        inputs.interfaceIdiom.accepts(Idiom.self)
    }
}

package struct InterfaceIdiomInput: ViewInput {
    package static let defaultValue: AnyInterfaceIdiom? = nil
}

extension _GraphInputs {
    package var interfaceIdiom: AnyInterfaceIdiom {
        self[InterfaceIdiomInput.self] ?? _GraphInputs.defaultInterfaceIdiom
    }
    
    package static var defaultInterfaceIdiom: AnyInterfaceIdiom {
        #if os(macOS)
        if isAppKitBased() {
            AnyInterfaceIdiom(.mac)
        } else {
            AnyInterfaceIdiom(.pad)
        }
        #elseif os(iOS)
        AnyInterfaceIdiom(.phone)
        #else
        fatalError("TODO")
        #endif
    }
}

extension AnyInterfaceIdiom {
    package static func ~= (pattern: some InterfaceIdiom, value: AnyInterfaceIdiom) -> Bool {        
        value == AnyInterfaceIdiom(pattern)
    }
}
