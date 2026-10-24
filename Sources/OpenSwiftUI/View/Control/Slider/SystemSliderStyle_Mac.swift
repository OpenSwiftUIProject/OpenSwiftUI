//
//  SystemSliderStyle_Mac.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: A7473CA4D30DB9CE24790738AC72AF8E (SwiftUI)

#if os(macOS)
import AppKit
import COpenSwiftUI
@_spi(ForOpenSwiftUIOnly)
import OpenSwiftUICore
#if OPENSWIFTUI_LINK_SYMBOLS
import Symbols
#endif

// MARK: - PlatformSliderStyle

struct PlatformSliderStyle: SliderStyle {
    var isVertical: Bool = false

    var showTickMarks: Bool = false

    @State private var symbolEffectState = SymbolEffectState()

    func makeBody(configuration: Configuration) -> some View {
        let content = LabeledContent {
            HStack(alignment: .center, spacing: 4) {
                valueLabel(configuration.minimumValueLabel, configuration: configuration)
                    #if OPENSWIFTUI_LINK_SYMBOLS
                    .symbolEffect(.bounce, value: symbolEffectState.minimumValueLabelSeed)
                    #else
                    .symbolEffect(.bounce(value: symbolEffectState.minimumValueLabelSeed))
                    #endif
                VStack(alignment: .center, spacing: 2) {
                    SystemSlider(
                        value: configuration.$value,
                        onEditingChanged: configuration.onEditingChanged,
                        isVertical: isVertical,
                        markConfiguration: MarkConfiguration(
                            discreteValueCount: configuration.discreteValueCount,
                            markValues: configuration.marks.map { $0.map(\.value) }
                        ),
                        symbolEffectState: $symbolEffectState
                    )
                    if let marks = configuration.marks {
                        SliderMarkLabels(marks: marks)
                    }
                }
                valueLabel(configuration.maximumValueLabel, configuration: configuration)
                    #if OPENSWIFTUI_LINK_SYMBOLS
                    .symbolEffect(.bounce, value: symbolEffectState.maximumValueLabelSeed)
                    #else
                    .symbolEffect(.bounce(value: symbolEffectState.maximumValueLabelSeed))
                    #endif
            }
        } label: {
            configuration.label
        }
        .accessibilityLabeledContent()
        return AccessibilitySliderMarkModifier(configuration: .init(
            marks: configuration.marks,
            bounds: 0 ... 1
        ))
        .body(content: content)
        .spacing(Spacing())
    }

    private func valueLabel<Label>(
        _ label: Label,
        configuration: SliderStyleConfiguration
    ) -> some View where Label: View {
        StaticIf(_SemanticFeature_v4.self) {
            InteractiveValueLabel(base: label, configuration: configuration)
        } else: {
            ValueLabel(base: label)
                .defaultForegroundStyle(HierarchicalShapeStyle.secondary)
        }
    }
}

// MARK: - MarkConfiguration

private struct MarkConfiguration: Equatable {
    var discreteValueCount: Int

    var markValues: [Double]?

    var numberOfTickMarks: Int {
        markValues?.count ?? discreteValueCount
    }

    func closestSnapPoint(to value: Double) -> (index: Int, value: Double) {
        if discreteValueCount == 1 {
            return (0, 0.5)
        } else if discreteValueCount != 0 {
            let maxIndex = Double(discreteValueCount - 1)
            let index = (maxIndex * value).rounded()
            return (Int(index), index / maxIndex)
        } else if let markValues {
            var closestIndex = -1
            var closestDistance = Double.greatestFiniteMagnitude
            for (index, markValue) in markValues.enumerated() {
                let distance = abs(value - markValue)
                if distance < closestDistance {
                    closestIndex = index
                    closestDistance = distance
                }
            }
            return (closestIndex, markValues[closestIndex])
        } else {
            return (-1, value)
        }
    }
}

// MARK: - CustomMarkedSlider

private final class CustomMarkedSlider: NSSlider, AcceptsFirstMouseCustomizing {
    var customAcceptsFirstMouse: Bool?

    override class var cellClass: AnyClass? {
        get { CustomMarkedSliderCell.self }
        set { _openSwiftUIEmptyStub() }
    }

