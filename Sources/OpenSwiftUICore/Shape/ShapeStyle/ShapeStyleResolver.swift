//
//  ShapeStyleResolver.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete

package import Foundation
package import OpenAttributeGraphShims

// MARK: ShapeStyleResolverMode

package struct _ShapeStyle_ResolverMode: Equatable {
    package var bundle: Bundle?

    package var foregroundLevels: UInt16

    package struct Options: OptionSet {
        package let rawValue: UInt8
        package init(rawValue: UInt8) { self.rawValue = rawValue }

        package static let foregroundPalette: Options = .init(rawValue: 1 << 0)

        package static let background: Options = .init(rawValue: 1 << 1)

        package static let multicolor: Options = .init(rawValue: 1 << 2)
    }

    package var options: Options

    package init(foregroundLevels: UInt16 = 0, options: Options = .init()) {
        self.bundle = nil
        self.foregroundLevels = foregroundLevels
        self.options = options
    }

    package init(rbSymbolStyleMask mask: UInt32, location: Image.Location) {
        let bundle: Bundle?
        var options: Options
        if mask & (1 << 9) != 0 {
            options = .multicolor
            bundle = location.bundle
        } else {
            options = []
            bundle = nil
        }
        let foregroundLevels: UInt16
        let hasForegroundPalette: Bool
        if mask & (1 << 8) != 0 {
            foregroundLevels = 5
            hasForegroundPalette = true
        } else if mask & (1 << 7) != 0 {
            foregroundLevels = 4
            hasForegroundPalette = true
        } else if mask & (1 << 6) != 0 {
            foregroundLevels = 3
            hasForegroundPalette = true
        } else if mask & (1 << 5) != 0 {
            foregroundLevels = 2
            hasForegroundPalette = true
        } else if mask & (1 << 0) != 0 {
            foregroundLevels = 1
            hasForegroundPalette = false
        } else {
            foregroundLevels = 0
            hasForegroundPalette = false
        }
        if hasForegroundPalette {
            options.formUnion(.foregroundPalette)
        }
        self.bundle = bundle
        self.foregroundLevels = foregroundLevels
        self.options = options
    }

    package mutating func formUnion(_ rhs: _ShapeStyle_ResolverMode) {
        bundle = bundle ?? rhs.bundle
        foregroundLevels = max(foregroundLevels, rhs.foregroundLevels)
        options.formUnion(rhs.options)
    }
}

// MARK: ShapeStyleResolver

package struct ShapeStyleResolver<Style>: StatefulRule, AsyncAttribute, ObservedAttribute where Style: ShapeStyle {
    @OptionalAttribute var style: Style?
    @OptionalAttribute var mode: ShapeStyle.ResolverMode?
    @Attribute var environment: EnvironmentValues
    var role: ShapeRole
    var animationsDisabled: Bool
    var helper: AnimatableAttributeHelper<ShapeStyle.Pack>
    let tracker: PropertyList.Tracker
    
    package typealias Value = ShapeStyle.Pack

    package init(
        style: OptionalAttribute<Style> = .init(),
        mode: OptionalAttribute<_ShapeStyle_ResolverMode> = .init(),
        environment: Attribute<EnvironmentValues>,
        role: ShapeRole,
        animationsDisabled: Bool,
        helper: AnimatableAttributeHelper<ShapeStyle.Pack>
    ) {
        self._style = style
        self._mode = mode
        self._environment = environment
        self.role = role
        self.animationsDisabled = animationsDisabled
        self.helper = helper
        self.tracker = .init()
    }
    
    package mutating func updateValue() {
        let (style, styleChanged) = $style?.changedValue() ?? (nil, false)
        let (mode, modeChanged) = $mode?.changedValue() ?? (.init(foregroundLevels: 1), false)
        let (environment, envChanged) = $environment.changedValue()

        var requiresUpdate = styleChanged || modeChanged || !hasValue || (envChanged && tracker.hasDifferentUsedValues(environment.plist))
        let shouldReset: Bool
        if helper.isAnimating {
            shouldReset = requiresUpdate
        } else {
            requiresUpdate = requiresUpdate || helper.checkReset()
            guard requiresUpdate else {
                return
            }
            shouldReset = true
        }
        if shouldReset {
            tracker.reset()
        }
        let effectiveLevels: Int
        if mode.options.contains(.foregroundPalette) {
            effectiveLevels = Int(mode.foregroundLevels)
        } else {
            effectiveLevels = mode.foregroundLevels > 0 ? 1 : 0
        }

        let newEnvironment = EnvironmentValues(environment.plist, tracker: tracker)
        var shape = _ShapeStyle_Shape(
            operation: .resolveStyle(name: .foreground, levels: 0 ..< effectiveLevels),
            environment: newEnvironment,
            role: role
        )
        if effectiveLevels == 0 {
            if shouldReset {
                helper.reset()
            }
        } else {
            if let style {
                style._apply(to: &shape)
            } else {
                ForegroundStyle()._apply(to: &shape)
            }
            if !mode.options.contains(.foregroundPalette) {
                shape.stylePack.createOpacities(
                    count: Int(mode.foregroundLevels),
                    name: .foreground,
                    environment: newEnvironment
                )
            }
        }
        if mode.options.contains(.background) {
            shape.operation = .resolveStyle(name: .background, levels: 0 ..< 1)
            shape.role = .fill
            BackgroundStyle()._apply(to: &shape)
        }
        var styles = shape.stylePack
        if mode.options.contains(.multicolor) {
            let multicolor = ResolvedMulticolorStyle(in: newEnvironment, bundle: mode.bundle)
            styles[.multicolor, 0] = .init(.multicolor(multicolor))
        }
        if !animationsDisabled {
            var animValue = (value: styles, changed: requiresUpdate)
            helper.update(
                value: &animValue,
                defaultAnimation: nil,
                environment: $environment
            )
            styles = animValue.value
            requiresUpdate = animValue.changed
        }
        if requiresUpdate {
            value = styles
        }
    }
    
    package mutating func destroy() {
        helper.removeListeners()
    }
}
