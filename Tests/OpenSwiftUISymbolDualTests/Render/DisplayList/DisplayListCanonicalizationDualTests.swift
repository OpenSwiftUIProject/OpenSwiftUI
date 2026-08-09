//
//  DisplayListCanonicalizationDualTests.swift
//  OpenSwiftUISymbolDualTests

#if canImport(SwiftUI, _underlyingVersion: 6.5.4)
import Foundation
@_spi(Private) @testable import OpenSwiftUICore
import Testing

extension DisplayList.Item {
    @_silgen_name("OpenSwiftUITestStub_DisplayListItemCanonicalize")
    mutating func swiftUI_canonicalize(options: DisplayList.Options)
}

@MainActor
@Suite(.serialized)
struct DisplayListCanonicalizationDualTests {
    @Test(arguments: CanonicalizationFixture.allCases)
    fileprivate func canonicalize(_ fixture: CanonicalizationFixture) {
        var openSwiftUIItem = fixture.makeItem()
        openSwiftUIItem.canonicalize(options: fixture.options)
        #expect(CanonicalizedItem(openSwiftUIItem) == fixture.expected)

        guard isSwiftUIVersionAtLeast65AndBefore70 else {
            return
        }
        var swiftUIItem = fixture.makeItem()
        swiftUIItem.swiftUI_canonicalize(options: fixture.options)
        #expect(CanonicalizedItem(swiftUIItem) == fixture.expected)
    }
}

private enum CanonicalizationFixture: String, CaseIterable, Equatable, Sendable, CustomTestStringConvertible {
    case disabled
    case empty
    case states
    case clearColor
    case opaqueColor
    case emptyFrame
    case requiredEmptyFrame
    case emptyShape
    case emptyShadowPath
    case transparentShadow
    case emptyText
    case emptyFlattenedContent
    case unhandledContent
    case emptyEffect
    case requiredEmptyEffect
    case identity
    case identityMultipleChildren
    case identityChildWithoutIdentity
    case unitOpacity
    case zeroOpacity
    case partialOpacity
    case requiredZeroOpacity
    case clipColorPaint
    case clipShapePaint
    case inverseClip
    case emptyClip
    case requiredEmptyClip
    case maskedBackdrop
    case opaqueColorMask
    case opaqueShapeMask
    case inverseMask
    case nonOpaqueMask
    case emptyMask
    case requiredEmptyMask
    case identityAffineTransform
    case translatedAffineTransform
    case identityFilter
    case unsupportedFilter
    case colorMatrixFusion
    case unhandledEffect

    var testDescription: String { rawValue }

    var options: DisplayList.Options {
        self == .disabled ? .disableCanonicalization : []
    }

