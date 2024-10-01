//
//  SemanticFeature.swift
//  OpenSwiftUICore
//
//  Audited for RELEASE_2024
//  Status: Complete

internal import COpenSwiftUICore

package protocol SemanticFeature: Feature {
    static var introduced: Semantics { get }
    static var requirement: SemanticRequirement { get }
}

extension SemanticFeature {
    @inlinable
    package static var requirement: SemanticRequirement { .linkedOnOrAfter }
    
    @inlinable
    package static var prior: Semantics { introduced.prior }
}

package struct _SemanticFeature_v2: SemanticFeature {
    package static let introduced = Semantics.v2
    
    @inlinable
    package init() {}
}

package struct _SemanticFeature_v2_1: SemanticFeature {
    package static let introduced = Semantics.v2_1
    
    @inlinable
    package init() {}
}

package struct _SemanticFeature_v2_3: SemanticFeature {
    package static let introduced = Semantics.v2_3
    
    @inlinable
    package init() {}
}

package struct _SemanticFeature_v3: SemanticFeature {
    package static let introduced = Semantics.v3
    
    @inlinable
    package init() {}
}

package struct _SemanticFeature_v4: SemanticFeature {
    package static let introduced = Semantics.v4
    
    @inlinable
    package init() {}
}

package struct _SemanticFeature_v4_4: SemanticFeature {
    package static let introduced = Semantics.v4_4
    
    @inlinable
    package init() {}
}

package struct _SemanticFeature_v5: SemanticFeature {
    package static let introduced = Semantics.v5
    
    @inlinable
    package init() {}
}

package struct _SemanticFeature_v5_2: SemanticFeature {
    package static let introduced = Semantics.v5_2
    
    @inlinable
    package init() {}
}

package struct _SemanticFeature_v6: SemanticFeature {
    package static let introduced = Semantics.v6
    
    @inlinable
    package init() {}
}

extension Semantics {
    package typealias ColumnarNavigationViewsUseUnaryWrappers = _SemanticFeature_v2
    package typealias ImagesLayoutAsText = _SemanticFeature_v2
    package typealias NoSpacingProjectedPadding = _SemanticFeature_v2
    package typealias ScaleNamedFonts = _SemanticFeature_v2
    package typealias UbiquitousTransitions = _SemanticFeature_v2
    package typealias UppercaseSectionHeaders = _SemanticFeature_v2
}

extension Semantics {
    package typealias IOSCompactDatePickerFeature = _SemanticFeature_v2
    package typealias IOSExplicitListInsettingFeature = _SemanticFeature_v2
    package typealias IOSIncreasedPhoneTableViewMargins = _SemanticFeature_v2
    package typealias IOSKeyboardAvoidance = _SemanticFeature_v2
    package typealias IOSMultiColumnFeature = _SemanticFeature_v2
    package typealias IOSOnDropUsesLocalCoordinateSpace = _SemanticFeature_v2
    package typealias IOSTableViewDefaultAnimationDisabled = _SemanticFeature_v2
}

extension Semantics {
    package typealias MacListMultilineText = _SemanticFeature_v2
    package typealias MacTabViewFittedSize = _SemanticFeature_v2
}

extension Semantics {
    package typealias TVNavigationBarHidden = _SemanticFeature_v2
}

extension Semantics {
    package typealias WatchBaselineAdjustedHeaders = _SemanticFeature_v2
    package typealias WatchBorderedButtonTintFeature = _SemanticFeature_v2
    package typealias WatchEllipticalListStyleFeature = _SemanticFeature_v2
    package typealias WatchGlobalAccentColor = _SemanticFeature_v2
    package typealias WatchNavigationPicker = _SemanticFeature_v2
    package typealias WheelPickerShouldHideLabels = _SemanticFeature_v2
    package typealias WatchSpecificSpacing = _SemanticFeature_v2
}

extension Semantics {
    package typealias SymbolImageLayoutUsingContentBounds = _SemanticFeature_v2_1
}

