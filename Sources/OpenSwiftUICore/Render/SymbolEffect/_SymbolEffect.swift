//
//  _SymbolEffect.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: 2975F89CBD28662DFA5DA6D958CBE343 (SwiftUICore)

import OpenAttributeGraphShims
package import OpenRenderBoxShims

// MARK: - _SymbolEffect

package struct _SymbolEffect: Equatable {
    package enum Storage: Equatable {
        case pulse(_SymbolEffect.PulseConfiguration)
        case breathe(_SymbolEffect.BreatheConfiguration)
        case bounce(_SymbolEffect.BounceConfiguration)
        case wiggle(_SymbolEffect.WiggleConfiguration)
        case rotate(_SymbolEffect.RotateConfiguration)
        case variableColor(_SymbolEffect.VariableColorConfiguration)
        case scale(_SymbolEffect.ScaleConfiguration)
        case hidden(_SymbolEffect.HiddenConfiguration)
        case none
    }

    package enum Trigger: Equatable {
        case value(AnyEquatable)
        case condition(Bool)

        package func activates(after oldTrigger: _SymbolEffect.Trigger?) -> Bool {
            guard let oldTrigger else {
                return false
            }
            switch (self, oldTrigger) {
            case let (.value(newValue), .value(oldValue)):
                return oldValue != newValue
            case let (.condition(newValue), .condition(oldValue)):
                return !oldValue && newValue
            default:
                return false
            }
        }
    }

    package struct Options: Equatable {
        package var speed: Float

        package var repeatCount: Float?

        package var repeatDelay: Float?

        package init() {
            speed = 1.0
            repeatCount = nil
            repeatDelay = nil
        }
    }

    package var storage: _SymbolEffect.Storage

    package var options: _SymbolEffect.Options

    package init(
        _ storage: _SymbolEffect.Storage,
        options: _SymbolEffect.Options = .init()
    ) {
        self.storage = storage
        self.options = options
    }

    package struct PulseConfiguration: Equatable {
        package var trigger: _SymbolEffect.Trigger?

        package var layered: Bool

        package init() {
            trigger = nil
            layered = true
        }
    }

    package struct BreatheConfiguration: Equatable {
        package var trigger: _SymbolEffect.Trigger?

        package var flags: ORBSymbolAnimation.BreatheOptions

        package var layered: Bool

        package init() {
            trigger = nil
            flags = []
            layered = true
        }
    }

    package struct BounceConfiguration: Equatable {
        package var trigger: _SymbolEffect.Trigger?

        package var flags: ORBSymbolAnimation.BounceOptions

        package var layered: Bool

        package init() {
            trigger = nil
            flags = []
            layered = true
        }
    }

    package struct WiggleConfiguration: Equatable {
        package var trigger: _SymbolEffect.Trigger?

        package var angle: Angle?

        package var flags: ORBSymbolAnimation.WiggleOptions

        package var layered: Bool

        package var appliesRTL: Bool

        package init() {
            trigger = nil
            angle = nil
            flags = []
            layered = true
            appliesRTL = false
        }
    }

    package struct RotateConfiguration: Equatable {
        package var trigger: _SymbolEffect.Trigger?

        package var flags: ORBSymbolAnimation.RotateOptions

        package var layered: Bool

        package init() {
            trigger = nil
            flags = []
            layered = true
        }
    }

    package struct VariableColorConfiguration: Equatable {
        package var trigger: _SymbolEffect.Trigger?

        package var flags: ORBSymbolAnimation.VariableColorOptions

        package init() {
            trigger = nil
            flags = []
        }
    }

    package struct ScaleConfiguration: Equatable {
        package var level: ORBSymbolScaleLevel

        package var layered: Bool

        package init() {
            level = .normal
            layered = true
        }
    }

    package struct HiddenConfiguration: Equatable {
        package var flags: ORBSymbolAnimation.AppearDisappearOptions

        package var layered: Bool

        package var isHidden: Bool

        package init() {
            flags = []
            layered = true
            isHidden = false
        }

        package var transitionFlags: ORBSymbolAnimation.AppearDisappearOptions {
            layered ? flags : flags.union(.wholeSymbol)
        }
    }

    package struct ReplaceConfiguration: Equatable {
        package var flags: ORBSymbolAnimation.ReplaceOptions

        package var layered: Bool

        package var speed: Float

        package init() {
            flags = []
            layered = true
            speed = 1.0
        }

        package var transitionFlags: ORBSymbolAnimation.ReplaceOptions {
            layered ? flags : flags.union(.wholeSymbol)
        }
    }
}

