//
//  Image.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: BE2D783904D422377BBEBAC3C942583C (SwiftUICore)

package import OpenAttributeGraphShims
package import OpenCoreGraphicsShims
package import OpenRenderBoxShims
#if OPENSWIFTUI_LINK_COREUI
package import CoreUI
#endif

// MARK: - Image

/// A view that displays an image.
///
/// Use an `Image` instance when you want to add images to your OpenSwiftUI app.
/// You can create images from many sources:
///
/// * Image files in your app's asset library or bundle. Supported types include
/// PNG, JPEG, HEIC, and more.
/// * Instances of platform-specific image types, like
/// [UIImage](https://developer.apple.com/documentation/uikit/uiimage) and
/// [NSImage](https://developer.apple.com/documentation/appkit/nsimage).
/// * A bitmap stored in a Core Graphics
/// [CGImage](https://developer.apple.com/documentation/coregraphics/cgimage)
///  instance.
/// * System graphics from the SF Symbols set.
///
/// The following example shows how to load an image from the app's asset
/// library or bundle and scale it to fit within its container:
///
///     Image("Landscape_4")
///         .resizable()
///         .aspectRatio(contentMode: .fit)
///     Text("Water wheel")
///
/// ![An image of a water wheel and its adjoining building, resized to fit the
/// width of an iPhone display. The words Water wheel appear under this
/// image.](Image-1.png)
///
/// You can use methods on the `Image` type as well as
/// standard view modifiers to adjust the size of the image to fit your app's
/// interface. Here, the `Image` type's
/// ``Image/resizable(capInsets:resizingMode:)`` method scales the image to fit
/// the current view. Then, the
/// ``View/aspectRatio(_:contentMode:)`` view modifier adjusts
/// this resizing behavior to maintain the image's original aspect ratio, rather
/// than scaling the x- and y-axes independently to fill all four sides of the
/// view. The article
/// <doc:Fitting-Images-into-Available-Space> shows how to apply scaling,
/// clipping, and tiling to `Image` instances of different sizes.
///
/// An `Image` is a late-binding token; the system resolves its actual value
/// only when it's about to use the image in an environment.
///
/// ### Making images accessible
///
/// To use an image as a control, use one of the initializers that takes a
/// `label` parameter. This allows the system's accessibility frameworks to use
/// the label as the name of the control for users who use features like
/// VoiceOver. For images that are only present for aesthetic reasons, use an
/// initializer with the `decorative` parameter; the accessibility systems
/// ignore these images.
@available(OpenSwiftUI_v1_0, *)
@frozen
public struct Image: Equatable, Sendable {
    package var provider: AnyImageProviderBox

    package init<P>(_ provider: P) where P: ImageProvider {
        self.provider = ImageProviderBox(base: provider)
    }

    package func resolve(in context: ImageResolutionContext) -> Image.Resolved {
        provider.resolve(in: context)
    }

    package func resolveNamedImage(in context: ImageResolutionContext) -> Image.NamedResolved? {
        provider.resolveNamedImage(in: context)
    }

    public static func == (lhs: Image, rhs: Image) -> Bool {
        lhs.provider.isEqual(to: rhs.provider)
    }
}

// MARK: - ImageResolutionContext

