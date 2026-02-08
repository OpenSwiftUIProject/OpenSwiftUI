//
//  BackgroundStyle.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: C7D4771CFE453D905E7BCD5A907D32EB (SwiftUICore)

import OpenAttributeGraphShims

// MARK: - Color + background

@available(OpenSwiftUI_v1_0, *)
extension Color {
    private struct BackgroundColorProvider: ColorProvider {
        func resolve(in environment: EnvironmentValues) -> Color.Resolved {
            Color.systemBackgroundColor(
                info: environment.backgroundInfo,
                context: environment.backgroundContext,
                scheme: environment.colorScheme
            )
        }
    }

    package static var _background: Color {
        Color(provider: BackgroundColorProvider())
    }

    package static func systemBackgroundColor(
        info: BackgroundInfo,
        context: BackgroundContext,
        scheme: ColorScheme
    ) -> Color.Resolved {
        switch scheme {
        case .light:
            let combined = info.groupCount + context.rawValue
            if combined & 1 == 0 {
                return .white
            } else {
                return Color.Resolved(red: 242 / 255, green: 242 / 255, blue: 247 / 255)
            }
        case .dark:
            let level = info.layer + info.groupCount
            switch level {
            case 0:
                return .black
            case 1:
                return Color.Resolved(red: 28 / 255, green: 28 / 255, blue: 30 / 255)
            case 2:
                return Color.Resolved(red: 44 / 255, green: 44 / 255, blue: 46 / 255)
            default:
                return Color.Resolved(red: 58 / 255, green: 58 / 255, blue: 60 / 255)
            }
        }
    }
}

// MARK: - ShapeStyle + BackgroundStyle

@available(OpenSwiftUI_v2_0, *)
extension ShapeStyle where Self == BackgroundStyle {

    /// The background style in the current context.
    ///
    /// Access this value to get the style OpenSwiftUI uses for the background
    /// in the current context. The specific color that OpenSwiftUI renders depends
    /// on factors like the platform and whether the user has turned on Dark
    /// Mode.
    ///
    /// For information about how to use shape styles, see ``ShapeStyle``.
    @_alwaysEmitIntoClient
    public static var background: BackgroundStyle {
        .init()
    }
}

// MARK: - BackgroundStyle

/// The background style in the current context.
///
/// You can also use ``ShapeStyle/background`` to construct this style.
@available(OpenSwiftUI_v2_0, *)
@frozen
public struct BackgroundStyle: ShapeStyle {
    static let shared = AnyShapeStyle(BackgroundStyle())

    /// Creates a background style instance.
    @inlinable
    public init() {}

    nonisolated public static func _makeView<S>(view: _GraphValue<_ShapeView<S, BackgroundStyle>>, inputs: _ViewInputs) -> _ViewOutputs where S: Shape {
        legacyMakeShapeView(view: view, inputs: inputs)
    }

    private func base(level: Int, env: EnvironmentValues) -> some ShapeStyle {
        var info = env.backgroundInfo
        info.groupCount += level
        let resolved = Color.systemBackgroundColor(
            info: info,
            context: env.backgroundContext,
            scheme: env.colorScheme
        )
        return resolved
    }

    @available(OpenSwiftUI_v3_0, *)
    public func _apply(to shape: inout _ShapeStyle_Shape) {
        if !shape.activeRecursiveStyles.contains(.background) {
            if let style = shape.environment.currentBackgroundStyle {
                shape.activeRecursiveStyles.formUnion(.background)
                style._apply(to: &shape)
                if shape.activeRecursiveStyles.contains(.background) {
                    shape.activeRecursiveStyles.subtract(.background)
                }
                return
            }
        }
        switch shape.operation {
        case let .resolveStyle(name, _) where name == .background:
            HierarchicalShapeStyle.quaternary._apply(to: &shape)
        case let .resolveStyle(name, levels):
            guard !levels.isEmpty else { return }
            var pack = shape.stylePack
            for level in levels {
                var innerShape = shape
                base(level: level, env: shape.environment)._apply(to: &innerShape)
                let style = innerShape.stylePack[name, 0]
                shape.stylePack[name, level] = style
            }
            shape.result = .pack(shape.stylePack)
        case let .prepareText(level):
            base(level: level, env: shape.environment)._apply(to: &shape)
        case let .fallbackColor(level):
            base(level: level, env: shape.environment)._apply(to: &shape)
        case .copyStyle, .primaryStyle:
            shape.result = .style(AnyShapeStyle(BackgroundStyle()))
        case let .modifyBackground(level):
            shape.environment.backgroundInfo.groupCount += level
        case .multiLevel:
            shape.result = .bool(false)
        }
    }

    public static func _apply(to type: inout _ShapeStyle_ShapeType) {
        type.result = .bool(true)
    }
}

// MARK: - View + _addingBackgroundGroup / _addingBackgroundLayer

@available(OpenSwiftUI_v1_0, *)
extension View {