extension _SymbolEffect {
    package struct Identified: Equatable {
        package var identifier: Int

        package var serial: Int

        package var effect: _SymbolEffect

        package init(identifier: Int, serial: Int = 0, effect: _SymbolEffect) {
            self.identifier = identifier
            self.serial = serial
            self.effect = effect
        }
    }

    package struct Phase: Equatable {
        fileprivate var added: [_SymbolEffect.Added]

        fileprivate var scale: _SymbolEffect.ScaleConfiguration

        fileprivate var scaleOptions: _SymbolEffect.Options

        fileprivate var hidden: _SymbolEffect.HiddenConfiguration

        fileprivate var hiddenOptions: _SymbolEffect.Options

        fileprivate var isFirstUpdate: Bool

        package init() {
            added = []
            scale = .init()
            scaleOptions = .init()
            hidden = .init()
            hiddenOptions = .init()
            isFirstUpdate = true
        }
    }

    fileprivate struct Added: Equatable {
        var identifier: Int

        var serial: Int

        var effect: _SymbolEffect.Storage

        var animationID: UInt32

        var priority: Float
    }

    fileprivate mutating func applyLayoutDirection(from environment: EnvironmentValues) {
        guard case var .wiggle(configuration) = storage,
              configuration.appliesRTL,
              environment.layoutDirection == .rightToLeft else {
            return
        }
        let direction = configuration.flags.intersection(.directionMask)
        configuration.flags.subtract(.directionMask)
        switch direction {
        case [], .forward:
            configuration.flags.formUnion(.backward)
        case .backward:
            configuration.flags.formUnion(.forward)
        default:
            break
        }
        configuration.appliesRTL = false
        storage = .wiggle(configuration)
    }
}

extension _SymbolEffect.Storage {
    fileprivate var trigger: _SymbolEffect.Trigger? {
        get {
            switch self {
            case let .pulse(configuration): configuration.trigger
            case let .breathe(configuration): configuration.trigger
            case let .bounce(configuration): configuration.trigger
            case let .wiggle(configuration): configuration.trigger
            case let .rotate(configuration): configuration.trigger
            case let .variableColor(configuration): configuration.trigger
            case .scale, .hidden, .none: nil
            }
        }
        set {
            switch self {
            case var .pulse(configuration):
                configuration.trigger = newValue
                self = .pulse(configuration)
            case var .breathe(configuration):
                configuration.trigger = newValue
                self = .breathe(configuration)
            case var .bounce(configuration):
                configuration.trigger = newValue
                self = .bounce(configuration)
            case var .wiggle(configuration):
                configuration.trigger = newValue
                self = .wiggle(configuration)
            case var .rotate(configuration):
                configuration.trigger = newValue
                self = .rotate(configuration)
            case var .variableColor(configuration):
                configuration.trigger = newValue
                self = .variableColor(configuration)
            case .scale, .hidden, .none:
                break
            }
        }
    }
}

// MARK: - EnvironmentValues + symbolEffects

extension EnvironmentValues {
    private struct SymbolEffectsKey: EnvironmentKey {
        static let defaultValue: [_SymbolEffect.Identified] = []
    }

    package var symbolEffects: [_SymbolEffect.Identified] {
        get { self[SymbolEffectsKey.self] }
        set { self[SymbolEffectsKey.self] = newValue }
    }

    package mutating func appendSymbolEffect(
        _ effect: _SymbolEffect,
        for identifier: Int
    ) {
        var effect = effect
        effect.applyLayoutDirection(from: self)
        symbolEffects.append(.init(identifier: identifier, effect: effect))
    }
}

// MARK: - GraphicsImage + updateSymbolEffects

