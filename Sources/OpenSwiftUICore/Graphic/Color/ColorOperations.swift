//
//  ColorOperations.swift
//  OpenSwiftUICore
//
//  Audited for iOS 18.0
//  Status: WIP
//  ID: B495DF025D9B78431A787E266E7D8FB1 (SwiftUI?)
//  ID: F28C5F7FF836E967BAC87540A3CB4F65 (SwiftUICore?)

extension Color {
    public func opacity(_ opacity: Double) -> Color {
        Color(provider: OpacityColor(base: self, opacity: opacity))        
    }
    
    private struct OpacityColor: ColorProvider {
        func resolve(in environment: EnvironmentValues) -> Color.Resolved {
            preconditionFailure("TODO")
        }
        
        var base: Color
        var opacity: Double
    }
    
    // TODO
}

// TODO