extension Semantics {
    package typealias PreviewPreferredColorScheme = _SemanticFeature_v2_3
    package typealias ListSectionInlinePickerStyle = _SemanticFeature_v2_3
    package typealias PageTabViewStyleStopsSizingChildren = _SemanticFeature_v2_3
    package typealias ViewStylesMustBeValueTypes = _SemanticFeature_v2_3
}

extension Semantics {
    package typealias DepthWiseSecondaryLayers = _SemanticFeature_v3
    package typealias EnvironmentReaderViewIsMulti = _SemanticFeature_v3
    package typealias AccessibilityCodableVersion3 = _SemanticFeature_v3
    package typealias WatchSupportsLargeTitles = _SemanticFeature_v3
    package typealias MergeCoincidentAnimations = _SemanticFeature_v3
    package typealias UpdatedSidebarHeaderStyle = _SemanticFeature_v3
    package typealias EnhancedBackgroundTransparency = _SemanticFeature_v3
    package typealias TraitCollectionAnimations = _SemanticFeature_v3
    package typealias FocusableCustomButtonStyleFeature = _SemanticFeature_v3
    package typealias MarkdownSupportForLocalizedStringKey = _SemanticFeature_v3
    package typealias DefaultListStyleInsetGrouped = _SemanticFeature_v3
    package typealias StopProjectingAffectedSpacing = _SemanticFeature_v3
    package typealias AvoidToolbarItemBridging = _SemanticFeature_v3
    package typealias IOSPickerIsMenuByDefault = _SemanticFeature_v3
    package typealias FormSectionInlinePickerStyle = _SemanticFeature_v3
    package typealias PrioritizeControlLabel = _SemanticFeature_v3
}

extension Semantics {
    package typealias IOSListsUseCollectionView = _SemanticFeature_v4
    package typealias InferredToolbar = _SemanticFeature_v4
    package typealias ChildToolbarItemsAreAppended = _SemanticFeature_v4
    package typealias AutomaticHierarchicalTextLevels = _SemanticFeature_v4
    package typealias NavigationBarDefaults = _SemanticFeature_v4
    package typealias TextModifiersOverrideParentValues = _SemanticFeature_v4
    package typealias FontModifiersNilResetValues = _SemanticFeature_v4
    package typealias EvaluateDefaultFocusState = _SemanticFeature_v4
    package typealias DisableFocusInSubtree = _SemanticFeature_v4
    package typealias FixedSidebarInSheetContext = _SemanticFeature_v4
    package typealias DesktopClassIpadFeatures = _SemanticFeature_v4
    package typealias NoImplicitHStackInDisclosureGroupHeader = _SemanticFeature_v4
    package typealias ImplicitlyFlexibleWindows = _SemanticFeature_v4
    package typealias IOSListsUseUpdatedRowLayout = _SemanticFeature_v4
    package typealias MenuIsButtonByDefault = _SemanticFeature_v4
    package typealias AvoidToolbarItemToggleBridging = _SemanticFeature_v4
    package typealias AllowDisabledButtonsInAlert = _SemanticFeature_v4
    package typealias RefreshableInScrollView = _SemanticFeature_v4
    package typealias IOSPickerIsMenuByDefaultInList = _SemanticFeature_v4
    package typealias UIKitEnvironmentPrefersTint = _SemanticFeature_v4
    package typealias OrderButtonsByRoleInAlert = _SemanticFeature_v4
    package typealias SettingsSceneAddsCoreCommands = _SemanticFeature_v4
    package typealias TVSwiftUIPlainButtonStyle = _SemanticFeature_v4
    package typealias TVSwiftUIBorderedButtonStyle = _SemanticFeature_v4
}

extension Semantics {
    package typealias ButtonHierarchicalTextLevels = _SemanticFeature_v4_4
    package typealias ListResetRefresh = _SemanticFeature_v4_4
}