extension GraphicsImage {
    mutating func updateSymbolEffects(
        _ phase: inout _SymbolEffect.Phase,
        environment: EnvironmentValues,
        transaction: Attribute<Transaction>,
        animationsDisabled: Bool
    ) -> ORBSymbolAnimator? {
        guard case var .vectorGlyph(glyph) = contents else {
            return nil
        }
        let animator = glyph.animator
        animator.updateSymbolEffects(
            &phase,
            effects: environment.symbolEffects,
            transaction: transaction,
            animationsDisabled: animationsDisabled
        )
        glyph.animatorVersion = animator.version
        glyph.allowsContentTransitions = glyph.allowsContentTransitions && !phase.hidden.isHidden
        contents = .vectorGlyph(glyph)
        return animator
    }
}

// MARK: - ORBSymbolAnimator + SymbolEffect

extension ORBSymbolAnimator {
    fileprivate func updateSymbolEffects(
        _ phase: inout _SymbolEffect.Phase,
        effects: [_SymbolEffect.Identified],
        transaction: Attribute<Transaction>,
        animationsDisabled: Bool
    ) {
        guard !phase.added.isEmpty
            || phase.scale.level != .normal
            || phase.hidden.isHidden
            || !effects.isEmpty
        else {
            return
        }
        let currentTransaction = Graph.withoutUpdate { transaction.value }
        let disablesAnimations = currentTransaction.disablesAnimations
        let animationListener = currentTransaction.animationListener
        let logicalListener = currentTransaction.animationLogicalListener

        var matched = BitVector(count: phase.added.count)
        var unmatchedCount = phase.added.count
        var added: [_SymbolEffect.Added] = []
        var scale = phase.scale
        scale.level = .normal
        var scaleOptions = phase.scaleOptions
        var hidden = phase.hidden
        hidden.isHidden = false
        var hiddenOptions = phase.hiddenOptions
        var priority: Float = 0

        for identified in effects {
            let storage = identified.effect.storage
            let options = identified.effect.options
            switch storage {
            case let .scale(configuration):
                scale = configuration
                scaleOptions = options
                continue
            case let .hidden(configuration):
                hidden = configuration
                hiddenOptions = options
                continue
            default:
                break
            }
            let trigger = storage.trigger
            var isNew = true
            if let index = phase.added.firstIndex(where: {
                $0.identifier == identified.identifier && $0.serial == identified.serial
            }) {
                var old = phase.added[index]
                matched[index] = true
                unmatchedCount -= 1
                let restarts: Bool
                if let trigger {
                    restarts = storage.hasSameCase(as: old.effect)
                        && trigger.activates(after: old.effect.trigger)
                } else {
                    restarts = storage != old.effect
                }
                if !restarts {
                    if old.animationID != 0 {
                        if old.priority != priority {
                            old.priority = priority
                            setPriority(priority, ofAnimationWithID: old.animationID)
                        }
                        priority += 1
                    }
                    old.effect.trigger = trigger
                    added.append(old)
                    continue
                }
                if old.animationID != 0 {
                    cancelAnimation(withID: old.animationID)
                }
                isNew = false
            }

            var animationID: UInt32 = 0
            var animationPriority: Float = .nan
            if !animationsDisabled, trigger == nil || (!isNew && !disablesAnimations) {
                var animationOptions: [ORBSymbolAnimation.OptionKey: Any] = [:]
                let animation: ORBSymbolAnimation?
                switch storage {
                case let .pulse(configuration):
                    animationOptions[.byLayer] = configuration.layered
                    animation = .pulse
                case let .breathe(configuration):
                    animationOptions[.byLayer] = configuration.layered
                    animationOptions[.breatheOptions] = configuration.flags.rawValue
                    animation = .breathe
                case let .bounce(configuration):
                    animationOptions[.bounceOptions] = configuration.flags.rawValue
                    animationOptions[.byLayer] = configuration.layered
                    animation = .bounce
                case let .wiggle(configuration):
                    animationOptions[.wiggleOptions] = configuration.flags.rawValue
                    if let angle = configuration.angle {
                        animationOptions[.wiggleAngle] = angle.radians
                    }
                    animationOptions[.byLayer] = configuration.layered
                    animation = .wiggle
                case let .rotate(configuration):
                    animationOptions[.rotateOptions] = configuration.flags.rawValue
                    animationOptions[.byLayer] = configuration.layered
                    animation = .rotate
                case let .variableColor(configuration):
                    animationOptions[.variableColorOptions] = configuration.flags.rawValue
                    animation = .variableColor
                case .scale, .hidden, .none:
                    animation = nil
                }
                if let animation {
                    animationOptions[.speed] = options.speed
                    animationOptions[.repeatCount] = options.repeatCount ?? (trigger == nil ? Float.infinity : 1)
                    if let repeatDelay = options.repeatDelay {
                        animationOptions[.repeatDelay] = repeatDelay
                    }
                    animationOptions[.priority] = priority
                    animationID = addAnimation(
                        animation,
                        options: animationOptions,
                        animationListener: animationListener,
                        logicalListener: logicalListener
                    )
                    if animationID != 0 {
                        animationPriority = priority
                        priority += 1
                    }
                }
            }
            added.append(
                .init(
                    identifier: identified.identifier,
                    serial: identified.serial,
                    effect: storage,
                    animationID: animationID,
                    priority: animationPriority
                )
            )
        }

        if unmatchedCount > 0 {
            for index in phase.added.indices where !matched[index] {
                let animationID = phase.added[index].animationID
                if animationID != 0 {
                    cancelAnimation(withID: animationID)
                }
            }
        }

        if scale.level != phase.scale.level || hidden.isHidden != phase.hidden.isHidden {
            if !animationsDisabled, !disablesAnimations, !phase.isFirstUpdate {
                if scale != phase.scale,
                   scale.level != .normal || phase.scale.level != .normal {
                    addAnimation(
                        .scale,
                        options: [
                            .byLayer: scale.layered,
                            .speed: scaleOptions.speed,
                        ],
                        animationListener: animationListener,
                        logicalListener: logicalListener
                    )
                }
                if hidden.isHidden != phase.hidden.isHidden {
                    addAnimation(
                        hidden.isHidden ? .disappear : .appear,
                        options: [
                            .byLayer: hidden.layered,
                            .appearDisappearOptions: hidden.flags.rawValue,
                            .speed: hiddenOptions.speed,
                        ],
                        animationListener: animationListener,
                        logicalListener: logicalListener
                    )
                }
            }
            scaleLevel = scale.level
            isHidden = hidden.isHidden
        }

        phase.added = added
        phase.scale = scale
        phase.scaleOptions = scaleOptions
        phase.hidden = hidden
        phase.hiddenOptions = hiddenOptions
        phase.isFirstUpdate = false
    }