package struct ImageResolutionContext {
    package struct Options: OptionSet {
        package let rawValue: UInt8

        package init(rawValue: UInt8) {
            self.rawValue = rawValue
        }

        package static let inferSymbolRenderingMode: ImageResolutionContext.Options = .init(rawValue: 1 << 0)

        package static let isArchived: ImageResolutionContext.Options = .init(rawValue: 1 << 1)

        package static let useCatalogReferences: ImageResolutionContext.Options = .init(rawValue: 1 << 2)

        package static let animationsDisabled: ImageResolutionContext.Options = .init(rawValue: 1 << 3)

        package static let preservesVectors: ImageResolutionContext.Options = .init(rawValue: 1 << 4)
    }

    package var environment: EnvironmentValues

    package var symbolAnimator: ORBSymbolAnimator?

    package var textStyle: Text.Style?

    package var transaction: OptionalAttribute<Transaction>

    package var symbolRenderingMode: SymbolRenderingMode?

    package var allowedDynamicRange: Image.DynamicRange?

    package var options: ImageResolutionContext.Options = .inferSymbolRenderingMode

    package init(
        environment: EnvironmentValues,
        textStyle: Text.Style? = nil,
        transaction: OptionalAttribute<Transaction> = .init()
    ) {
        self.environment = environment
        self.textStyle = textStyle
        self.transaction = transaction
    }

    /// Determines how to animate a vector glyph (SF Symbol) transition when the
    /// ``symbolAnimator`` is being reused.
    ///
    /// This method handles three cases:
    /// 1. No previous glyph (first-time setup) or different glyph — animate
    ///    based on the content transition type from the environment.
    /// 2. Same glyph, different variable value — animate variable value change.
    /// 3. Same glyph, same value — no animation needed.
    ///
    /// Animation types used:
    /// - ``ORBSymbolAnimation/variableValue``: variable value change
    /// - ``ORBSymbolAnimation/replace``: symbol replace animation
    /// - ``ORBSymbolAnimation/interpolate``: interpolate animation
    ///
    /// - Parameters:
    ///   - glyph: The new vector glyph to transition to.
    ///   - variableValue: The new variable value for the glyph.
    /// - Returns: `true` if content transitions are allowed (no animator, animations
    ///   disabled, or no transaction), `false` if animation was handled by the animator.
    package func willUpdateVectorGlyph(
        to glyph: CUINamedVectorGlyph,
        variableValue: CGFloat
    ) -> Bool {
        #if canImport(Darwin)
        guard let symbolAnimator,
              !options.contains(.animationsDisabled),
              let transactionAttribute = transaction.attribute
        else { return true }
        let oldGlyph = symbolAnimator.glyph
        guard oldGlyph !== glyph else {
            if symbolAnimator.variableValue != variableValue {
                let transaction = Graph.withoutUpdate { transactionAttribute.value }
                guard !transaction.disablesAnimations else { return false }
                symbolAnimator.addAnimation(
                    .variableValue,
                    options: [:],
                    animationListener: transaction.animationListener,
                    logicalListener: transaction.animationLogicalListener
                )
            }
            return false
        }
        let transaction = Graph.withoutUpdate { transactionAttribute.value }
        guard !transaction.disablesAnimations else { return false }

        // TBA: FIXME when we implement ContentTransition and ORBAnimation
        let contentTransitionState = environment.contentTransitionState
        let contentAnimation = contentTransitionState.animation
        let transition = contentTransitionState.transition
        let isReplaceable = transition.isReplaceable

        if let contentAnimation {
            if case .symbolReplace(let replaceConfig) = transition.storage {
                if let oldGlyph, oldGlyph.canBeInterpolated(with: glyph) {
                } else {
                    var options = replaceConfig.animationOptions
                    options[.timing] = contentAnimation.rbAnimation
                    symbolAnimator.addAnimation(
                        .replace,
                        options: options,
                        animationListener: transaction.animationListener,
                        logicalListener: transaction.animationLogicalListener
                    )
                    return false
                }
            }
            // Interpolate animation with content animation timing
            var options: [ORBSymbolAnimation.OptionKey: Any] = [
                .timing: contentAnimation.rbAnimation
            ]
            let isInterpolate = transition.storage == ContentTransition.interpolate.storage
            if !isInterpolate || isReplaceable != ContentTransition.interpolate.isReplaceable {
                options[.interpolateOptions] = true
            }
            symbolAnimator.addAnimation(
                .interpolate,
                options: options,
                animationListener: transaction.animationListener,
                logicalListener: transaction.animationLogicalListener
            )
            return false
        }

        // No content animation: dispatch on storage type
        switch transition.storage {
        case .symbolReplace(let replaceConfig):
            var options = replaceConfig.animationOptions
            if let contentAnimation = environment.contentTransitionState.animation {
                options[.timing] = contentAnimation.rbAnimation
            } else if let transactionAnimation = transaction.animation {
                options[.timing] = transactionAnimation.rbAnimation
            }
            symbolAnimator.addAnimation(
                .replace,
                options: options,
                animationListener: transaction.animationListener,
                logicalListener: transaction.animationLogicalListener
            )
            return false

        case .named(let named):
            if case .default = named.name {
                // Resolve .default: >= v4 → .interpolate, else .identity
                let resolved = isLinkedOnOrAfter(.v4) ? ContentTransition.interpolate : .identity
                if case .symbolReplace(let replaceConfig) = resolved.storage {
                    var options = replaceConfig.animationOptions
                    if let contentAnimation = environment.contentTransitionState.animation {
                        options[.timing] = contentAnimation.rbAnimation
                    } else if let transactionAnimation = transaction.animation {
                        options[.timing] = transactionAnimation.rbAnimation
                    }
                    symbolAnimator.addAnimation(
                        .replace,
                        options: options,
                        animationListener: transaction.animationListener,
                        logicalListener: transaction.animationLogicalListener
                    )
                    return false
                }
            }
            // .default (non-replace), .diff, and all other named transitions
            guard let transactionAnimation = transaction.animation else {
                return false
            }
            var options: [ORBSymbolAnimation.OptionKey: Any] = [
                .timing: transactionAnimation.rbAnimation
            ]
            let isInterpolate = ContentTransition.default.storage == ContentTransition.interpolate.storage
            if !isInterpolate || isReplaceable != ContentTransition.interpolate.isReplaceable {
                options[.interpolateOptions] = true
            }
            symbolAnimator.addAnimation(
                .interpolate,
                options: options,
                animationListener: transaction.animationListener,
                logicalListener: transaction.animationLogicalListener
            )
            return false
        }
        #else
        _openSwiftUIUnimplementedWarning()
        return false
        #endif
    }

    package var effectiveSymbolRenderingMode: SymbolRenderingMode? {
        if let mode = symbolRenderingMode {
            return mode
        }
        if let envMode = environment.symbolRenderingMode {
            return envMode
        }
        if ForegroundStyle().isMultiLevel(in: environment) {
            return .palette
        }
        guard options.contains(.inferSymbolRenderingMode) else {
            return nil
        }
        return SymbolRenderingMode.preferredIfEnabled ?? .monochrome
    }

    package func effectiveAllowedDynamicRange(for image: GraphicsImage) -> Image.DynamicRange? {
        #if canImport(CoreGraphics)
        guard allowedDynamicRange != .none else {
            return .none
        }
        guard case let .cgImage(cgImage) = image.contents,
                let colorSpace = cgImage.colorSpace,
                CGColorSpaceUsesITUR_2100TF(colorSpace)
        else {
            return .none
        }
        let allowedDynamicRange = allowedDynamicRange ?? environment.allowedDynamicRange
        let maxAllowedDynamicRange = environment.maxAllowedDynamicRange
        guard let allowedDynamicRange else {
            return maxAllowedDynamicRange
        }
        guard let maxAllowedDynamicRange else {
            return allowedDynamicRange
        }
        return .init(storage: min(allowedDynamicRange.storage, maxAllowedDynamicRange.storage))
        #else
        _openSwiftUIPlatformUnimplementedFailure()
        #endif
    }
}