    @MainActor
    func makeItem() -> DisplayList.Item {
        switch self {
        case .disabled:
            return effectItem(.opacity(1), child: child, frame: outerFrame)
        case .empty:
            return item(.empty, frame: outerFrame)
        case .states:
            return item(.states([(StrongHash(), child)]), frame: outerFrame)
        case .clearColor:
            return contentItem(.color(.clear), frame: outerFrame)
        case .opaqueColor:
            return contentItem(.color(.white), frame: outerFrame)
        case .emptyFrame:
            return contentItem(.color(.white))
        case .requiredEmptyFrame:
            return contentItem(.platformView(EmptyViewFactory()))
        case .emptyShape:
            return contentItem(
                .shape(
                    Path(),
                    OpenSwiftUICore._AnyResolvedPaint(Color.Resolved.white),
                    FillStyle()
                ),
                frame: outerFrame
            )
        case .emptyShadowPath:
            return contentItem(.shadow(Path(), visibleResolvedShadow), frame: outerFrame)
        case .transparentShadow:
            return contentItem(.shadow(testPath, transparentResolvedShadow), frame: outerFrame)
        case .emptyText:
            return contentItem(
                .text(StyledTextContentView(text: resolvedStyledText(nil)), .zero),
                frame: outerFrame
            )
        case .emptyFlattenedContent:
            return contentItem(.flattened(DisplayList(), .zero, .init()), frame: outerFrame)
        case .unhandledContent:
            return contentItem(.backdrop(.init(color: .white)), frame: outerFrame)
        case .emptyEffect:
            return effectItem(.opacity(0.5), frame: outerFrame)
        case .requiredEmptyEffect:
            return effectItem(.properties(.privacySensitive), frame: outerFrame)
        case .identity:
            return effectItem(.identity, child: child, frame: outerFrame)
        case .identityMultipleChildren:
            return effectItem(.identity, child: multipleChildren, frame: outerFrame)
        case .identityChildWithoutIdentity:
            return effectItem(.identity, child: childWithoutIdentity, frame: outerFrame)
        case .unitOpacity:
            return effectItem(.opacity(1), child: child, frame: outerFrame)
        case .zeroOpacity:
            return effectItem(.opacity(0), child: child, frame: outerFrame)
        case .partialOpacity:
            return effectItem(.opacity(0.5), child: child, frame: outerFrame)
        case .requiredZeroOpacity:
            return effectItem(.opacity(0), child: requiredChild, frame: outerFrame)
        case .clipColorPaint:
            return effectItem(.clip(testPath, FillStyle()), child: colorPaintChild, frame: outerFrame)
        case .clipShapePaint:
            return effectItem(.clip(testPath, FillStyle()), child: shapePaintChild, frame: outerFrame)
        case .inverseClip:
            return effectItem(
                .clip(testPath, FillStyle(), .inverse),
                child: colorPaintChild,
                frame: outerFrame
            )
        case .emptyClip:
            return effectItem(.clip(Path(), FillStyle()), child: child, frame: outerFrame)
        case .requiredEmptyClip:
            return effectItem(.clip(Path(), FillStyle()), child: requiredChild, frame: outerFrame)
        case .maskedBackdrop:
            let backdrop = contentItem(.backdrop(.init(color: .clear)), frame: sizeFrame)
            let filteredBackdrop = effectItem(
                .filter(.brightness(0.25)),
                child: DisplayList(backdrop),
                frame: sizeFrame
            )
            let mask = DisplayList(contentItem(.color(.white), frame: sizeFrame))
            return effectItem(
                .mask(mask),
                child: DisplayList(filteredBackdrop),
                frame: outerFrame
            )
        case .opaqueColorMask:
            let mask = DisplayList(contentItem(.color(.white), frame: sizeFrame))
            return effectItem(.mask(mask), child: colorPaintChild, frame: outerFrame)
        case .opaqueShapeMask:
            let mask = DisplayList(contentItem(
                .shape(
                    fullSizePath,
                    OpenSwiftUICore._AnyResolvedPaint(Color.Resolved.white),
                    FillStyle()
                ),
                frame: CGRect(origin: CGPoint(x: 2, y: 3), size: outerFrame.size)
            ))
            return effectItem(.mask(mask), child: colorPaintChild, frame: outerFrame)
        case .inverseMask:
            let mask = DisplayList(contentItem(.color(.white), frame: sizeFrame))
            return effectItem(.mask(mask, .inverse), child: colorPaintChild, frame: outerFrame)
        case .nonOpaqueMask:
            let mask = DisplayList(contentItem(.color(translucentColor), frame: sizeFrame))
            return effectItem(.mask(mask), child: colorPaintChild, frame: outerFrame)
        case .emptyMask:
            return effectItem(.mask(DisplayList()), child: child, frame: outerFrame)
        case .requiredEmptyMask:
            return effectItem(.mask(DisplayList()), child: requiredChild, frame: outerFrame)
        case .identityAffineTransform:
            return effectItem(.transform(.affine(.identity)), child: child, frame: outerFrame)
        case .translatedAffineTransform:
            return effectItem(
                .transform(.affine(.init(translationX: 1, y: 2))),
                child: child,
                frame: outerFrame
            )
        case .identityFilter:
            return effectItem(.filter(.brightness(0)), child: child, frame: outerFrame)
        case .unsupportedFilter:
            return effectItem(.filter(.blur(.init(radius: 1))), child: child, frame: outerFrame)
        case .colorMatrixFusion:
            let innerList = DisplayList(contentItem(.color(.white), frame: outerFrame))
            let innerFilter = effectItem(
                .filter(.contrast(2)),
                child: innerList,
                frame: CGRect(origin: .zero, size: outerFrame.size)
            )
            return effectItem(
                .filter(.brightness(0.25)),
                child: DisplayList(innerFilter),
                frame: outerFrame
            )
        case .unhandledEffect:
            return effectItem(.blendMode(.normal), child: child, frame: outerFrame)
        }
    }