    @discardableResult
    func addAnimation(
        _ animation: ORBSymbolAnimation,
        options: consuming [ORBSymbolAnimation.OptionKey: Any],
        animationListener: AnimationListener?,
        logicalListener: AnimationListener?
    ) -> UInt32 {
        var options = options
        if animationListener != nil || logicalListener != nil {
            #if canImport(ObjectiveC)
            let completion: @convention(block) (Bool, UInt32) -> Void = { _, _ in
                Update.enqueueAction(reason: nil) {
                    animationListener?.animationWasRemoved()
                    logicalListener?.animationWasRemoved()
                }
            }
            #else
            // On Linux, Swift 6.3.3 can call blocks but crashes when
            // options.map copies a block stored as Any. Use a Swift closure.
            let completion: (Bool, UInt32) -> Void = { _, _ in
                Update.enqueueAction(reason: nil) {
                    animationListener?.animationWasRemoved()
                    logicalListener?.animationWasRemoved()
                }
            }
            #endif
            options[.onCompletion] = completion
        }
        let animationOptions = Dictionary(
            uniqueKeysWithValues: options.map { ($0.key.rawValue, $0.value) }
        )
        let animationID = addAnimation(animation, options: animationOptions)
        if animationID != 0 {
            animationListener?.animationWasAdded()
            logicalListener?.animationWasAdded()
        }
        return animationID
    }
}

extension _SymbolEffect.Storage {
    fileprivate func hasSameCase(as other: _SymbolEffect.Storage) -> Bool {
        switch (self, other) {
        case (.pulse, .pulse), (.breathe, .breathe), (.bounce, .bounce),
             (.wiggle, .wiggle), (.rotate, .rotate), (.variableColor, .variableColor),
             (.scale, .scale), (.hidden, .hidden), (.none, .none):
            true
        default:
            false
        }
    }
}