    override func acceptsFirstMouse(for event: NSEvent?) -> Bool {
        if ResponderBasedHitTesting.isEnabled {
            customAcceptsFirstMouse ?? super.acceptsFirstMouse(for: event)
        } else {
            effectiveAcceptsFirstMouse ?? super.acceptsFirstMouse(for: event)
        }
    }
}

// MARK: - CustomMarkedSliderCell

private final class CustomMarkedSliderCell: NSSliderCell {
    var markConfiguration: MarkConfiguration? {
        didSet {
            guard markConfiguration != oldValue else {
                return
            }
            numberOfTickMarks = 0
            numberOfTickMarks = markConfiguration?.numberOfTickMarks ?? 0
        }
    }

    override func tickMarkValue(at index: Int) -> Double {
        guard let markConfiguration else {
            return super.tickMarkValue(at: index)
        }
        if let markValues = markConfiguration.markValues {
            return markValues[index]
        }
        let maxIndex = markConfiguration.discreteValueCount - 1
        guard maxIndex != 0 else {
            return 0.5
        }
        return Double(index) / Double(maxIndex)
    }

    override func closestTickMarkValue(toValue value: Double) -> Double {
        guard let markConfiguration else {
            return super.closestTickMarkValue(toValue: value)
        }
        return markConfiguration.closestSnapPoint(to: value).value
    }

    override func closestTickMarkIndex(toValue value: Double) -> Int {
        guard let markConfiguration else {
            return super.closestTickMarkIndex(toValue: value)
        }
        return markConfiguration.closestSnapPoint(to: value).index
    }
}

// MARK: - SystemSlider

private struct SystemSlider: NSViewRepresentable {
    static let willBeginTrackingNotification = NSNotification.Name("NSControlWillBeginContinuousTrackingNotification")

    static let didEndTrackingNotification = NSNotification.Name("NSControlDidEndContinuousTrackingNotification")

    static let didCancelTrackingNotification = NSNotification.Name("NSControlDidCancelContinuousTrackingNotification")

    @Binding var value: Double

    var onEditingChanged: (Bool) -> Void

    var isVertical: Bool

    var markConfiguration: MarkConfiguration

    @Binding var symbolEffectState: PlatformSliderStyle.SymbolEffectState

    @Environment(\.tintColor)
    private var controlTint: Color?

    @Environment(\.layoutDirection)
    private var layoutDirection: LayoutDirection

    @Environment(\.allowsWindowActivationEvents)
    private var acceptsFirstMouse: Bool?

    func makeNSView(context: Context) -> CustomMarkedSlider {
        let slider = CustomMarkedSlider(
            target: context.coordinator,
            action: #selector(Coordinator.valueChanged(_:))
        )
        let center = NotificationCenter.default
        center.addObserver(
            context.coordinator,
            selector: #selector(Coordinator.userInteractionStarted(_:)),
            name: Self.willBeginTrackingNotification,
            object: slider
        )
        center.addObserver(
            context.coordinator,
            selector: #selector(Coordinator.userInteractionEnded(_:)),
            name: Self.didEndTrackingNotification,
            object: slider
        )
        center.addObserver(
            context.coordinator,
            selector: #selector(Coordinator.userInteractionEnded(_:)),
            name: Self.didCancelTrackingNotification,
            object: slider
        )
        return slider
    }

    func updateNSView(_ nsView: CustomMarkedSlider, context: Context) {
        if let cell = nsView.cell as? CustomMarkedSliderCell {
            cell.markConfiguration = markConfiguration
        }
        nsView.allowsTickMarkValuesOnly = markConfiguration.discreteValueCount > 0
        nsView.isVertical = isVertical
        let direction: NSUserInterfaceLayoutDirection = layoutDirection == .rightToLeft ? .rightToLeft : .leftToRight
        if nsView.userInterfaceLayoutDirection != direction {
            nsView.userInterfaceLayoutDirection = direction
        }
        if context.transaction.animation != nil {
            nsView.animator().doubleValue = value
        } else {
            nsView.doubleValue = value
        }
        context.coordinator.configuration = self
        if let controlTint {
            nsView.trackFillColor = NSColor(controlTint)
        }
        nsView.customAcceptsFirstMouse = acceptsFirstMouse
    }