// MARK: - ImageProvider

package protocol ImageProvider: Equatable {
    func resolve(in context: ImageResolutionContext) -> Image.Resolved

    func resolveNamedImage(in context: ImageResolutionContext) -> Image.NamedResolved?
}

// MARK: - Image + View

package protocol ImageStyleProtocol {
    static func _makeImageView(view: _GraphValue<Image>, inputs: _ViewInputs) -> _ViewOutputs
}

@available(OpenSwiftUI_v1_0, *)
extension Image: View, UnaryView, PrimitiveView {
    package struct Style: ViewInput {
        package static let defaultValue: Stack<any ImageStyleProtocol.Type> = .empty
    }

    nonisolated public static func _makeView(
        view: _GraphValue<Self>,
        inputs: _ViewInputs
    ) -> _ViewOutputs {
        var newInputs = inputs
        guard let style = newInputs.popLast(Style.self) else {
            let flags = inputs.archivedView.flags
            var options: ImageResolutionContext.Options = []
            if flags.contains(.isArchived) {
                options.formUnion([.isArchived, .preservesVectors])
                if flags.contains(.assetCatalogRefences) {
                    options.formUnion(.useCatalogReferences)
                }
            }
            if inputs.base.animationsDisabled {
                options.formUnion(.animationsDisabled)
            }
            if newInputs.usingGraphicsRenderer, !flags.contains(.isArchived) {
                options.formUnion(.preservesVectors)
            }
            var outputs = _ViewOutputs()
            makeImageViewChild(
                newInputs.imageAccessibilityProvider,
                image: view.value,
                options: options,
                inputs: inputs,
                outputs: &outputs
            )
            if let representation = inputs.requestedNamedImageRepresentation,
               representation.shouldMakeRepresentation(inputs: inputs) {
                let context = Attribute(
                    MakeRepresentableContext(
                        image: view.value,
                        environment: inputs.environment
                    )
                )
                representation.makeRepresentation(
                    inputs: inputs,
                    context: context,
                    outputs: &outputs
                )
            }
            return outputs
        }
        return style._makeImageView(view: view, inputs: newInputs)
    }