    var expected: CanonicalizedItem {
        switch self {
        case .disabled:
            return CanonicalizedItem(
                frame: outerFrame,
                version: 3,
                identity: 7,
                value: .opacity(1, childCount: 1)
            )
        case .identity, .unitOpacity, .identityAffineTransform, .identityFilter:
            return CanonicalizedItem(
                frame: CGRect(x: 11, y: 22, width: 3, height: 4),
                version: 5,
                identity: 8,
                value: .content(.color)
            )
        case .identityChildWithoutIdentity:
            return CanonicalizedItem(
                frame: CGRect(x: 11, y: 22, width: 3, height: 4),
                version: 5,
                identity: 7,
                value: .content(.color)
            )
        case .requiredEmptyEffect:
            return CanonicalizedItem(
                frame: outerFrame,
                version: 3,
                identity: 7,
                value: .properties(.privacySensitive, childCount: 0)
            )
        case .maskedBackdrop:
            return CanonicalizedItem(
                frame: outerFrame,
                version: 3,
                identity: 7,
                value: .vibrantColorMatrix(
                    _ColorMatrix(
                        row1: (1, 0, 0, 0, 0.25),
                        row2: (0, 1, 0, 0, 0.25),
                        row3: (0, 0, 1, 0, 0.25),
                        row4: (0, 0, 0, 1, 0)
                    ),
                    childCount: 1
                )
            )
        case .colorMatrixFusion:
            return CanonicalizedItem(
                frame: outerFrame,
                version: 3,
                identity: 7,
                value: .colorMatrix(
                    _ColorMatrix(
                        row1: (2, 0, 0, 0, -0.25),
                        row2: (0, 2, 0, 0, -0.25),
                        row3: (0, 0, 2, 0, -0.25),
                        row4: (0, 0, 0, 1, 0)
                    ),
                    premultiplied: false,
                    childCount: 1
                )
            )
        case .empty, .clearColor, .emptyShape, .emptyShadowPath, .transparentShadow,
             .emptyText, .emptyFlattenedContent, .emptyEffect, .zeroOpacity, .emptyClip,
             .emptyMask:
            return CanonicalizedItem(
                frame: outerFrame,
                version: 3,
                identity: 7,
                value: .empty
            )
        case .emptyFrame:
            return CanonicalizedItem(frame: .zero, version: 3, identity: 7, value: .empty)
        case .states:
            return CanonicalizedItem(frame: outerFrame, version: 3, identity: 7, value: .states(1))
        case .opaqueColor:
            return CanonicalizedItem(frame: outerFrame, version: 3, identity: 7, value: .content(.color))
        case .requiredEmptyFrame:
            return CanonicalizedItem(frame: .zero, version: 3, identity: 7, value: .content(.platformView))
        case .unhandledContent:
            return CanonicalizedItem(frame: outerFrame, version: 3, identity: 7, value: .content(.backdrop))
        case .identityMultipleChildren:
            return CanonicalizedItem(frame: outerFrame, version: 3, identity: 7, value: .identity(childCount: 2))
        case .partialOpacity:
            return CanonicalizedItem(frame: outerFrame, version: 3, identity: 7, value: .opacity(0.5, childCount: 1))
        case .requiredZeroOpacity:
            return CanonicalizedItem(frame: outerFrame, version: 3, identity: 7, value: .opacity(0, childCount: 1))
        case .clipColorPaint, .clipShapePaint, .opaqueColorMask, .opaqueShapeMask:
            return CanonicalizedItem(frame: outerFrame, version: 3, identity: 7, value: .content(.shape(pathIsEmpty: false)))
        case .inverseClip, .inverseMask:
            return CanonicalizedItem(
                frame: outerFrame,
                version: 3,
                identity: 7,
                value: .clip(pathIsEmpty: false, options: 1, childCount: 1)
            )
        case .requiredEmptyClip:
            return CanonicalizedItem(
                frame: outerFrame,
                version: 3,
                identity: 7,
                value: .clip(pathIsEmpty: true, options: 0, childCount: 1)
            )
        case .nonOpaqueMask:
            return CanonicalizedItem(
                frame: outerFrame,
                version: 3,
                identity: 7,
                value: .mask(maskCount: 1, options: 0, childCount: 1)
            )
        case .requiredEmptyMask:
            return CanonicalizedItem(
                frame: outerFrame,
                version: 3,
                identity: 7,
                value: .mask(maskCount: 0, options: 0, childCount: 1)
            )
        case .translatedAffineTransform:
            return CanonicalizedItem(frame: outerFrame, version: 3, identity: 7, value: .transform(childCount: 1))
        case .unsupportedFilter:
            return CanonicalizedItem(frame: outerFrame, version: 3, identity: 7, value: .filter(childCount: 1))
        case .unhandledEffect:
            return CanonicalizedItem(frame: outerFrame, version: 3, identity: 7, value: .blendMode(childCount: 1))
        }
    }
}

