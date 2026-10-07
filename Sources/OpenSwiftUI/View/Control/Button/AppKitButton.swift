//
//  AppKitButton.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: TBA
//  ID: 9FEBA96B0BC70E1682E82D239F242E73 (SwiftUI)

#if os(macOS)
import AppKit
import COpenSwiftUI
import OpenAttributeGraphShims
@_spi(ForOpenSwiftUIOnly)
import OpenSwiftUICore

// MARK: - AllowsVerticallyFlexibleMacButtons

struct AllowsVerticallyFlexibleMacButtons: SemanticFeature {
    static let introduced: Semantics = .v5
}

// MARK: - AppKitButtonStyle

struct AppKitButtonStyle: PrimitiveButtonStyle {
    var appearance: AppKitButtonAppearance

    func makeBody(configuration: Configuration) -> some View {
        Content(appearance: appearance, configuration: configuration)
    }

    struct Content: EnvironmentalView {
        var appearance: AppKitButtonAppearance
        var configuration: PrimitiveButtonStyleConfiguration

        func body(environment: EnvironmentValues) -> some View {
            AppKitButton(
                configuration: AppKitButtonConfiguration(
                    role: configuration.role,
                    action: configuration.trigger,
                    appearance: appearance.resolve(in: environment),
                    isOn: environment.defaultToggleIsOn
                ),
                label: configuration.label
            )
            .coordinateSpace(.id(focusCoordinateSpace))
        }
    }
}

// MARK: - AppKitButtonAppearance

struct AppKitButtonAppearance {
    let bezelStyle: NSButton.BezelStyle
    let isBordered: Bool
    fileprivate let tint: Tint?
    let showsBorderOnHover: Bool
    fileprivate let heightBehavior: HeightBehavior
    let isInToolbar: Bool

    init(bezelStyle: NSButton.BezelStyle, tint: Color?, isInToolbar: Bool) {
        self.bezelStyle = bezelStyle
        isBordered = true
        self.tint = tint.map(Tint.bezel)
        showsBorderOnHover = bezelStyle == .accessoryBar
        switch bezelStyle.rawValue {
        case 1, 5, 7, 9, 11, 12, 13, 14: heightBehavior = .fixed
        case 28: heightBehavior = .fixedWithFlexibleFallback
        default: heightBehavior = .flexible
        }
        self.isInToolbar = isInToolbar
    }

    private init(
        bezelStyle: NSButton.BezelStyle, isBordered: Bool, tint: Tint?,
        showsBorderOnHover: Bool, heightBehavior: HeightBehavior, isInToolbar: Bool
    ) {
        self.bezelStyle = bezelStyle
        self.isBordered = isBordered
        self.tint = tint
        self.showsBorderOnHover = showsBorderOnHover
        self.heightBehavior = heightBehavior
        self.isInToolbar = isInToolbar
    }

    static func borderless(tint: Color?) -> AppKitButtonAppearance {
        AppKitButtonAppearance(
            bezelStyle: .flexiblePush, isBordered: false, tint: tint.map(Tint.content),
            showsBorderOnHover: false, heightBehavior: .flexible, isInToolbar: false
        )
    }

    static let accessoryBarAction = AppKitButtonAppearance(
        bezelStyle: .accessoryBarAction, tint: nil, isInToolbar: false
    )

    static let link = AppKitButtonAppearance(
        bezelStyle: .flexiblePush, isBordered: false, tint: .content(Color(appearanceName: "linkColor")),
        showsBorderOnHover: false, heightBehavior: .flexible, isInToolbar: false
    )

    fileprivate enum Tint {
        case bezel(Color)
        case content(Color)
    }

    fileprivate enum HeightBehavior: Hashable {
        case fixed
        case fixedWithFlexibleFallback
        case flexible
    }