extension Semantics {
    package typealias ResetScrollEnvironment = _SemanticFeature_v5
    package typealias DismissActionInRootHost = _SemanticFeature_v5
    package typealias TVSwiftUICardButtonStyle = _SemanticFeature_v5
    package typealias ClientButtonStyleMenuComposition = _SemanticFeature_v5
    package typealias HiddenSidebarHeadersForEmptyView = _SemanticFeature_v5
    package typealias WatchViewsUseMaterials = _SemanticFeature_v5
    package typealias RequireAccessingSecurityScopedResource = _SemanticFeature_v5
    package typealias UseSettingsLinkInCommands = _SemanticFeature_v5
    package typealias AllowLabelToolbarItemBridging = _SemanticFeature_v5
    package typealias DefaultFocusableBehaviorIncludesKeyboard = _SemanticFeature_v5
    package typealias BridgeKitAnimations = _SemanticFeature_v5
    package typealias PortaledLiftPreviews = _SemanticFeature_v5
    package typealias NoImplicitHStackInPrimitiveOutline = _SemanticFeature_v5
    package typealias MirrorUIKitVibrancy = _SemanticFeature_v5
    package typealias BottomBarManagedAppearance = _SemanticFeature_v5
    package typealias TextSpacingUIKit0059v2 = _SemanticFeature_v5
    package typealias FlexFrameIdealSizing = _SemanticFeature_v5
    package typealias NSToolbarBridgingDoesNotRequireFullWindow = _SemanticFeature_v5
    package typealias ProgrammaticSectionExpansion = _SemanticFeature_v5
    package typealias ArchivedLinkIsButton = _SemanticFeature_v5
    package typealias TextRenderingMetrics = _SemanticFeature_v5
    package typealias ListButtonsAreUnary = _SemanticFeature_v5
    package typealias SearchRepresentablesForFocusableSubviews = _SemanticFeature_v5
    package typealias SectionsHaveAuxiliaryHoverEffect = _SemanticFeature_v5
    package typealias ResponderBasedTooltips = _SemanticFeature_v5
}

extension Semantics {
    package typealias TextContentTransitionDisabled = _SemanticFeature_v5_2
}

extension Semantics {
    package typealias WindowBasedScrollGeometry = _SemanticFeature_v6
    package typealias NonScrollableSafeAreaEdges = _SemanticFeature_v6
    package typealias PrincipalItemsPerSplitViewPane = _SemanticFeature_v6
    package typealias UnifiedHitTesting = _SemanticFeature_v6
    package typealias PresentationSizing = _SemanticFeature_v6
    package typealias TVBlurOverFullScreen = _SemanticFeature_v6
    package typealias IgnoreNavDestInLazyContainer = _SemanticFeature_v6
    package typealias TVSidebarNavSplit = _SemanticFeature_v6
    package typealias PopoverDismissesOutsideSafeArea = _SemanticFeature_v6
    package typealias DocumentViewControllerRoot = _SemanticFeature_v6
    package typealias TabViewWindowSidebarStyling = _SemanticFeature_v6
    package typealias ShapeStyleDownwardsModifiers = _SemanticFeature_v6
    package typealias ProminentHeadersInSidebarDisabled = _SemanticFeature_v6
    package typealias LimitWriteBacksToSheetBindings = _SemanticFeature_v6
    package typealias EmptyPickerCurrentValueLabel = _SemanticFeature_v6
    package typealias ListLabelCenterAlignsIcon = _SemanticFeature_v6
    package struct DismissPopsInNavigationSplitViewRoots : SemanticFeature {
        package static let introduced = Semantics.v6
        package static let requirement = SemanticRequirement.deployedOnOrAfter
        
        @inlinable
        package init() {}
    }
    package typealias SearchCompletionIncludesMatches = _SemanticFeature_v6
    package typealias MacOSListDoesNotEagerlyLoadsPIL = _SemanticFeature_v6
}

package struct DisabledFeature: SemanticFeature {
    package static let introduced = Semantics.maximal
    
    @inlinable
    package static var isEnabled: Bool { false }
  
    @inlinable
    package init() {}
}

package struct EnabledFeature: SemanticFeature {
    package static let introduced = Semantics.firstRelease
    
    @inlinable
    package init() {}
}
