//
//  AccessibilityTraits.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete

package import OpenSwiftUI_SPI

/// A set of accessibility traits that describe how an element behaves.
@available(OpenSwiftUI_v1_0, *)
public struct AccessibilityTraits: SetAlgebra, Sendable {
    var traitSet: AccessibilityTraitSet

    /// The accessibility element is a button.
    public static let isButton = Self(traitSet: .init(trait: .isButton))

    /// The accessibility element is a header that divides content into
    /// sections, like the title of a navigation bar.
    public static let isHeader = Self(traitSet: .init(trait: .isHeader))

    /// The accessibility element is currently selected.
    public static let isSelected = Self(traitSet: .init(trait: .isSelected))

    /// The accessibility element is a link.
    public static let isLink = Self(traitSet: .init(trait: .isLink))

    /// The accessibility element is a search field.
    public static let isSearchField = Self(traitSet: .init(trait: .isSearchField))

    /// The accessibility element is an image.
    public static let isImage = Self(traitSet: .init(trait: .isImage))

    /// The accessibility element plays its own sound when activated.
    public static let playsSound = Self(traitSet: .init(trait: .playsSound))

    /// The accessibility element behaves as a keyboard key.
    public static let isKeyboardKey = Self(traitSet: .init(trait: .isKeyboardKey))

    /// The accessibility element is a static text that cannot be
    /// modified by the user.
    public static let isStaticText = Self(traitSet: .init(trait: .isStaticText))

    /// The accessibility element provides summary information when the
    /// application starts.
    ///
    /// Use this trait to characterize an accessibility element that provides
    /// a summary of current conditions, settings, or state, like the
    /// temperature in the Weather app.
    public static let isSummaryElement = Self(traitSet: .init(trait: .isSummaryElement))

    /// The accessibility element frequently updates its label or value.
    ///
    /// Use this trait when you want an assistive technology to poll for
    /// changes when it needs updated information. For example, you might use
    /// this trait to characterize the readout of a stopwatch.
    public static let updatesFrequently = Self(traitSet: .init(trait: .updatesFrequently))

    /// The accessibility element starts a media session when it is activated.
    ///
    /// Use this trait to silence the audio output of an assistive technology,
    /// such as VoiceOver, during a media session that should not be interrupted.
    /// For example, you might use this trait to silence VoiceOver speech while
    /// the user is recording audio.
    public static let startsMediaSession = Self(traitSet: .init(trait: .startsMediaSession))

    /// The accessibility element allows direct touch interaction for
    /// VoiceOver users.
    public static let allowsDirectInteraction = Self(traitSet: .init(trait: .allowsDirectInteraction))

    /// The accessibility element causes an automatic page turn when VoiceOver
    /// finishes reading the text within it.
    public static let causesPageTurn = Self(traitSet: .init(trait: .causesPageTurn))

    /// The accessibility element is modal.
    ///
    /// Use this trait to restrict which accessibility elements an assistive
    /// technology can navigate. When a modal accessibility element is visible,
    /// sibling accessibility elements that are not modal are ignored.
    public static let isModal = Self(traitSet: .init(trait: .isModal))

    /// The accessibility element is a toggle.
    @available(OpenSwiftUI_v5_0, *)
    public static let isToggle = Self(traitSet: .init(trait: .isToggle))

    /// The accessibility element is a tab bar.
    @available(OpenSwiftUI_v5_0, *)
    public static let isTabBar = Self(traitSet: .init(trait: .isTabBar))

    @_spi(UIFrameworks)
    @available(OpenSwiftUI_v5_0, *)
    public static let isTabButton = Self(traitSet: .init(trait: .isTabButton))

    @_spi(UIFrameworks)
    @available(OpenSwiftUI_v4_0, *)
    public static let isBackButton = Self(traitSet: .init(trait: .isBackButton))

    @_spi(UIFrameworks)
    @available(OpenSwiftUI_v4_0, *)
    public static let excludeFromItemChooser = Self(traitSet: .init(trait: .excludeFromItemChooser))