    fileprivate struct Resolved {
        let bezelStyle: NSButton.BezelStyle
        let isBordered: Bool
        let tint: Tint?
        let showsBorderOnHover: Bool
        let heightBehavior: HeightBehavior
        let isInToolbar: Bool

        enum Tint {
            case bezel(Color.Resolved)
            case content(Color.Resolved)
        }

        func updateEnvironment(_ environment: inout EnvironmentValues) {
            guard isInToolbar else { return }
            if environment.controlSize == .large {
                environment.symbolFont = .system(size: NSFont.systemFontSize, weight: .medium)
                environment.imageScale = .large
            } else {
                environment.imageScale = .medium
            }
        }

        func apply(to button: NSButton) {
            button.bezelStyle = bezelStyle
            switch tint {
            case .bezel(let color):
                button.bezelColor = (color.kitColor as! NSColor)
                button.contentTintColor = nil
            case .content(let color):
                button.bezelColor = nil
                button.contentTintColor = (color.kitColor as! NSColor)
            case nil:
                button.bezelColor = nil
                button.contentTintColor = nil
            }
            button.isBordered = isBordered
            button.showsBorderOnlyWhileMouseInside = showsBorderOnHover
        }
    }

    fileprivate func resolve(in environment: EnvironmentValues) -> Resolved {
        let resolvedTint: Resolved.Tint?
        switch tint {
        case .bezel(let color): resolvedTint = .bezel(color.resolve(in: environment))
        case .content(let color): resolvedTint = .content(color.resolve(in: environment))
        case nil: resolvedTint = nil
        }
        return Resolved(
            bezelStyle: bezelStyle, isBordered: isBordered, tint: resolvedTint,
            showsBorderOnHover: showsBorderOnHover, heightBehavior: heightBehavior,
            isInToolbar: isInToolbar
        )
    }
}

// MARK: - AppKitButtonConfiguration

private struct AppKitButtonConfiguration {
    var role: ButtonRole?
    var action: () -> Void
    var appearance: AppKitButtonAppearance.Resolved
    var isOn: Bool?
}

// MARK: - NSButtonResponder

private class NSButtonResponder: PlatformUnaryViewResponder {
    var configuration: AppKitButtonConfiguration

    init(layoutResponder: DefaultLayoutViewResponder, configuration: AppKitButtonConfiguration) {
        self.configuration = configuration
        super.init(layoutResponder: layoutResponder)
    }

    override func addContentPath(
        to path: inout Path, kind: ContentShapeKinds, in space: CoordinateSpace,
        observer: (any ContentPathObserver)?
    ) {
        if configuration.appearance.isBordered {
            super.addContentPath(to: &path, kind: kind, in: space, observer: observer)
        } else {
            layoutResponder.addContentPath(to: &path, kind: kind, in: space, observer: observer)
        }
    }
}

// MARK: - SwiftUIAppKitButton

private class SwiftUIAppKitButton: NSButton, RecursiveIgnoreHitTestCustomizing, AcceptsFirstMouseCustomizing {
    let viewType: Any.Type
    var configuration: AppKitButtonConfiguration?
    var repeatTiming: ButtonRepeatTiming?
    var repeatState: RepeatState?
    var recursiveIgnoreHitTest = false
    var customAcceptsFirstMouse: Bool?

    struct RepeatState {
        var timer: Timer
        var hasTriggeredInitialAction: Bool
    }