    /// Add a background group, affecting the default background color.
    @MainActor
    @preconcurrency
    public func _addingBackgroundGroup() -> some View {
        transformEnvironment(\.backgroundInfo) { $0.groupCount += 1 }
    }

    /// Add a background layer, affecting the default background color.
    @MainActor
    @preconcurrency
    public func _addingBackgroundLayer() -> some View {
        transformEnvironment(\.backgroundInfo) { $0.layer += 1 }
    }

    /// Sets the specified style to render backgrounds within the view.
    ///
    /// The following example uses this modifier to set the
    /// ``EnvironmentValues/backgroundStyle`` environment value to a
    /// ``ShapeStyle/blue`` color that includes a subtle ``Color/gradient``.
    /// OpenSwiftUI fills the ``Circle`` shape that acts as a background element
    /// with this style:
    ///
    ///     Image(systemName: "swift")
    ///         .padding()
    ///         .background(in: Circle())
    ///         .backgroundStyle(.blue.gradient)
    ///
    /// To restore the default background style, set the
    /// ``EnvironmentValues/backgroundStyle`` environment value to
    /// `nil` using the ``View/environment(_:_:)`` modifer:
    ///
    ///     .environment(\.backgroundStyle, nil)
    ///
    @available(OpenSwiftUI_v4_0, *)
    @inlinable
    nonisolated public func backgroundStyle<S>(_ style: S) -> some View where S: ShapeStyle {
        return modifier(_EnvironmentBackgroundStyleModifier(style: style))
    }
}


// MARK: - BackgroundStyleKey

private struct BackgroundStyleKey: EnvironmentKey {
    static let defaultValue: AnyShapeStyle? = nil
}

// MARK: - BackgroundContextKey

private struct BackgroundContextKey: EnvironmentKey {
    static let defaultValue: BackgroundContext = .normal
}

// MARK: - BackgroundInfoKey

private struct BackgroundInfoKey: EnvironmentKey {
    static let defaultValue = BackgroundInfo(layer: 0, groupCount: 0)
}

// MARK: - EnvironmentValues + BackgroundStyle

extension EnvironmentValues {

    /// An optional style that overrides the default system background
    /// style when set.
    @available(OpenSwiftUI_v4_0, *)
    public var backgroundStyle: AnyShapeStyle? {
        get { self[BackgroundStyleKey.self] }
        set { self[BackgroundStyleKey.self] = newValue }
    }

    package var currentBackgroundStyle: AnyShapeStyle? {
        backgroundStyle
    }

    package var effectiveBackgroundStyle: AnyShapeStyle {
        currentBackgroundStyle ?? BackgroundStyle.shared
    }

    package var backgroundContext: BackgroundContext {
        get { self[BackgroundContextKey.self] }
        set { self[BackgroundContextKey.self] = newValue }
    }

    package var backgroundInfo: BackgroundInfo {
        get { self[BackgroundInfoKey.self] }
        set { self[BackgroundInfoKey.self] = newValue }
    }
}

// MARK: - BackgroundContext

package enum BackgroundContext: Int, CaseIterable {
    case normal
    case grouped
}

// MARK: - BackgroundInfo

package struct BackgroundInfo: Equatable {
    package var layer: Int

    package var groupCount: Int

    package init(layer: Int, groupCount: Int) {
        self.layer = layer
        self.groupCount = groupCount
    }
}

// MARK: - _EnvironmentBackgroundStyleModifier

@available(OpenSwiftUI_v4_0, *)
@frozen
@MainActor
@preconcurrency
public struct _EnvironmentBackgroundStyleModifier<S>: ViewInputsModifier, PrimitiveViewModifier where S: ShapeStyle {
    @usableFromInline
    var style: S

    @inlinable
    init(style: S) {
        self.style = style
    }

    nonisolated public static func _makeViewInputs(
        modifier: _GraphValue<Self>, 
        inputs: inout _ViewInputs
    ) {
        _makeInputs(modifier: modifier, inputs: &inputs.base)
    }

    nonisolated private static func _makeInputs(
        modifier: _GraphValue<Self>,
        inputs: inout _GraphInputs
    ) {
        inputs.environment = Attribute(
            ChildEnvironment(
                modifier: modifier.value,
                environment: inputs.environment
            )
        )
    }

    nonisolated public static func _makeViewList(
        modifier: _GraphValue<Self>,
        inputs: _ViewListInputs,
        body: @escaping (_Graph, _ViewListInputs) -> _ViewListOutputs
    ) -> _ViewListOutputs {
        var inputs = inputs
        _makeInputs(modifier: modifier, inputs: &inputs.base)
        return body(_Graph(), inputs)
    }

    private struct ChildEnvironment: Rule, AsyncAttribute {
        @Attribute var modifier: _EnvironmentBackgroundStyleModifier
        @Attribute var environment: EnvironmentValues

        var value: EnvironmentValues {
            var environment = environment
            let style = modifier.style.copyStyle(name: .background, in: environment)
            environment.backgroundStyle = style
            return environment
        }
    }
}

@available(*, unavailable)
extension _EnvironmentBackgroundStyleModifier: Sendable {}