// MARK: - _SymbolEffect + ProtobufMessage

extension _SymbolEffect: ProtobufMessage {
    package func encode(to encoder: inout ProtobufEncoder) throws {
        try encoder.messageField(1, storage)
        try encoder.messageField(2, options, defaultValue: .init())
    }

    package init(from decoder: inout ProtobufDecoder) throws {
        var storage: Storage?
        var options = Options()
        while let field = try decoder.nextField() {
            switch field.tag {
            case 1: storage = try decoder.messageField(field)
            case 2: options = try decoder.messageField(field)
            default: try decoder.skipField(field)
            }
        }
        guard let storage else {
            throw ProtobufDecoder.DecodingError.failed
        }
        self.init(storage, options: options)
    }
}

// MARK: - _SymbolEffect.Storage + ProtobufMessage

extension _SymbolEffect.Storage: ProtobufMessage {
    package func encode(to encoder: inout ProtobufEncoder) throws {
        switch self {
        case let .pulse(configuration):
            try encoder.messageField(1, configuration)
        case let .breathe(configuration):
            try encoder.messageField(8, configuration)
        case let .bounce(configuration):
            try encoder.messageField(2, configuration)
        case let .wiggle(configuration):
            try encoder.messageField(3, configuration)
        case let .rotate(configuration):
            try encoder.messageField(4, configuration)
        case let .variableColor(configuration):
            try encoder.messageField(5, configuration)
        case let .scale(configuration):
            try encoder.messageField(6, configuration)
        case let .hidden(configuration):
            try encoder.messageField(7, configuration)
        case .none:
            break
        }
    }

    package init(from decoder: inout ProtobufDecoder) throws {
        var storage: Self = .none
        while let field = try decoder.nextField() {
            switch field.tag {
            case 1: storage = .pulse(try decoder.messageField(field))
            case 2: storage = .bounce(try decoder.messageField(field))
            case 3: storage = .wiggle(try decoder.messageField(field))
            case 4: storage = .rotate(try decoder.messageField(field))
            case 5: storage = .variableColor(try decoder.messageField(field))
            case 6: storage = .scale(try decoder.messageField(field))
            case 7: storage = .hidden(try decoder.messageField(field))
            case 8: storage = .breathe(try decoder.messageField(field))
            default: try decoder.skipField(field)
            }
        }
        self = storage
    }
}

// MARK: - _SymbolEffect.Options + ProtobufMessage

extension _SymbolEffect.Options: ProtobufMessage {
    package func encode(to encoder: inout ProtobufEncoder) throws {
        encoder.floatField(1, speed, defaultValue: 1)
        if let repeatCount {
            encoder.floatField(2, repeatCount)
        }
        if let repeatDelay {
            encoder.floatField(3, repeatDelay)
        }
    }

    package init(from decoder: inout ProtobufDecoder) throws {
        var options = Self()
        while let field = try decoder.nextField() {
            switch field.tag {
            case 1: options.speed = try decoder.floatField(field)
            case 2: options.repeatCount = try decoder.floatField(field)
            case 3: options.repeatDelay = try decoder.floatField(field)
            default: try decoder.skipField(field)
            }
        }
        self = options
    }
}

// MARK: - _SymbolEffect.Trigger + ProtobufMessage

extension _SymbolEffect.Trigger: ProtobufMessage {
    package func encode(to encoder: inout ProtobufEncoder) throws {
        switch self {
        case let .value(value):
            try encoder.messageField(1, value.hash ?? .random())
        case let .condition(condition):
            encoder.boolField(2, condition)
        }
    }

    package init(from decoder: inout ProtobufDecoder) throws {
        var trigger: Self = .condition(false)
        while let field = try decoder.nextField() {
            switch field.tag {
            case 1:
                let hash: StrongHash = try decoder.messageField(field)
                trigger = .value(AnyEquatable(hash: hash))
            case 2:
                trigger = .condition(try decoder.boolField(field))
            default:
                try decoder.skipField(field)
            }
        }
        self = trigger
    }
}