    @_spi(UIFrameworks)
    @available(OpenSwiftUI_v5_0, *)
    public static let isSwitch = Self(traitSet: .init(trait: .isSwitch))

    @_spi(Private)
    @available(OpenSwiftUI_v6_0, *)
    public static let isMathEquation = Self(traitSet: .init(trait: .isMathEquation))

    private init(traitSet: AccessibilityTraitSet) {
        self.traitSet = traitSet
    }

    public init() {
        traitSet = []
    }

    public func union(_ other: Self) -> Self {
        Self(traitSet: traitSet.union(other.traitSet))
    }

    public mutating func formUnion(_ other: Self) {
        traitSet.formUnion(other.traitSet)
    }

    public func intersection(_ other: Self) -> Self {
        Self(traitSet: traitSet.intersection(other.traitSet))
    }

    public mutating func formIntersection(_ other: Self) {
        traitSet.formIntersection(other.traitSet)
    }

    public func symmetricDifference(_ other: Self) -> Self {
        Self(traitSet: traitSet.symmetricDifference(other.traitSet))
    }

    public mutating func formSymmetricDifference(_ other: Self) {
        traitSet.formSymmetricDifference(other.traitSet)
    }

    public func contains(_ member: Self) -> Bool {
        traitSet.contains(member.traitSet)
    }

    public mutating func insert(_ newMember: Self) -> (inserted: Bool, memberAfterInsert: Self) {
        let result = traitSet.insert(newMember.traitSet)
        return (result.inserted, .init(traitSet: result.memberAfterInsert))
    }

    public mutating func remove(_ member: Self) -> Self? {
        traitSet.remove(member.traitSet).map { .init(traitSet: $0) }
    }

    public mutating func update(with newMember: Self) -> Self? {
        traitSet.update(with: newMember.traitSet).map { .init(traitSet: $0) }
    }
}

package enum AccessibilityTrait: UInt64, CaseIterable {
    case isButton
    case isHeader
    case isSelected
    case isLink
    case isSearchField
    case isImage
    case playsSound
    case isKeyboardKey
    case isStaticText
    case isSummaryElement
    case updatesFrequently
    case startsMediaSession
    case allowsDirectInteraction
    case causesPageTurn
    case isModal
    case isCheckbox
    case isSwitch
    case isRadioButton
    case isRadioGroup
    case isLabel
    case isSingleSiblingWithGesture
    case isInteractive
    case isTabBar
    case isTabButton
    case isBackButton
    case excludeFromItemChooser
    case isControlGroup
    case isPopupButton
    case isToggle
    case isMathEquation

    package var displayDescription: String? {
        switch self {
        case .isButton, .isHeader, .isSelected, .isLink, .isSearchField,
             .isImage, .playsSound, .isKeyboardKey, .isStaticText,
             .isSummaryElement, .updatesFrequently, .startsMediaSession,
             .allowsDirectInteraction, .causesPageTurn, .isModal,
             .isTabBar, .isTabButton, .isBackButton, .excludeFromItemChooser,
             .isToggle:
            return "." + String(describing: self)
        default:
            return nil
        }
    }

    package var uiTrait: AXOpenSwiftUITraits? {
        switch self {
        case .isButton: .button
        case .isHeader: .header
        case .isSelected: .selected
        case .isLink: .link
        case .isSearchField: .searchField
        case .isImage: .image
        case .playsSound: .playsSound
        case .isKeyboardKey: .keyboardKey
        case .isStaticText: .staticText
        case .isSummaryElement: .summaryElement
        case .updatesFrequently: .updatesFrequently
        case .startsMediaSession: .startsMediaSession
        case .allowsDirectInteraction: .allowsDirectInteraction
        case .causesPageTurn: .causesPageTurn
        case .isRadioButton: .radioButton
        case .isTabBar: .tabBar
        case .isTabButton: .tabButton
        case .isBackButton: .backButton
        case .isPopupButton: .popupButton
        case .isToggle: .toggle
        case .isMathEquation: .mathEquation
        case .isModal, .isCheckbox, .isSwitch, .isRadioGroup, .isLabel,
             .isSingleSiblingWithGesture, .isInteractive,
             .excludeFromItemChooser, .isControlGroup:
            nil
        }
    }

    package var isElementUITrait: Bool {
        switch self {
        case .isButton, .isHeader, .isLink, .isSearchField, .isImage,
             .playsSound, .isKeyboardKey, .isStaticText, .isSummaryElement,
             .startsMediaSession, .causesPageTurn, .isRadioButton,
             .isTabButton, .isBackButton, .isPopupButton, .isToggle,
             .isMathEquation:
            true
        default:
            false
        }
    }

    package var isContainerUITrait: Bool {
        switch self {
        case .isSelected, .updatesFrequently, .allowsDirectInteraction, .isTabBar:
            true
        default:
            false
        }
    }

    package var isInteractionUITrait: Bool {
        switch self {
        case .isSelected, .playsSound, .startsMediaSession, .causesPageTurn:
            true
        default:
            false
        }
    }
}