    static func dismantleNSView(_ nsView: CustomMarkedSlider, coordinator: Coordinator) {
        let center = NotificationCenter.default
        center.removeObserver(coordinator, name: willBeginTrackingNotification, object: nsView)
        center.removeObserver(coordinator, name: didEndTrackingNotification, object: nsView)
        center.removeObserver(coordinator, name: didCancelTrackingNotification, object: nsView)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(configuration: self)
    }
}

// MARK: - Coordinator

private class Coordinator: PlatformViewCoordinator {
    enum TrackingState {
        case none
        case userInteractionStarted
        case editing
    }

    var configuration: SystemSlider

    var trackingState: TrackingState = .none

    init(configuration: SystemSlider) {
        self.configuration = configuration
        super.init()
    }

    @objc
    func valueChanged(_ slider: NSSlider) {
        guard configuration.value != slider.doubleValue else {
            return
        }
        let isTracking: Bool
        switch trackingState {
        case .none:
            trackingState = .editing
            Update.dispatchImmediately(reason: nil) {
                configuration.onEditingChanged(true)
            }
            isTracking = false
        case .userInteractionStarted:
            trackingState = .editing
            Update.dispatchImmediately(reason: nil) {
                configuration.onEditingChanged(true)
            }
            isTracking = true
        case .editing:
            isTracking = true
        }
        configuration.value = slider.doubleValue
        slider.doubleValue = configuration.value
        if isTracking {
            let value = configuration.value
            var symbolEffectState = configuration.symbolEffectState
            if value == 0 {
                symbolEffectState.minimumValueLabelSeed &+= 1
            } else if value == 1 {
                symbolEffectState.maximumValueLabelSeed &+= 1
            }
            configuration.symbolEffectState = symbolEffectState
        } else {
            trackingState = .none
            Update.dispatchImmediately(reason: nil) {
                configuration.onEditingChanged(false)
            }
        }
    }

    @objc
    func userInteractionStarted(_ slider: NSSlider) {
        trackingState = .userInteractionStarted
    }

    @objc
    func userInteractionEnded(_ slider: NSSlider) {
        if trackingState == .editing {
            Update.dispatchImmediately(reason: nil) {
                configuration.onEditingChanged(false)
            }
        }
        trackingState = .none
    }
}

// MARK: - SliderMarkLabels

struct SliderMarkLabels: View {
    @Environment(\.isEnabled)
    private var enabled: Bool

    var marks: [SliderMark<Double>]

    var body: some View {
        LabelLayout(markValues: marks.map(\.value)) {
            ForEach(marks) { mark in
                VStack {
                    mark.label
                }
            }
        }
        .defaultForegroundStyle(enabled ? HierarchicalShapeStyle.primary : .tertiary)
        .font(.caption)
        .lineLimit(1)
        .accessibilityDisabled()
        .textSelection(.disabled)
    }

    private struct LabelLayout: Layout {
        var markValues: [Double]

        func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
            let sizes = subviews.map { $0.sizeThatFits(proposal) }
            return CGSize(
                width: proposal.width ?? sizes.reduce(0) { $0 + $1.width },
                height: sizes.reduce(0) { max($0, $1.height) }
            )
        }