    nonisolated private static func makeImageViewChild<P>(
        _ type: P.Type,
        image: Attribute<Image>,
        options: ImageResolutionContext.Options,
        inputs: _ViewInputs,
        outputs: inout _ViewOutputs
    ) where P: ImageAccessibilityProvider {
        let child = Attribute(
            ImageViewChild<P>(
                view: image,
                environment: inputs.environment,
                transaction: inputs.transaction,
                position: inputs.position,
                size: inputs.size,
                transform: inputs.transform,
                options: options,
                parentID: inputs.scrapeableParentID,
                symbolAnimator: nil,
                symbolEffects: .init()
            )
        )
        child.flags = [
            .transactional,
            inputs.isScrapeable ? .scrapeable : []
        ]
        outputs = P.Body.makeDebuggableView(view: .init(child), inputs: inputs)
    }

    private struct MakeRepresentableContext: Rule, AsyncAttribute {
        @Attribute var image: Image
        @Attribute var environment: EnvironmentValues

        var value: PlatformNamedImageRepresentableContext {
            PlatformNamedImageRepresentableContext(
                image: image,
                environment: environment
            )
        }
    }

    private struct ImageViewChild<P>: StatefulRule, AsyncAttribute, ScrapeableAttribute where P: ImageAccessibilityProvider {
        @Attribute var view: Image
        @Attribute var environment: EnvironmentValues
        @Attribute var transaction: Transaction
        @Attribute var position: CGPoint
        @Attribute var size: ViewSize
        @Attribute var transform: ViewTransform
        let options: ImageResolutionContext.Options
        let parentID: ScrapeableID
        let tracker: PropertyList.Tracker
        var symbolAnimator: ORBSymbolAnimator?
        var symbolEffects: _SymbolEffect.Phase

        init(
            view: Attribute<Image>,
            environment: Attribute<EnvironmentValues>,
            transaction: Attribute<Transaction>,
            position: Attribute<CGPoint>,
            size: Attribute<ViewSize>,
            transform: Attribute<ViewTransform>,
            options: ImageResolutionContext.Options,
            parentID: ScrapeableID,
            symbolAnimator: ORBSymbolAnimator?,
            symbolEffects: _SymbolEffect.Phase
        ) {
            self._view = view
            self._environment = environment
            self._transaction = transaction
            self._position = position
            self._size = size
            self._transform = transform
            self.options = options
            self.parentID = parentID
            self.tracker = .init()
            self.symbolAnimator = symbolAnimator
            self.symbolEffects = symbolEffects
        }

        typealias Value = P.Body

        mutating func updateValue() {
            let (view, viewChanged) = $view.changedValue()
            let changed: Bool
            if viewChanged {
                changed = true
            } else {
                let (environment, environmentChanged) = $environment.changedValue()
                if environmentChanged, tracker.hasDifferentUsedValues(environment.plist) {
                    changed = true
                } else {
                    changed = !hasValue
                }
            }
            guard changed else { return }
            tracker.reset()
            tracker.initializeValues(from: environment.plist)
            let newEnvironment = EnvironmentValues(environment.plist, tracker: tracker)
            var resolutionContext = ImageResolutionContext(
                environment: newEnvironment,
                textStyle: nil,
                transaction: .init($transaction)
            )
            resolutionContext.symbolAnimator = symbolAnimator
            resolutionContext.options.formUnion(options)
            var resolved = view.resolve(in: resolutionContext)
            symbolAnimator = resolved.image.updateSymbolEffects(
                &symbolEffects,
                environment: newEnvironment,
                transaction: $transaction,
                animationsDisabled: options.contains(.animationsDisabled)
            )

            value = P.makeView(image: view, resolved: resolved)
        }
        