// MARK: - _SymbolEffect.PulseConfiguration + ProtobufMessage

extension _SymbolEffect.PulseConfiguration: ProtobufMessage {
    package func encode(to encoder: inout ProtobufEncoder) throws {
        if let trigger {
            try encoder.messageField(3, trigger)
        }
        encoder.boolField(2, layered, defaultValue: true)
    }

    package init(from decoder: inout ProtobufDecoder) throws {
        var configuration = Self()
        while let field = try decoder.nextField() {
            switch field.tag {
            case 2: configuration.layered = try decoder.boolField(field)
            case 3: configuration.trigger = try decoder.messageField(field)
            default: try decoder.skipField(field)
            }
        }
        self = configuration
    }
}

// MARK: - _SymbolEffect.BreatheConfiguration + ProtobufMessage

extension _SymbolEffect.BreatheConfiguration: ProtobufMessage {
    package func encode(to encoder: inout ProtobufEncoder) throws {
        if let trigger {
            try encoder.messageField(1, trigger)
        }
        encoder.uintField(2, UInt(flags.rawValue))
        encoder.boolField(3, layered, defaultValue: true)
    }

    package init(from decoder: inout ProtobufDecoder) throws {
        var configuration = Self()
        while let field = try decoder.nextField() {
            switch field.tag {
            case 1: configuration.trigger = try decoder.messageField(field)
            case 2: configuration.flags = .init(rawValue: try decoder.uint32Field(field))
            case 3: configuration.layered = try decoder.boolField(field)
            default: try decoder.skipField(field)
            }
        }
        self = configuration
    }
}

// MARK: - _SymbolEffect.BounceConfiguration + ProtobufMessage

extension _SymbolEffect.BounceConfiguration: ProtobufMessage {
    package func encode(to encoder: inout ProtobufEncoder) throws {
        if let trigger {
            try encoder.messageField(4, trigger)
        }
        encoder.uintField(2, UInt(flags.rawValue))
        encoder.boolField(3, layered, defaultValue: true)
    }

    package init(from decoder: inout ProtobufDecoder) throws {
        var configuration = Self()
        while let field = try decoder.nextField() {
            switch field.tag {
            case 2: configuration.flags = .init(rawValue: try decoder.uint32Field(field))
            case 3: configuration.layered = try decoder.boolField(field)
            case 4: configuration.trigger = try decoder.messageField(field)
            default: try decoder.skipField(field)
            }
        }
        self = configuration
    }
}

// MARK: - _SymbolEffect.WiggleConfiguration + ProtobufMessage

extension _SymbolEffect.WiggleConfiguration: ProtobufMessage {
    package func encode(to encoder: inout ProtobufEncoder) throws {
        if let trigger {
            try encoder.messageField(5, trigger)
        }
        if let angle {
            encoder.doubleField(2, angle.radians)
        }
        encoder.uintField(3, UInt(flags.rawValue))
        encoder.boolField(4, layered, defaultValue: true)
        encoder.boolField(6, appliesRTL)
    }

    package init(from decoder: inout ProtobufDecoder) throws {
        var configuration = Self()
        while let field = try decoder.nextField() {
            switch field.tag {
            case 2: configuration.angle = .init(radians: try decoder.doubleField(field))
            case 3: configuration.flags = .init(rawValue: try decoder.uint32Field(field))
            case 4: configuration.layered = try decoder.boolField(field)
            case 5: configuration.trigger = try decoder.messageField(field)
            case 6: configuration.appliesRTL = try decoder.boolField(field)
            default: try decoder.skipField(field)
            }
        }
        self = configuration
    }
}

// MARK: - _SymbolEffect.RotateConfiguration + ProtobufMessage

extension _SymbolEffect.RotateConfiguration: ProtobufMessage {
    package func encode(to encoder: inout ProtobufEncoder) throws {
        if let trigger {
            try encoder.messageField(4, trigger)
        }
        encoder.uintField(2, UInt(flags.rawValue))
        encoder.boolField(3, layered, defaultValue: true)
    }