    init(viewType: Any.Type, contentStyleSignal: WeakAttribute<Void>) {
        self.viewType = viewType
        let host = ContentViewHost(contentStyleSignal: contentStyleSignal)
        super.init(frame: .zero)
        title = ""
        imagePosition = .noImage
        bezelStyle = .push
        lineBreakMode = .byTruncatingTail
        setButtonType(.momentaryPushIn)
        host.ignoreContentStyleUpdates = true
        contentView = host
        cell?.setAccessibilityElement(false)
        addTarget(self, action: #selector(didReleaseButton(_:)), forControlEvents: 0x40)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func update(
        configuration: AppKitButtonConfiguration, keyboardShortcut: KeyboardShortcut?,
        springLoading: SpringLoadingBehavior, buttonRepeatTiming: ButtonRepeatTiming?,
        forceDestructiveAppearance: Bool, allowsWindowActivationEvents: Bool?
    ) {
        let host = contentView as! ContentViewHost
        host.ignoreContentStyleUpdates = true
        font = nil
        configuration.appearance.apply(to: self)
        hasDestructiveAction = configuration.role == .destructive
        _setUsesCautionaryAppearance(whenActionIsDestructive: forceDestructiveAppearance)
        if let keyboardShortcut {
            let key = String(keyboardShortcut.key.character)
            keyEquivalent = isLinkedOnOrAfter(.v3) ? key.lowercased() : key
            keyEquivalentModifierMask = NSEvent.ModifierFlags(keyboardShortcut.modifiers)
        } else {
            keyEquivalent = ""
            keyEquivalentModifierMask = []
        }
        isSpringLoaded = springLoading == .enabled
        let cell = cell as! NSButtonCell
        let stateMask: NSCell.StyleMask
        if let isOn = configuration.isOn {
            cell.state = isOn ? .on : .off
            stateMask = .contentsCellMask
        } else {
            stateMask = []
        }
        if cell.showsStateBy != stateMask { cell.showsStateBy = stateMask }
        repeatTiming = buttonRepeatTiming
        let targets: [(Selector, UInt64)] = [
            (#selector(didPressButton(_:)), 0x1),
            (#selector(didCancelButton(_:)), 0x180),
            (#selector(didExitButton(_:)), 0x20),
            (#selector(didReenterButton(_:)), 0x10),
        ]
        for (action, events) in targets {
            if buttonRepeatTiming != nil {
                addTarget(self, action: action, forControlEvents: events)
            } else {
                removeTarget(self, action: action, forControlEvents: events)
            }
        }
        self.configuration = configuration
        customAcceptsFirstMouse = allowsWindowActivationEvents
        host.ignoreContentStyleUpdates = false
    }

    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        updateCell(cell!)
    }

    override func menu(for event: NSEvent) -> NSMenu? {
        (enclosingViewRendererHost as? NSView)?.menu(for: event)
    }

    override func hitTest(_ point: NSPoint) -> NSView? {
        if !ResponderBasedHitTesting.isEnabled {
            guard !recursiveIgnoreHitTest,
                  alphaValue >= ViewResponder.minOpacityForHitTest else { return nil }
        }
        return super.hitTest(point) == nil ? nil : self
    }

    override func acceptsFirstMouse(for event: NSEvent?) -> Bool {
        let accepts = ResponderBasedHitTesting.isEnabled
            ? customAcceptsFirstMouse : effectiveAcceptsFirstMouse
        return accepts ?? super.acceptsFirstMouse(for: event)
    }

    override func designatedFocusRing() -> NSView? {
        isBordered ? super.designatedFocusRing() : contentView
    }

    @objc func didReleaseButton(_ sender: NSButton) {
        repeatState?.timer.invalidate()
        if let configuration, repeatState?.hasTriggeredInitialAction != true {
            Update.enqueueAction(reason: .didReleaseButton) { configuration.action() }
        }
        repeatState = nil
    }

    @objc func didCancelButton(_ sender: NSButton) {
        repeatState?.timer.invalidate()
        repeatState = nil
    }

    @objc func didExitButton(_ sender: NSButton) { repeatState?.timer.invalidate() }

    @objc func didReenterButton(_ sender: NSButton) {
        if repeatState != nil, let repeatTiming {
            scheduleRepeatTimer(timingIterator: repeatTiming.makeIterator(), isInitial: true)
        }
    }

    @objc func didPressButton(_ sender: NSButton) {
        if let repeatTiming {
            scheduleRepeatTimer(timingIterator: repeatTiming.makeIterator(), isInitial: true)
        }
    }

    func scheduleRepeatTimer<I: IteratorProtocol>(timingIterator: I, isInitial: Bool) where I.Element == Double {
        var iterator = timingIterator
        guard let interval = iterator.next() else { return }
        let timer = Timer(timeInterval: interval, repeats: false) { [weak self] _ in
            guard let self else { return }
            self.repeatState?.hasTriggeredInitialAction = true
            self.configuration?.action()
            self.scheduleRepeatTimer(timingIterator: iterator, isInitial: false)
        }
        RunLoop.main.add(timer, forMode: .common)
        if repeatState != nil {
            repeatState?.timer = timer
        } else {
            repeatState = RepeatState(timer: timer, hasTriggeredInitialAction: false)
        }
    }

    class ContentViewHost: NSView {
        let contentStyleSignal: WeakAttribute<Void>
        var ignoreContentStyleUpdates = false
        var icsHeight = NSView.noIntrinsicMetric
        var firstBaselineOffset = CGFloat.leastNormalMagnitude
        var lastBaselineOffset = CGFloat.leastNormalMagnitude
        final lazy var helper = FocusRingHelper(responder: nil, focusRingView: self)

        init(contentStyleSignal: WeakAttribute<Void>) {
            self.contentStyleSignal = contentStyleSignal
            super.init(frame: .zero)
            clipsToBounds = false
        }

        required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

        override var focusRingMaskBounds: NSRect { helper.focusRingMaskBounds }
        override func drawFocusRingMask() { helper.drawFocusRingMask() }
        override var isFlipped: Bool { true }
        override func setFlipped(_ flipped: Bool) {}

        override var intrinsicContentSize: NSSize {
            NSSize(width: NSView.noIntrinsicMetric, height: icsHeight)
        }

        override func _baselineOffsets(at size: CGSize) -> BaselineOffset {
            BaselineOffset(firstTextBaseline: firstBaselineOffset, lastTextBaseline: lastBaselineOffset)
        }

        override var contentStyle: (any NSContentStyle)? {
            get { super.contentStyle }
            set {
                super.contentStyle = newValue
                guard !ignoreContentStyleUpdates, let attribute = contentStyleSignal.attribute else { return }
                attribute.graph.viewGraph().asyncTransaction(
                    invalidating: contentStyleSignal, style: .deferred, mayDeferUpdate: false
                )
            }
        }

        func update(height: CGFloat, firstBaseline: CGFloat, lastBaseline: CGFloat) {
            if icsHeight != height {
                icsHeight = height
                invalidateIntrinsicContentSize()
                superview?.needsLayout = true
            }
            if firstBaselineOffset != firstBaseline {
                firstBaselineOffset = firstBaseline
                superview?.needsLayout = true
            }
            if lastBaselineOffset != height - lastBaseline {
                lastBaselineOffset = height - lastBaseline
                superview?.needsLayout = true
            }
        }
    }
}

extension SwiftUIAppKitButton: PlatformFocusViewProvider {
    var focusView: NSView { self }
}

extension SwiftUIAppKitButton: PlatformGroupFactory {
    func makePlatformGroup() -> AnyObject? { self }
    func needsUpdateFor(newValue: any PlatformGroupFactory) -> Bool { false }
    func updatePlatformGroup(_ view: inout AnyObject) {}
    func platformGroupContainer(_ view: AnyObject) -> AnyObject { contentView! }

    func renderPlatformGroup(
        _ list: DisplayList, in ctx: GraphicsContext, size: CGSize, renderer: DisplayList.GraphicsRenderer
    ) {
        Update.syncMain {
            renderer.renderPlatformView(self, in: ctx, size: size, viewType: NSButton.self)
        }
    }
}

extension SwiftUIAppKitButton.ContentViewHost: CustomRecursiveStringConvertible {
    var descriptionAttributes: [(name: String, value: String)] {
        guard superview != nil, _TestApp.host != nil,
              _TestApp.isIntending(to: .includeBaselines) else { return [] }
        return [
            ("firstBaseline", firstBaselineOffset.description),
            ("lastBaseline", lastBaselineOffset.description),
        ]
    }

    var defaultDescriptionAttributes: Set<DefaultDescriptionAttribute> { [] }

    var descriptionChildren: [any CustomRecursiveStringConvertible] {
        subviews.compactMap { $0 as? any CustomRecursiveStringConvertible }
    }
}

// MARK: - NSButton.Metrics

extension NSButton {
    fileprivate struct Metrics {
        var size: CGSize
        var alignmentInsets: EdgeInsets
        var contentInsets: EdgeInsets
    }

    fileprivate var metrics: Metrics {
        var size = CGSize.zero
        var alignment = NSEdgeInsetsZero
        var content = NSEdgeInsetsZero
        Update.syncMain {
            if isBordered {
                _ = _getIntrinsicArtworkSize(
                    &size, alignmentRectInsets: &alignment,
                    idealContentInsets: &content, maxContentInsets: nil
                )
            }
        }
        let alignmentInsets = EdgeInsets(top: alignment.top, leading: alignment.left, bottom: alignment.bottom, trailing: alignment.right)
        let contentInsets = EdgeInsets(top: content.top, leading: content.left, bottom: content.bottom, trailing: content.right)
        return Metrics(size: size, alignmentInsets: alignmentInsets, contentInsets: contentInsets.adding(alignmentInsets.negatedInsets))
    }
}

// MARK: - AppKitButton

private struct AppKitButton<Label: View>: PrimitiveView, UnaryView {
    var configuration: AppKitButtonConfiguration
    var label: Label

    static func _makeView(view: _GraphValue<Self>, inputs: _ViewInputs) -> _ViewOutputs {
        let signal = Attribute(value: ())
        let configuration = view[\.configuration].value
        let position = inputs.animatedPosition()
        let size = inputs.animatedSize()
        let needsDisplayList = inputs.preferences.requiresDisplayList
        let isInToolbar = needsDisplayList && inputs.base.accepts(.toolbar)
        var nativeButton: SwiftUIAppKitButton!
        Update.syncMain {
            nativeButton = SwiftUIAppKitButton(viewType: Self.self, contentStyleSignal: WeakAttribute(signal))
        }
        var button = Attribute(UpdatedButton(
            button: nativeButton,
            configuration: configuration,
            environment: inputs.environment,
            keyboardShortcut: inputs.base.keyboardShortcut,
            springLoading: inputs.base.mapEnvironment(id: .springLoadingBehavior) {
                $0.springLoadingBehavior
            },
            buttonRepeatTiming: inputs.base.mapEnvironment(id: .effectiveButtonRepeatTiming) {
                $0.effectiveButtonRepeatTiming
            },
            forceDestructiveAppearance: inputs.base.mapEnvironment(id: .enforceButtonDestructiveRoleAppearance) {
                $0.enforceButtonDestructiveRoleAppearance
            },
            allowsWindowActivationEvents: inputs.base.mapEnvironment(id: .allowsWindowActivationEvents) {
                $0.allowsWindowActivationEvents
            }
        ))
        var childInputs = inputs
        var frame: Attribute<ButtonContentFrame.Value>?
        if inputs.needsGeometry {
            let contentFrame = Attribute(ButtonContentFrame(
                button: button, configuration: configuration, position: position,
                size: size, pixelLength: inputs.pixelLength, contentComputer: .init()
            ))
            frame = contentFrame
            childInputs.requestsLayoutComputer = true
            childInputs.size = contentFrame[keyPath: \.frame.size]
            childInputs.position = contentFrame[keyPath: \.frame.origin]
            childInputs.containerPosition = contentFrame[keyPath: \.containerPosition]
            childInputs.safeAreaInsets = .init()
        }
        if isInToolbar {
            childInputs.addPlatformItemListKey(flags: TextPlatformItemListFlags.self, editOperation: .formUnion)
        }
        let environment = Attribute(ButtonContentEnvironment(button: button, environment: inputs.environment))
        environment.addInput(signal, options: ._4, token: 0)
        environment.flags = .transactional
        childInputs.environment = environment
        let label = _GraphValue(LabelChild(
            label: view[\.label].value, configuration: configuration,
            isInTouchBar: inputs.base.interfaceIdiom.accepts(.touchBar)
        ))
        var outputs = LabelChild.Value.makeDebuggableView(view: label, inputs: childInputs)
        let contentComputer = outputs.layoutComputer
        if let frame, let contentComputer {
            frame.mutateBody(as: ButtonContentFrame.self, invalidating: true) {
                $0.$contentComputer = contentComputer
            }
        }
        let metrics = Attribute(ButtonContentMetrics(
            button: button, size: size, contentComputer: .init(contentComputer)
        ))
        if isInToolbar, let list = outputs.preferences.platformItemList {
            button = Attribute(UpdatedButton.WithContainsText(button: button, platformItemList: list))
        }
        if inputs.requestsLayoutComputer {
            outputs.layoutComputer = Attribute(ButtonLayoutComputer(
                button: button, configuration: configuration, contentComputer: .init(contentComputer)
            ))
        }
        if inputs.preferences.requiresViewResponders {
            outputs[ViewRespondersKey.self] = Attribute(ButtonResponder(
                button: button, position: position, size: size, transform: inputs.transform,
                children: outputs.viewResponders(), configuration: configuration,
                layoutResponder: DefaultLayoutViewResponder(inputs: inputs)
            ))
        }
        if needsDisplayList {
            let identity = DisplayList.Identity()
            inputs.pushIdentity(identity)
            outputs.displayList = Attribute(ButtonDisplayList(
                identity: identity, button: metrics, configuration: configuration,
                position: position, size: size, containerPosition: inputs.containerPosition,
                contentList: .init(outputs.displayList)
            ))
        }
        // TODO: AccessibilityPlatformViewModifier
        return outputs
    }

    struct LabelChild: Rule {
        @Attribute var label: Label
        @Attribute var configuration: AppKitButtonConfiguration
        var isInTouchBar: Bool

        var value: some View {
            HStack(spacing: isInTouchBar ? 6 : 4) {
                label.lineLimit(configuration.appearance.heightBehavior == .flexible ? nil : 1)
            }
            .multilineTextAlignment(.center)
            .buttonDefaultRenderingMode()
        }
    }
}

// MARK: - ButtonContentEnvironment

private extension CachedEnvironment.ID {
    static let springLoadingBehavior = CachedEnvironment.ID()
    static let effectiveButtonRepeatTiming = CachedEnvironment.ID()
    static let enforceButtonDestructiveRoleAppearance = CachedEnvironment.ID()
    static let allowsWindowActivationEvents = CachedEnvironment.ID()
}

private struct ButtonContentEnvironment: Rule {
    @Attribute var button: SwiftUIAppKitButton
    @Attribute var environment: EnvironmentValues

    var value: EnvironmentValues {
        var environment = environment
        button.configuration?.appearance.updateEnvironment(&environment)
        let style = ButtonContentStyle(contentStyle: button.contentView!.contentStyle, seed: 0, button: button)
        environment.defaultForegroundStyle = style.copyStyle(in: environment)
        return environment
    }
}

// MARK: - ButtonContentFrame

private struct ButtonContentFrame: Rule {
    @Attribute var button: SwiftUIAppKitButton
    @Attribute var configuration: AppKitButtonConfiguration
    @Attribute var position: CGPoint
    @Attribute var size: ViewSize
    @Attribute var pixelLength: CGFloat
    @OptionalAttribute var contentComputer: LayoutComputer?

    struct Value {
        var frame: ViewFrame
        var containerPosition: CGPoint
    }

    var value: Value {
        let insets = button.metrics.contentInsets
        let containerPosition = position.offset(by: insets)
        let available = CGRect(origin: .zero, size: size.value).inset(by: insets).size
        let proposal = _ProposedSize(available)
        let contentSize = (contentComputer ?? .defaultValue).sizeThatFits(proposal)
        var origin = containerPosition
        if configuration.appearance.bezelStyle == .circular {
            origin.x += contentSize.centeredIn(available).origin.x
        }
        var frame = ViewFrame(origin: origin, size: ViewSize(contentSize, proposal: proposal))
        frame.round(toMultipleOf: pixelLength)
        return Value(frame: frame, containerPosition: containerPosition)
    }
}

// MARK: - ButtonLayoutComputer

private struct ButtonLayoutComputer: StatefulRule {
    @Attribute var button: SwiftUIAppKitButton
    @Attribute var configuration: AppKitButtonConfiguration
    @OptionalAttribute var contentComputer: LayoutComputer?

    typealias Value = LayoutComputer

    mutating func updateValue() {
        update(to: Engine(
            button: button, contentComputer: contentComputer,
            heightBehavior: configuration.appearance.heightBehavior
        ))
    }

    struct Engine: LayoutEngine {
        let button: SwiftUIAppKitButton
        let contentComputer: LayoutComputer?
        let heightBehavior: AppKitButtonAppearance.HeightBehavior
        var cache = ViewSizeCache()

        mutating func sizeThatFits(_ proposal: _ProposedSize) -> CGSize {
            var result = CGSize.zero
            Update.syncMain {
                let metrics = button.metrics
                if button.bezelStyle == .circular {
                    result = metrics.size
                    return
                }
                let insets = metrics.contentInsets
                let proposal = _ProposedSize(
                    width: proposal.width,
                    height: heightBehavior == .flexible ? proposal.height : metrics.size.height
                ).inset(by: insets)
                let computer = contentComputer ?? .defaultValue
                let contentSize = cache.get(proposal) { computer.sizeThatFits(proposal) }
                let height: CGFloat
                switch heightBehavior {
                case .fixed: height = metrics.size.height
                case .fixedWithFlexibleFallback: height = max(metrics.size.height, contentSize.height + insets.vertical)
                case .flexible: height = contentSize.height + insets.vertical
                }
                result = CGSize(width: contentSize.width + insets.horizontal, height: height)
            }
            return result
        }

        func explicitAlignment(_ key: AlignmentKey, at size: ViewSize) -> CGFloat? {
            var result: CGFloat?
            Update.syncMain {
                if button.isBordered {
                    let baselines = button._baselineOffsets(at: size.value)
                    if key == VerticalAlignment.firstTextBaseline.key {
                        result = baselines.firstTextBaseline.isNaN ? 0 : baselines.firstTextBaseline
                    } else if key == VerticalAlignment.lastTextBaseline.key {
                        result = size.height - (baselines.lastTextBaseline.isNaN ? 0 : baselines.lastTextBaseline)
                    }
                } else {
                    result = (contentComputer ?? .defaultValue).explicitAlignment(key, at: size)
                }
            }
            return result
        }
    }
}

// MARK: - UpdatedButton

private struct UpdatedButton: StatefulRule {
    let button: SwiftUIAppKitButton
    @Attribute var configuration: AppKitButtonConfiguration
    @Attribute var environment: EnvironmentValues
    @Attribute var keyboardShortcut: KeyboardShortcut?
    @Attribute var springLoading: SpringLoadingBehavior
    @Attribute var buttonRepeatTiming: ButtonRepeatTiming?
    @Attribute var forceDestructiveAppearance: Bool
    @Attribute var allowsWindowActivationEvents: Bool?

    typealias Value = SwiftUIAppKitButton

    mutating func updateValue() {
        let (environment, changed) = $environment.changedValue()
        if changed {
            Graph.withoutUpdate {
                button.adoptEnvironment(environment, hostedSubview: button)
            }
        }
        let configuration = configuration
        let keyboardShortcut = keyboardShortcut
        let springLoading = springLoading
        let timing = buttonRepeatTiming
        let forceDestructiveAppearance = forceDestructiveAppearance
        let allowsWindowActivationEvents = allowsWindowActivationEvents
        Graph.withoutUpdate {
            button.update(
                configuration: configuration, keyboardShortcut: keyboardShortcut,
                springLoading: springLoading, buttonRepeatTiming: timing,
                forceDestructiveAppearance: forceDestructiveAppearance,
                allowsWindowActivationEvents: allowsWindowActivationEvents
            )
        }
        value = button
    }

    struct WithContainsText: StatefulRule {
        @Attribute var button: SwiftUIAppKitButton
        @Attribute var platformItemList: PlatformItemList

        typealias Value = SwiftUIAppKitButton

        mutating func updateValue() {
            let containsText = platformItemList.items.contains { $0.text != nil }
            Graph.withoutUpdate {
                button.toolbarAppearance = button.configuration?.appearance.isInToolbar == true && containsText ? 2 : 0
            }
            value = button
        }
    }
}

// MARK: - ButtonContentMetrics

private struct ButtonContentMetrics: StatefulRule {
    @Attribute var button: SwiftUIAppKitButton
    @Attribute var size: ViewSize
    @OptionalAttribute var contentComputer: LayoutComputer?

    typealias Value = SwiftUIAppKitButton

    mutating func updateValue() {
        let insets = button.metrics.contentInsets
        let proposal = _ProposedSize(CGRect(origin: .zero, size: size.value).inset(by: insets).size)
        let contentSize = (contentComputer ?? .defaultValue).sizeThatFits(proposal)
        let baselineSize = ViewSize.fixed(CGSize(width: contentSize.width + insets.horizontal, height: contentSize.height))
        let first = contentComputer?.explicitAlignment(VerticalAlignment.firstTextBaseline.key, at: baselineSize)
        let last = contentComputer?.explicitAlignment(VerticalAlignment.lastTextBaseline.key, at: baselineSize)
        let button = button
        Graph.withoutUpdate {
            (button.contentView as! SwiftUIAppKitButton.ContentViewHost).update(
                height: contentSize.height, firstBaseline: first ?? .leastNormalMagnitude,
                lastBaseline: last ?? .leastNormalMagnitude
            )
        }
        value = button
    }
}

// MARK: - ButtonDisplayList

private struct ButtonDisplayList: Rule {
    let identity: DisplayList.Identity
    @Attribute var button: SwiftUIAppKitButton
    @Attribute var configuration: AppKitButtonConfiguration
    @Attribute var position: CGPoint
    @Attribute var size: ViewSize
    @Attribute var containerPosition: CGPoint
    @OptionalAttribute var contentList: DisplayList?

    var value: DisplayList {
        let insets = button.alignmentRectInsets
        let origin = CGPoint(x: position.x - containerPosition.x, y: position.y - containerPosition.y)
        let frame = CGRect(origin: origin, size: size.value).outset(by: EdgeInsets(
            top: insets.top, leading: insets.left, bottom: insets.bottom, trailing: insets.right
        ))
        var item = DisplayList.Item(
            .effect(.platformGroup(button), contentList ?? DisplayList()),
            frame: frame, identity: identity, version: .init(forUpdate: ())
        )
        item.canonicalize()
        return DisplayList(item)
    }
}

// MARK: - ButtonResponder

private struct ButtonResponder: StatefulRule {
    @Attribute var button: SwiftUIAppKitButton
    @Attribute var position: CGPoint
    @Attribute var size: ViewSize
    @Attribute var transform: ViewTransform
    @Attribute var children: [ViewResponder]
    @Attribute var configuration: AppKitButtonConfiguration
    var layoutResponder: DefaultLayoutViewResponder
    var _buttonResponder: NSButtonResponder?

    typealias Value = [ViewResponder]

    mutating func updateValue() {
        let responder = buttonResponder()
        responder.hostView = button
        responder.configuration = configuration
        responder.helper.update(
            data: (TrivialContentResponder(), false), size: $size.changedValue(),
            position: $position.changedValue(), transform: $transform.changedValue(), parent: responder
        )
        layoutResponder.updateChildren($children.changedValue())
        let helper = (button.contentView as! SwiftUIAppKitButton.ContentViewHost).helper
        helper.responder = responder
        helper.focusRingView?.noteFocusRingMaskChanged()
        if !hasValue { value = [responder] }
    }

    mutating func buttonResponder() -> NSButtonResponder {
        if let _buttonResponder { return _buttonResponder }
        let responder = NSButtonResponder(layoutResponder: layoutResponder, configuration: configuration)
        _buttonResponder = responder
        return responder
    }
}

// MARK: - ButtonContentStyle

private struct ButtonContentStyle: ShapeStyle, @unchecked Sendable {
    var contentStyle: (any NSContentStyle)?
    var seed: UInt32
    weak var button: NSButton?

    var fallbackColor: Color? {
        guard let contentStyle else { return nil }
        return Color(nsColor: NSColor(name: nil) { _ in
            contentStyle.equivalentForegroundColorForTemplateImage ?? .clear
        })
    }

    func _apply(to shape: inout _ShapeStyle_Shape) {
        guard contentStyle != nil else {
            HierarchicalShapeStyle.primary._apply(to: &shape)
            return
        }
        switch shape.operation {
        case .prepareText:
            shape.result = .preparedText(.foregroundKeyColor)
        case let .resolveStyle(name, levels):
            guard !levels.isEmpty else { return }
            let (color, blendMode) = resolve(in: shape.environment)
            var resolvedColor = Color.Resolved(color)
            resolvedColor.opacity *= shape.opacity(at: levels.lowerBound)
            var style = _ShapeStyle_Pack.Style(.color(resolvedColor))
            style.applyBlend(GraphicsBlendMode(BlendMode(blendMode)))
            shape.stylePack[name, levels.lowerBound] = style
        case .fallbackColor:
            if let fallbackColor { shape.result = .color(fallbackColor) }
        default:
            break
        }
    }

    func resolve(in environment: EnvironmentValues) -> (CGColor, CGBlendMode) {
        let appearance = NSAppearance.appearance(from: environment, allowsVibrantBlending: nil)
            ?? NSApp.effectiveAppearance
        var color: CGColor?
        var blendMode = CGBlendMode.normal
        appearance.performAsCurrentDrawingAppearance {
            if let contentStyle, let foreground = contentStyle.equivalentForegroundColorForTemplateImage {
                color = foreground.cgColor
                blendMode = CGBlendMode(rawValue: contentStyle.outputBlendModeForTemplateContent)!
            }
        }
        if let button,
           button.responds(to: #selector(NSButton.effectiveVibrancyBlendMode(for:))),
           button.effectiveVibrancyBlendMode(for: appearance) == Int32(blendMode.rawValue),
           let color {
            return (color, .normal)
        }
        return (color ?? .clear, blendMode)
    }

    typealias Resolved = Never
}

#endif