        static func scrapeContent(from ident: AnyAttribute) -> ScrapeableContent.Item? {
            let child = ident.info.body.assumingMemoryBound(to: ImageViewChild.self)[]
            return ScrapeableContent.Item(
                .image(child.view, child.environment),
                ids: .none,
                child.parentID,
                position: child.$position,
                size: child.$size,
                transform: child.$transform
            )
        }
    }
}

// MARK: - ImageProviderBox

@available(OpenSwiftUI_v1_0, *)
@usableFromInline
package class AnyImageProviderBox: @unchecked Sendable {
    func resolve(in context: ImageResolutionContext) -> Image.Resolved {
        _openSwiftUIBaseClassAbstractMethod()
    }

    func resolveNamedImage(in context: ImageResolutionContext) -> Image.NamedResolved? {
        _openSwiftUIBaseClassAbstractMethod()
    }

    func isEqual(to other: AnyImageProviderBox) -> Bool {
        _openSwiftUIBaseClassAbstractMethod()
    }
}

final package class ImageProviderBox<Base>: AnyImageProviderBox, @unchecked Sendable where Base: ImageProvider {
    package let base: Base

    init(base: Base) {
        self.base = base
    }

    override func resolve(in context: ImageResolutionContext) -> Image.Resolved {
        base.resolve(in: context)
    }

    override func resolveNamedImage(in context: ImageResolutionContext) -> Image.NamedResolved? {
        base.resolveNamedImage(in: context)
    }

    override func isEqual(to other: AnyImageProviderBox) -> Bool {
        guard let other = (other as? ImageProviderBox<Base>) else {
            return false
        }
        return base == other.base
    }
}

// FIXME

extension ORBSymbolAnimator {
    // TODO: 2975F89CBD28662DFA5DA6D958CBE343
    @discardableResult
    fileprivate func addAnimation(
        _ animation: ORBSymbolAnimation,
        options: [ORBSymbolAnimation.OptionKey: Any],
        animationListener: AnimationListener?,
        logicalListener: AnimationListener?
    ) -> UInt32 {
        _openSwiftUIUnimplementedFailure()
    }
}

struct ORBSymbolAnimation: RawRepresentable {
    let rawValue: Int

    /// Variable value change
    static let variableValue = ORBSymbolAnimation(rawValue: 0x0)
    /// Symbol replace animation
    static let replace = ORBSymbolAnimation(rawValue: 0x6)
    /// Interpolate animation
    static let interpolate = ORBSymbolAnimation(rawValue: 0x7)

    struct OptionKey: RawRepresentable, Hashable {
        let rawValue: String
    }
}

extension ORBSymbolAnimation.OptionKey {
    static let timing = ORBSymbolAnimation.OptionKey(rawValue: "ORBSymbolAnimationTiming")
    static let interpolateOptions = ORBSymbolAnimation.OptionKey(rawValue: "ORBSymbolAnimationInterpolateOptions")
    static let replaceOptions = ORBSymbolAnimation.OptionKey(rawValue: "ORBSymbolAnimationReplaceOptions")
    static let byLayer = ORBSymbolAnimation.OptionKey(rawValue: "ORBSymbolAnimationByLayer")
    static let speed = ORBSymbolAnimation.OptionKey(rawValue: "ORBSymbolAnimationSpeed")
}

extension Animation {
    fileprivate var rbAnimation: ORBAnimation {
        let animation = ORBAnimation()
        // function.apply(to: animation)
        return animation
    }
}

extension _SymbolEffect.ReplaceConfiguration {
    fileprivate var animationOptions: [ORBSymbolAnimation.OptionKey: Any] {
        [
            .replaceOptions: self,
//            .byLayer: byLayer,
//            .speed: speed,
        ]
    }
}