package struct AccessibilityTraitSet: OptionSet, Hashable, Codable {
    package let rawValue: UInt64

    package init(rawValue: UInt64) {
        self.rawValue = rawValue
    }

    package init(trait: AccessibilityTrait) {
        rawValue = 1 << trait.rawValue
    }

    package init(traits: [AccessibilityTrait]) {
        rawValue = traits.reduce(0) { $0 + (1 << $1.rawValue) }
    }
}

package typealias AccessibilityTraitStorage = AccessibilityNullableOptionSet<AccessibilityTraitSet>

extension AccessibilityNullableOptionSet where T == AccessibilityTraitSet {
    package init(adding traits: AccessibilityTraits) {
        self.init(adding: traits.traitSet)
    }

    package init(removing traits: AccessibilityTraits) {
        self.init(removing: traits.traitSet)
    }

    @_disfavoredOverload
    package init(adding trait: AccessibilityTrait) {
        self.init(adding: AccessibilityTraitSet(trait: trait))
    }

    @_disfavoredOverload
    package init(adding traits: [AccessibilityTrait]) {
        self.init(adding: AccessibilityTraitSet(traits: traits))
    }

    @_disfavoredOverload
    package init(removing trait: AccessibilityTrait) {
        self.init(removing: AccessibilityTraitSet(trait: trait))
    }

    @_disfavoredOverload
    package init(removing traits: [AccessibilityTrait]) {
        self.init(removing: AccessibilityTraitSet(traits: traits))
    }

    @_disfavoredOverload
    package func isSet(_ trait: AccessibilityTrait) -> Bool {
        isSet(AccessibilityTraitSet(trait: trait))
    }

    package subscript(_ trait: AccessibilityTrait) -> Bool? {
        get { self[AccessibilityTraitSet(trait: trait)] }
        set { self[AccessibilityTraitSet(trait: trait)] = newValue }
    }

    package subscript(_ trait: AccessibilityTrait, default defaultValue: Bool) -> Bool {
        self[AccessibilityTraitSet(trait: trait), default: defaultValue]
    }
}

extension AccessibilityProperties {
    package var isTabBar: Bool? {
        get { self[trait: .isTabBar] }
        set { self[trait: .isTabBar] = newValue }
    }

    package var isTabButton: Bool? {
        get { self[trait: .isTabButton] }
        set { self[trait: .isTabButton] = newValue }
    }

    package var isBackButton: Bool? {
        get { self[trait: .isBackButton] }
        set { self[trait: .isBackButton] = newValue }
    }

    package var excludeFromItemChooser: Bool? {
        get { self[trait: .excludeFromItemChooser] }
        set { self[trait: .excludeFromItemChooser] = newValue }
    }
}