        func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
            guard bounds.width > 0 else {
                return
            }
            var resolver = LabelLayoutResolver(parentFrame: bounds, markValues: markValues, subviews: subviews)
            resolver.layout()
        }

        struct LabelInfo {
            let markValue: Double
            var markValueRange: ClosedRange<Double> = 0 ... 1
            let markIndex: Int
            let view: LayoutSubview
            var finalFrame: CGRect?
            let desiredFrame: CGRect
        }

        struct LabelLayoutResolver {
            let parentFrame: CGRect
            var labels: [LabelInfo]
            let sortedLabelIndices: [Int]

            init(parentFrame: CGRect, markValues: [Double], subviews: Subviews) {
                self.parentFrame = parentFrame
                sortedLabelIndices = subviews.enumerated().sorted { lhs, rhs in
                    if lhs.element.priority != rhs.element.priority {
                        return lhs.element.priority > rhs.element.priority
                    } else if lhs.offset == 0 {
                        return true
                    } else if rhs.offset == 0 {
                        return false
                    } else if lhs.offset == subviews.count - 1 {
                        return true
                    } else if rhs.offset == subviews.count - 1 {
                        return false
                    } else {
                        return lhs.offset < rhs.offset
                    }
                }.map(\.offset)
                labels = subviews.enumerated().map { index, view in
                    let value = markValues[index]
                    let size = view.sizeThatFits(.unspecified)
                    let frame = CGRect(
                        position: CGPoint(x: parentFrame.minX + value * parentFrame.width, y: parentFrame.minY),
                        size: size,
                        anchor: UnitPoint(x: value, y: 0)
                    )
                    return LabelInfo(markValue: value, markIndex: index, view: view, desiredFrame: frame)
                }
            }

            func availableXOffset(label: LabelInfo) -> ClosedRange<CGFloat> {
                let size = label.desiredFrame.size
                let lowerValue = label.markValueRange.lowerBound
                let upperValue = label.markValueRange.upperBound
                let lowerFrame = CGRect(
                    position: CGPoint(x: parentFrame.minX + lowerValue * parentFrame.width, y: parentFrame.minY),
                    size: size,
                    anchor: UnitPoint(x: lowerValue, y: 0)
                )
                let upperFrame = CGRect(
                    position: CGPoint(x: parentFrame.minX + upperValue * parentFrame.width, y: parentFrame.minY),
                    size: size,
                    anchor: UnitPoint(x: upperValue, y: 0)
                )
                return ClosedRange(bounds: lowerFrame.minX, upperFrame.minX)
                    .offset(by: -label.desiredFrame.minX)
            }

            mutating func place(labelIndex: Int, markValue: Double) {
                let frame = CGRect(
                    position: CGPoint(x: parentFrame.minX + markValue * parentFrame.width, y: parentFrame.minY),
                    size: labels[labelIndex].desiredFrame.size,
                    anchor: UnitPoint(x: markValue, y: 0)
                )
                labels[labelIndex].finalFrame = frame
                labels[labelIndex].view.place(at: frame.origin, anchor: .topLeading, proposal: .unspecified)
                for index in 0 ..< labelIndex {
                    let range = labels[index].markValueRange
                    labels[index].markValueRange = min(range.lowerBound, markValue) ... min(range.upperBound, markValue)
                }
                for index in (labelIndex + 1) ..< labels.count {
                    let range = labels[index].markValueRange
                    labels[index].markValueRange = max(range.lowerBound, markValue) ... max(range.upperBound, markValue)
                }
            }

            mutating func layout() {
                for index in sortedLabelIndices {
                    let label = labels[index]
                    let paddedFrame = label.desiredFrame.outset(by: EdgeInsets(top: 0, leading: 4, bottom: 0, trailing: 4))
                    let previousFrame = index > 0 ? labels[index - 1].finalFrame : nil
                    let nextFrame = index < labels.count - 1 ? labels[index + 1].finalFrame : nil
                    let overlapsPrevious = previousFrame.map { !$0.intersection(paddedFrame).isEmpty } ?? false
                    let overlapsNext = nextFrame.map { !$0.intersection(paddedFrame).isEmpty } ?? false
                    let offset: CGFloat
                    if overlapsPrevious && !overlapsNext, let previousFrame {
                        offset = previousFrame.maxX - paddedFrame.minX
                    } else if overlapsNext && !overlapsPrevious, let nextFrame {
                        offset = nextFrame.minX - paddedFrame.maxX
                    } else {
                        place(labelIndex: index, markValue: label.markValue)
                        continue
                    }
                    let frame = label.desiredFrame.offsetBy(dx: offset.clamped(to: availableXOffset(label: label)), dy: 0)
                    let value = (frame.origin.x - parentFrame.origin.x) / (parentFrame.width - frame.width)
                    place(labelIndex: index, markValue: Double(value.clamped(to: 0 ... 1)))
                }
            }
        }
    }
}
#endif
