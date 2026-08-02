//
//  SafeAreaInsetsTests.swift
//  OpenSwiftUICoreTests

import OpenAttributeGraphShims
import OpenCoreGraphicsShims
@_spi(ForOpenSwiftUIOnly)
import OpenSwiftUICore
import Testing

@MainActor
@Suite(.disabled(if: attributeGraphVendor == .oag))
struct SafeAreaInsetsTests {
    @Test
    func centeredRectDoesNotResolveInsets() {
        let space = CoordinateSpace.ID()
        let resolved = resolve(
            insets: safeAreaInsets(space: space),
            transform: transform(
                space: space,
                spaceSize: .init(width: 400, height: 800),
                localOrigin: .init(x: 150, y: 390)
            )
        )

        #expect(resolved == .zero)
    }

    @Test
    func edgeAlignedRectsResolveMatchingInset() {
        let space = CoordinateSpace.ID()
        let insets = EdgeInsets(top: 10, leading: 20, bottom: 30, trailing: 40)
        let safeAreaInsets = safeAreaInsets(space: space, insets: insets)
        func resolved(at localOrigin: CGPoint) -> EdgeInsets {
            resolve(
                insets: safeAreaInsets,
                transform: transform(
                    space: space,
                    spaceSize: .init(width: 400, height: 800),
                    localOrigin: localOrigin
                )
            )
        }

        #expect(
            resolved(at: .init(x: 150, y: 10)) ==
                .init(top: 10, leading: 0, bottom: 0, trailing: 0)
        )
        #expect(
            resolved(at: .init(x: 150, y: 750)) ==
                .init(top: 0, leading: 0, bottom: 30, trailing: 0)
        )
        #expect(
            resolved(at: .init(x: 20, y: 100)) ==
                .init(top: 0, leading: 20, bottom: 0, trailing: 0)
        )
        #expect(
            resolved(at: .init(x: 260, y: 100)) ==
                .init(top: 0, leading: 0, bottom: 0, trailing: 40)
        )
    }

    @Test
    func rightToLeftFlipsResolvedHorizontalInsets() {
        let space = CoordinateSpace.ID()
        let insets = EdgeInsets(top: 10, leading: 20, bottom: 30, trailing: 40)
        let safeAreaInsets = safeAreaInsets(space: space, insets: insets)
        func resolved(at localOrigin: CGPoint) -> EdgeInsets {
            resolve(
                layoutDirection: .rightToLeft,
                insets: safeAreaInsets,
                transform: transform(
                    space: space,
                    spaceSize: .init(width: 400, height: 800),
                    localOrigin: localOrigin
                )
            )
        }

        #expect(
            resolved(at: .init(x: 20, y: 100)) ==
                .init(top: 0, leading: 0, bottom: 0, trailing: 20)
        )
        #expect(
            resolved(at: .init(x: 260, y: 100)) ==
                .init(top: 0, leading: 40, bottom: 0, trailing: 0)
        )
    }

    @Test
    func missingCoordinateSpaceDoesNotResolveInsets() {
        let insetsSpace = CoordinateSpace.ID()
        let transformSpace = CoordinateSpace.ID()
        let resolved = resolve(
            insets: safeAreaInsets(space: insetsSpace),
            transform: transform(
                space: transformSpace,
                spaceSize: .init(width: 400, height: 800),
                localOrigin: .init(x: 150, y: 60)
            )
        )

        #expect(resolved == .zero)
    }

    @Test
    func unmatchedRegionsDoNotResolveInsets() {
        let space = CoordinateSpace.ID()
        let resolved = resolve(
            regions: .keyboard,
            insets: safeAreaInsets(space: space),
            transform: transform(
                space: space,
                spaceSize: .init(width: 400, height: 800),
                localOrigin: .init(x: 150, y: 60)
            )
        )

        #expect(resolved == .zero)
    }

    private func safeAreaInsets(
        space: CoordinateSpace.ID,
        insets: EdgeInsets = .init(top: 60, leading: 0, bottom: 0, trailing: 0)
    ) -> SafeAreaInsets {
        SafeAreaInsets(
            space: space,
            elements: [.init(
                regions: .container,
                insets: insets
            )]
        )
    }

    private func transform(
        space: CoordinateSpace.ID,
        spaceSize: CGSize,
        localOrigin: CGPoint
    ) -> ViewTransform {
        var transform = ViewTransform()
        transform.appendSizedSpace(id: space, size: spaceSize)
        transform.appendTranslation(-CGSize(localOrigin))
        return transform
    }

    private func resolve(
        regions: SafeAreaRegions = .container,
        layoutDirection: LayoutDirection = .leftToRight,
        insets: SafeAreaInsets,
        transform: ViewTransform
    ) -> EdgeInsets {
        let graph = ViewGraph(rootViewType: EmptyView.self)
        var environment = graph.environment
        environment.layoutDirection = layoutDirection
        return graph.rootSubgraph.apply {
            insets
                .resolve(
                    regions: regions,
                    in: .init(
                        context: AnyRuleContext(attribute: graph.rootView),
                        size: .init(value: .fixed(.init(width: 100, height: 20))),
                        environment: .init(value: environment),
                        transform: .init(value: transform),
                        position: .init(value: graph.zeroPoint),
                        safeAreaInsets: .init()
                    )
                )
        }
    }
}