    package init(from decoder: inout ProtobufDecoder) throws {
        var configuration = Self()
        while let field = try decoder.nextField() {
            switch field.tag {
            case 2: configuration.flags = .init(rawValue: try decoder.uint32Field(field))
            case 3: configuration.layered = try decoder.boolField(field)
            case 4: configuration.trigger = try decoder.messageField(field)
            default: try decoder.skipField(field)
            }
        }
        self = configuration
    }
}

// MARK: - _SymbolEffect.VariableColorConfiguration + ProtobufMessage

extension _SymbolEffect.VariableColorConfiguration: ProtobufMessage {
    package func encode(to encoder: inout ProtobufEncoder) throws {
        if let trigger {
            try encoder.messageField(3, trigger)
        }
        encoder.uintField(2, UInt(flags.rawValue))
    }

    package init(from decoder: inout ProtobufDecoder) throws {
        var configuration = Self()
        while let field = try decoder.nextField() {
            switch field.tag {
            case 2: configuration.flags = .init(rawValue: try decoder.uint32Field(field))
            case 3: configuration.trigger = try decoder.messageField(field)
            default: try decoder.skipField(field)
            }
        }
        self = configuration
    }
}

// MARK: - ORBSymbolScaleLevel + ProtobufEnum

extension ORBSymbolScaleLevel: ProtobufEnum {
    package var protobufValue: UInt {
        UInt(rawValue)
    }

    package init?(protobufValue value: UInt) {
        guard let rawValue = Int32(exactly: value) else {
            return nil
        }
        self.init(rawValue: rawValue)
    }
}

// MARK: - _SymbolEffect.ScaleConfiguration + ProtobufMessage

extension _SymbolEffect.ScaleConfiguration: ProtobufMessage {
    package func encode(to encoder: inout ProtobufEncoder) throws {
        encoder.enumField(1, level)
        encoder.boolField(2, layered, defaultValue: true)
    }

    package init(from decoder: inout ProtobufDecoder) throws {
        var configuration = Self()
        while let field = try decoder.nextField() {
            switch field.tag {
            case 1: configuration.level = try decoder.enumField(field) ?? .normal
            case 2: configuration.layered = try decoder.boolField(field)
            default: try decoder.skipField(field)
            }
        }
        self = configuration
    }
}

// MARK: - _SymbolEffect.HiddenConfiguration + ProtobufMessage

extension _SymbolEffect.HiddenConfiguration: ProtobufMessage {
    package func encode(to encoder: inout ProtobufEncoder) throws {
        encoder.boolField(1, isHidden)
        encoder.uintField(2, UInt(flags.rawValue))
        encoder.boolField(3, layered, defaultValue: true)
    }

    package init(from decoder: inout ProtobufDecoder) throws {
        var configuration = Self()
        while let field = try decoder.nextField() {
            switch field.tag {
            case 1: configuration.isHidden = try decoder.boolField(field)
            case 2: configuration.flags = .init(rawValue: try decoder.uint32Field(field))
            case 3: configuration.layered = try decoder.boolField(field)
            default: try decoder.skipField(field)
            }
        }
        self = configuration
    }
}

// MARK: - _SymbolEffect.ReplaceConfiguration + ProtobufMessage

extension _SymbolEffect.ReplaceConfiguration: ProtobufMessage {
    package func encode(to encoder: inout ProtobufEncoder) throws {
        encoder.uintField(1, UInt(flags.rawValue))
        encoder.boolField(2, layered, defaultValue: true)
        encoder.floatField(3, speed, defaultValue: 1)
    }

    package init(from decoder: inout ProtobufDecoder) throws {
        var configuration = Self()
        while let field = try decoder.nextField() {
            switch field.tag {
            case 1: configuration.flags = .init(rawValue: try decoder.uint32Field(field))
            case 2: configuration.layered = try decoder.boolField(field)
            case 3: configuration.speed = try decoder.floatField(field)
            default: try decoder.skipField(field)
            }
        }
        self = configuration
    }
}

// MARK: - _SymbolEffect + isIndefinite

extension _SymbolEffect {
    package var isIndefinite: Bool {
        if let repeatCount = options.repeatCount {
            return !repeatCount.isFinite
        }
        switch storage {
        case .scale, .hidden, .none:
            return true
        default:
            return storage.trigger == nil
        }
    }
}