private struct CanonicalizedItem: Equatable {
    enum ContentValue: Equatable {
        case backdrop
        case color
        case shape(pathIsEmpty: Bool)
        case shadow
        case platformView
        case text
        case flattened(childCount: Int)
        case other
    }

    enum Value: Equatable {
        case empty
        case content(ContentValue)
        case states(Int)
        case identity(childCount: Int)
        case opacity(Float, childCount: Int)
        case clip(pathIsEmpty: Bool, options: UInt32, childCount: Int)
        case mask(maskCount: Int, options: UInt32, childCount: Int)
        case transform(childCount: Int)
        case properties(DisplayList.Properties, childCount: Int)
        case colorMatrix(_ColorMatrix, premultiplied: Bool, childCount: Int)
        case vibrantColorMatrix(_ColorMatrix, childCount: Int)
        case filter(childCount: Int)
        case blendMode(childCount: Int)
        case other
    }

    var frame: CGRect
    var version: Int
    var identity: UInt32
    var value: Value

    init(frame: CGRect, version: Int, identity: UInt32, value: Value) {
        self.frame = frame
        self.version = version
        self.identity = identity
        self.value = value
    }

    init(_ item: DisplayList.Item) {
        frame = item.frame
        version = item.version.value
        identity = item.identity.value
        value = switch item.value {
        case .empty:
            .empty
        case let .content(content):
            switch content.value {
            case .backdrop:
                .content(.backdrop)
            case .color:
                .content(.color)
            case let .shape(path, _, _):
                .content(.shape(pathIsEmpty: path.isEmpty))
            case .shadow:
                .content(.shadow)
            case .platformView:
                .content(.platformView)
            case .text:
                .content(.text)
            case let .flattened(list, _, _):
                .content(.flattened(childCount: list.items.count))
            default:
                .content(.other)
            }
        case let .effect(effect, list):
            switch effect {
            case .identity:
                .identity(childCount: list.items.count)
            case let .opacity(opacity):
                .opacity(opacity, childCount: list.items.count)
            case let .clip(path, _, options):
                .clip(
                    pathIsEmpty: path.isEmpty,
                    options: options.rawValue,
                    childCount: list.items.count
                )
            case let .mask(mask, options):
                .mask(
                    maskCount: mask.items.count,
                    options: options.rawValue,
                    childCount: list.items.count
                )
            case .transform:
                .transform(childCount: list.items.count)
            case let .properties(properties):
                .properties(properties, childCount: list.items.count)
            case let .filter(.colorMatrix(matrix, premultiplied)):
                .colorMatrix(
                    matrix,
                    premultiplied: premultiplied,
                    childCount: list.items.count
                )
            case let .filter(.vibrantColorMatrix(matrix)):
                .vibrantColorMatrix(matrix, childCount: list.items.count)
            case .filter:
                .filter(childCount: list.items.count)
            case .blendMode:
                .blendMode(childCount: list.items.count)
            default:
                .other
            }
        case let .states(states):
            .states(states.count)
        }
    }
}

