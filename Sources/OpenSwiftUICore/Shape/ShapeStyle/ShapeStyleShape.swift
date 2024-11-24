//
//  ShapeStyle_Shape.swift
//  OpenSwiftUICore
//
//  Audited for iOS 18.0
//  Status: Blocked by Color / ColorProvider / Color.Resolved

package import Foundation

// MARK: - _ShapeStyle_Shape

public struct _ShapeStyle_Shape {
    package enum Operation {
        case prepareText(level: Int)
        case resolveStyle(name: _ShapeStyle_Name, levels: Range<Int>)
        case multiLevel
        case fallbackColor(level: Int)
        case copyStyle(name: _ShapeStyle_Name)
        case primaryStyle
        case modifyBackground(level: Int)
    }
    
    package enum Result {
        case none
        case preparedText(PreparedTextResult)
        case pack(_ShapeStyle_Pack)
        case style(AnyShapeStyle)
        case color(Color)
        case bool(Bool)
    }
    
    package enum PreparedTextResult {
        case foregroundKeyColor
        case foregroundColor(Color)
    }
    
    package var operation: Operation
    package var result: Result
    package var environment: EnvironmentValues
    package var foregroundStyle: AnyShapeStyle?
    package var bounds: CGRect?
    package var role: ShapeRole

    package init(
        operation: Operation,
        result: Result = .none,
        environment: EnvironmentValues = .init(),
        foregroundStyle: AnyShapeStyle? = nil,
        bounds: CGRect? = nil,
        role: ShapeRole = .fill
    ) {
        self.operation = operation
        self.result = result
        self.environment = environment
        self.foregroundStyle = foregroundStyle
        self.bounds = bounds
        self.role = role
    }

    package struct RecursiveStyles: OptionSet {
        package let rawValue: UInt8
        package init(rawValue: UInt8) {
            self.rawValue = rawValue
        }
        
        package static let content: RecursiveStyles = .init(rawValue: 1 << 0)
        package static let foreground: RecursiveStyles = .init(rawValue: 1 << 1)
        package static let background: RecursiveStyles = .init(rawValue: 1 << 2)
    }
    
    package var activeRecursiveStyles: RecursiveStyles = []
    
    package func opacity(at level: Int) -> Float {
        // Blocked by Color
        preconditionFailure("TODO")
    }
    
    package func opacity(for color: Color, at level: Int) -> Float {
        // Blocked by Color
        preconditionFailure("TODO")
    }
    package func applyingOpacity(at level: Int, to color: Color) -> Color {
        // Blocked by Color
        preconditionFailure("TODO")
    }
    
    package func applyingOpacity(at level: Int, to color: Color.Resolved) -> Color.Resolved {
        // Blocked by Color
        preconditionFailure("TODO")
    }
    
    package var currentForegroundStyle: AnyShapeStyle? {
        environment.currentForegroundStyle
    }
    
    package var effectiveForegroundStyle: AnyShapeStyle {
        environment._effectiveForegroundStyle
    }
}

@available(*, unavailable)
extension _ShapeStyle_Shape: Sendable {}

// MARK: - _ShapeStyle_ShapeType

public struct _ShapeStyle_ShapeType {
    package enum Operation {
        case modifiesBackground
    }
    
    package enum Result {
        case none
        case bool(Bool)
    }
    
    package var operation: Operation
    package var result: Result
}

@available(*, unavailable)
extension _ShapeStyle_ShapeType: Sendable {}
