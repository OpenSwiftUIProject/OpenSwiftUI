//
//  AXOpenSwiftUITraits.c
//  OpenSwiftUI_SPI
//
//  Audited for 6.5.4
//  Status: Complete

#include "AXOpenSwiftUITraits.h"

const AXOpenSwiftUITraits AXOpenSwiftUITraitsNone = 0;
const AXOpenSwiftUITraits AXOpenSwiftUITraitsButton = UINT64_C(1) << 0;
const AXOpenSwiftUITraits AXOpenSwiftUITraitsLink = UINT64_C(1) << 1;
const AXOpenSwiftUITraits AXOpenSwiftUITraitsImage = UINT64_C(1) << 2;
const AXOpenSwiftUITraits AXOpenSwiftUITraitsSelected = UINT64_C(1) << 3;
const AXOpenSwiftUITraits AXOpenSwiftUITraitsPlaysSound = UINT64_C(1) << 4;
const AXOpenSwiftUITraits AXOpenSwiftUITraitsKeyboardKey = UINT64_C(1) << 5;
const AXOpenSwiftUITraits AXOpenSwiftUITraitsStaticText = UINT64_C(1) << 6;
const AXOpenSwiftUITraits AXOpenSwiftUITraitsSummaryElement = UINT64_C(1) << 7;
const AXOpenSwiftUITraits AXOpenSwiftUITraitsNotEnabled = UINT64_C(1) << 8;
const AXOpenSwiftUITraits AXOpenSwiftUITraitsUpdatesFrequently = UINT64_C(1) << 9;
const AXOpenSwiftUITraits AXOpenSwiftUITraitsSearchField = UINT64_C(1) << 10;
const AXOpenSwiftUITraits AXOpenSwiftUITraitsStartsMediaSession = UINT64_C(1) << 11;
const AXOpenSwiftUITraits AXOpenSwiftUITraitsAdjustable = UINT64_C(1) << 12;
const AXOpenSwiftUITraits AXOpenSwiftUITraitsAllowsDirectInteraction = UINT64_C(1) << 13;
const AXOpenSwiftUITraits AXOpenSwiftUITraitsCausesPageTurn = UINT64_C(1) << 14;
const AXOpenSwiftUITraits AXOpenSwiftUITraitsTabBar = UINT64_C(1) << 15;
const AXOpenSwiftUITraits AXOpenSwiftUITraitsHeader = UINT64_C(1) << 16;
const AXOpenSwiftUITraits AXOpenSwiftUITraitsWebContent = UINT64_C(1) << 17;
const AXOpenSwiftUITraits AXOpenSwiftUITraitsTextEntry = UINT64_C(1) << 18;
const AXOpenSwiftUITraits AXOpenSwiftUITraitsPickerElement = UINT64_C(1) << 19;
const AXOpenSwiftUITraits AXOpenSwiftUITraitsRadioButton = UINT64_C(1) << 20;
const AXOpenSwiftUITraits AXOpenSwiftUITraitsIsEditing = UINT64_C(1) << 21;
const AXOpenSwiftUITraits AXOpenSwiftUITraitsLaunchIcon = UINT64_C(1) << 22;
const AXOpenSwiftUITraits AXOpenSwiftUITraitsStatusBarElement = UINT64_C(1) << 23;
const AXOpenSwiftUITraits AXOpenSwiftUITraitsSecureTextField = UINT64_C(1) << 24;
const AXOpenSwiftUITraits AXOpenSwiftUITraitsInactive = UINT64_C(1) << 25;
const AXOpenSwiftUITraits AXOpenSwiftUITraitsFooter = UINT64_C(1) << 26;
const AXOpenSwiftUITraits AXOpenSwiftUITraitsBackButton = UINT64_C(1) << 27;
const AXOpenSwiftUITraits AXOpenSwiftUITraitsTabButton = UINT64_C(1) << 28;
const AXOpenSwiftUITraits AXOpenSwiftUITraitsAutoCorrectCandidate = UINT64_C(1) << 29;
const AXOpenSwiftUITraits AXOpenSwiftUITraitsDeleteKey = UINT64_C(1) << 30;
const AXOpenSwiftUITraits AXOpenSwiftUITraitsSelectionDismissesItem = UINT64_C(1) << 31;
const AXOpenSwiftUITraits AXOpenSwiftUITraitsVisited = UINT64_C(1) << 32;
const AXOpenSwiftUITraits AXOpenSwiftUITraitsScrollable = UINT64_C(1) << 33;
const AXOpenSwiftUITraits AXOpenSwiftUITraitsSpacer = UINT64_C(1) << 34;
const AXOpenSwiftUITraits AXOpenSwiftUITraitsTableIndex = UINT64_C(1) << 35;
const AXOpenSwiftUITraits AXOpenSwiftUITraitsMap = UINT64_C(1) << 36;
const AXOpenSwiftUITraits AXOpenSwiftUITraitsTextOperationsAvailable = UINT64_C(1) << 37;
const AXOpenSwiftUITraits AXOpenSwiftUITraitsDraggable = UINT64_C(1) << 38;
const AXOpenSwiftUITraits AXOpenSwiftUITraitsGesturePracticeRegion = UINT64_C(1) << 39;
const AXOpenSwiftUITraits AXOpenSwiftUITraitsPopupButton = UINT64_C(1) << 40;
const AXOpenSwiftUITraits AXOpenSwiftUITraitsAllowsNativeSliding = UINT64_C(1) << 41;
const AXOpenSwiftUITraits AXOpenSwiftUITraitsMathEquation = UINT64_C(1) << 42;
const AXOpenSwiftUITraits AXOpenSwiftUITraitsContainedByTable = UINT64_C(1) << 43;
const AXOpenSwiftUITraits AXOpenSwiftUITraitsContainedByList = UINT64_C(1) << 44;
const AXOpenSwiftUITraits AXOpenSwiftUITraitsTouchContainer = UINT64_C(1) << 45;
const AXOpenSwiftUITraits AXOpenSwiftUITraitsSupportsZoom = UINT64_C(1) << 46;
const AXOpenSwiftUITraits AXOpenSwiftUITraitsTextArea = UINT64_C(1) << 47;
const AXOpenSwiftUITraits AXOpenSwiftUITraitsBookContent = UINT64_C(1) << 48;
const AXOpenSwiftUITraits AXOpenSwiftUITraitsContainedByLandmark = UINT64_C(1) << 49;
const AXOpenSwiftUITraits AXOpenSwiftUITraitsFolderIcon = UINT64_C(1) << 50;
const AXOpenSwiftUITraits AXOpenSwiftUITraitsReadOnly = UINT64_C(1) << 51;
const AXOpenSwiftUITraits AXOpenSwiftUITraitsMenuItem = UINT64_C(1) << 52;
const AXOpenSwiftUITraits AXOpenSwiftUITraitsToggle = UINT64_C(1) << 53;
const AXOpenSwiftUITraits AXOpenSwiftUITraitsIgnoreItemChooser = UINT64_C(1) << 54;
const AXOpenSwiftUITraits AXOpenSwiftUITraitsSupportsTrackingDetail = UINT64_C(1) << 55;
const AXOpenSwiftUITraits AXOpenSwiftUITraitsAlert = UINT64_C(1) << 56;
const AXOpenSwiftUITraits AXOpenSwiftUITraitsContainedByFieldset = UINT64_C(1) << 57;
const AXOpenSwiftUITraits AXOpenSwiftUITraitsAllowsLayoutChangeInStatusBar = UINT64_C(1) << 58;
const AXOpenSwiftUITraits AXOpenSwiftUITraitsWebInteractiveVideo = UINT64_C(1) << 59;
const AXOpenSwiftUITraits AXOpenSwiftUITraitsProminentIcon = UINT64_C(1) << 60;
const AXOpenSwiftUITraits AXOpenSwiftUITraitsGestureHandlerRegion = UINT64_C(1) << 61;
const AXOpenSwiftUITraits AXOpenSwiftUITraitsRemoveTraitsSentinel = UINT64_C(1) << 63;
