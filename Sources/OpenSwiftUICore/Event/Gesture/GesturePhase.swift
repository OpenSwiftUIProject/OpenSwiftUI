//
//  GesturePhase.swift
//  OpenSwiftUICore
//
//  Status: Complete

// MARK: - GesturePhase [6.5.4]

@_spi(ForOnlySwiftUIOnly)
@available(OpenSwiftUI_v6_0, *)
public enum GesturePhase<Wrapped> {
    case possible(Wrapped?)
    case active(Wrapped)
    case ended(Wrapped)
    case failed
}

@_spi(ForOnlySwiftUIOnly)
@available(*, unavailable)
extension GesturePhase: Sendable {}

@_spi(ForOnlySwiftUIOnly)
extension GesturePhase: Equatable where Wrapped: Equatable {
    
//    public static func == (
//        a: GesturePhase<Wrapped>,
//        b: GesturePhase<Wrapped>
//    ) -> Bool {
//        preconditionFailure("TODO")
//    }
}

//@_spi(ForOnlySwiftUIOnly)
//extension GesturePhase {
//    
//    package var unwrapped: Wrapped? {
//        
//        get { preconditionFailure("TODO") }
//    }
//
//    
//    package func map<T>(_ body: (Wrapped) -> T) -> GesturePhase<T> {
//        preconditionFailure("TODO")
//    }
//
//    
//    package func withValue<T>(_ value: @autoclosure () -> T) -> GesturePhase<T> {
//        preconditionFailure("TODO")
//    }
//
//    
//    package var isPossible: Bool {
//        
//        get { preconditionFailure("TODO") }
//    }
//
//    
//    package var isActive: Bool {
//        
//        get { preconditionFailure("TODO") }
//    }
//
//    
//    package var isTerminal: Bool {
//        
//        get { preconditionFailure("TODO") }
//    }
//
//    
//    package var isEnded: Bool {
//        
//        get { preconditionFailure("TODO") }
//    }
//
//    
//    package var isFailed: Bool {
//        
//        get { preconditionFailure("TODO") }
//    }
//}
//@_spi(ForOnlySwiftUIOnly)
//
//extension GesturePhase: Defaultable {
//    
//    package static var defaultValue: GesturePhase<Wrapped> {
//        
//        get { preconditionFailure("TODO") }
//    }
//
//    
//    package typealias Value = GesturePhase<Wrapped>
//}
//
//@_spi(ForOnlySwiftUIOnly)
//
//extension GestureCategory: Defaultable {
//    
//    package static var defaultValue: GestureCategory {
//        
//        get { preconditionFailure("TODO") }
//    }
//
//    
//    package typealias Value = GestureCategory
//}