private let outerFrame = CGRect(x: 10, y: 20, width: 100, height: 200)
private let sizeFrame = CGRect(origin: .zero, size: outerFrame.size)
private let testPath = Path(CGRect(x: 1, y: 2, width: 3, height: 4))
private let fullSizePath = Path(sizeFrame)
private let translucentColor = Color.Resolved(
    linearRed: 1,
    linearGreen: 1,
    linearBlue: 1,
    opacity: 0.5
)
private let visibleResolvedShadow = ResolvedShadowStyle(
    color: .black,
    radius: 2,
    offset: CGSize(width: 3, height: 4)
)
private let transparentResolvedShadow = ResolvedShadowStyle(
    color: .clear,
    radius: 2,
    offset: CGSize(width: 3, height: 4)
)

@MainActor
private var child: DisplayList {
    DisplayList(contentItem(
        .color(.white),
        frame: CGRect(x: 1, y: 2, width: 3, height: 4),
        identity: 8,
        version: 5
    ))
}

@MainActor
private var childWithoutIdentity: DisplayList {
    DisplayList(contentItem(
        .color(.white),
        frame: CGRect(x: 1, y: 2, width: 3, height: 4),
        identity: 0,
        version: 5
    ))
}

@MainActor
private var multipleChildren: DisplayList {
    DisplayList([
        contentItem(
            .color(.white),
            frame: CGRect(x: 1, y: 2, width: 3, height: 4),
            identity: 8,
            version: 5
        ),
        contentItem(
            .color(.black),
            frame: CGRect(x: 5, y: 6, width: 7, height: 8),
            identity: 9,
            version: 6
        ),
    ])
}

@MainActor
private var requiredChild: DisplayList {
    DisplayList(effectItem(.properties(.privacySensitive), frame: sizeFrame))
}

@MainActor
private var colorPaintChild: DisplayList {
    DisplayList(contentItem(.color(.white), frame: sizeFrame))
}

@MainActor
private var shapePaintChild: DisplayList {
    DisplayList(contentItem(
        .shape(
            fullSizePath,
            OpenSwiftUICore._AnyResolvedPaint(Color.Resolved.white),
            FillStyle()
        ),
        frame: sizeFrame
    ))
}

@MainActor
private func item(
    _ value: DisplayList.Item.Value,
    frame: CGRect = .zero,
    identity: UInt32 = 7,
    version: Int = 3
) -> DisplayList.Item {
    DisplayList.Item(
        value,
        frame: frame,
        identity: .init(decodedValue: identity),
        version: .init(decodedValue: version)
    )
}

@MainActor
private func contentItem(
    _ value: DisplayList.Content.Value,
    frame: CGRect = .zero,
    identity: UInt32 = 7,
    version: Int = 3
) -> DisplayList.Item {
    item(
        .content(.init(value, seed: .init(decodedValue: 1))),
        frame: frame,
        identity: identity,
        version: version
    )
}

@MainActor
private func effectItem(
    _ effect: DisplayList.Effect,
    child: DisplayList = DisplayList(),
    frame: CGRect = .zero
) -> DisplayList.Item {
    item(
        .effect(effect, child),
        frame: frame
    )
}

@MainActor
private func resolvedStyledText(_ string: String?) -> ResolvedStyledText {
    ResolvedStyledText(
        storage: string.map { NSAttributedString(string: $0) },
        layoutProperties: TextLayoutProperties(EnvironmentValues()),
        layoutMargins: nil,
        stylePadding: .zero,
        archiveOptions: .init(),
        isCollapsible: false,
        features: [],
        suffix: .none,
        attachments: .init(),
        styles: [],
        transitions: [],
        scaleFactorOverride: nil
    )
}

#endif
