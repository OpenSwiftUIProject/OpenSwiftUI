//
//  SpacingTests.swift
//  OpenSwiftUICoreTests
//
//  Audited for iOS 18.0
//  Status: Complete

import Numerics
@_spi(ForOpenSwiftUIOnly)
import OpenSwiftUICore
import Testing

struct SpacingTests {
    // MARK: - Category Tests

    struct CategoryTests {
        @Test
        func equality() {
            let textToText1 = Spacing.Category.textToText
            let textToText2 = Spacing.Category.textToText
            let edgeAboveText = Spacing.Category.edgeAboveText

            #expect(textToText1 == textToText2)
            #expect(textToText1 != edgeAboveText)
        }

        @Test
        func predefinedCategories() {
            // Testing all predefined categories
            let categories = [
                Spacing.Category.textToText,
                Spacing.Category.edgeAboveText,
                Spacing.Category.edgeBelowText,
                Spacing.Category.textBaseline,
                Spacing.Category.edgeLeftText,
                Spacing.Category.edgeRightText,
                Spacing.Category.leftTextBaseline,
                Spacing.Category.rightTextBaseline,
            ]

            // Ensure all categories are unique
            var uniqueCategories = Set<Spacing.Category>()
            for category in categories {
                uniqueCategories.insert(category)
            }

            #expect(uniqueCategories.count == 8)
        }
    }

    // MARK: - Key Tests

    struct KeyTests {
        @Test
        func initialization() {
            let key1 = Spacing.Key(category: .textToText, edge: .top)
            #expect(key1.category == .textToText)
            #expect(key1.edge == .top)

            let key2 = Spacing.Key(category: nil, edge: .bottom)
            #expect(key2.category == nil)
            #expect(key2.edge == .bottom)

            #expect(key1 != key2)
        }

        @Test
        func equality() {
            let key1 = Spacing.Key(category: .textToText, edge: .top)
            let key2 = Spacing.Key(category: .textToText, edge: .top)
            let key3 = Spacing.Key(category: .edgeAboveText, edge: .top)
            let key4 = Spacing.Key(category: .textToText, edge: .bottom)

            #expect(key1 == key2)
            #expect(key1 != key3)
            #expect(key1 != key4)
        }
    }

    // MARK: - TextMetrics Tests

    struct TextMetricsTests {
        typealias TextMetrics = Spacing.TextMetrics

        @Test
        func isAlmostEqual() {
            let m1 = TextMetrics(ascend: 1, descend: 2, leading: 3, pixelLength: 4)
            let m2 = TextMetrics(ascend: 1, descend: 2, leading: 3, pixelLength: 5)
            #expect(m1.isAlmostEqual(to: m2))

            let m3 = TextMetrics(ascend: 1.1, descend: 2, leading: 3, pixelLength: 4)
            #expect(!m1.isAlmostEqual(to: m3))
        }

        @Test
        func spacing() {
            let m1 = TextMetrics(ascend: 2, descend: 3, leading: 5, pixelLength: 13)
            let m2 = TextMetrics(ascend: 2, descend: 3, leading: 5, pixelLength: 13)
            let m3 = TextMetrics(ascend: 7, descend: 11, leading: 17, pixelLength: 23)
            #expect(TextMetrics.spacing(top: m1, bottom: m2).isApproximatelyEqual(to: 13))
            #expect(TextMetrics.spacing(top: m1, bottom: m3).isApproximatelyEqual(to: 26))
            #expect(TextMetrics.spacing(top: m3, bottom: m1).isApproximatelyEqual(to: 23))
        }

        @Test
        func lineSpacing() {
            let metris = TextMetrics(ascend: 2, descend: 3, leading: 5, pixelLength: 13)
            #expect(metris.lineSpacing.isApproximatelyEqual(to: 10))
        }

        @Test
        func comparison() {
            let m1 = TextMetrics(ascend: 2, descend: 3, leading: 5, pixelLength: 13)
            let m2 = TextMetrics(ascend: 2, descend: 3, leading: 4, pixelLength: 10)
            let m3 = TextMetrics(ascend: 5, descend: 3, leading: 2, pixelLength: 13)
            let m4 = TextMetrics(ascend: 2, descend: 3, leading: 5, pixelLength: 13)

            #expect(m2 < m1)

            #expect(!(m1 < m3))
            #expect(!(m1 > m3))
            #expect(m1 != m3)

            #expect(m1 == m4)
        }
    }

    // MARK: - Value Tests

    struct ValueTests {
        typealias TextMetrics = Spacing.TextMetrics
        typealias Value = Spacing.Value

        @Test
        func initialization() {
            _ = Value(10.0)
            let metrics = TextMetrics(ascend: 2, descend: 3, leading: 5, pixelLength: 13)
            _ = Value.topTextMetrics(metrics)
            _ = Value.bottomTextMetrics(metrics)
        }

        @Test
        func getValue() throws {
            let v1 = Value(10.0)
            let metrics = TextMetrics(ascend: 2, descend: 3, leading: 5, pixelLength: 13)
            let v2 = Value.topTextMetrics(metrics)

            let value = try #require(v1.value)
            #expect(value.isApproximatelyEqual(to: 10.0))
            #expect(v2.value == nil)
        }

        @Test
        func distance() throws {
            let d1 = Value(10.0)
            let d2 = Value(15.0)
            #expect(d1.distance(to: d2) == 25.0)

            let tm1 = TextMetrics(ascend: 2, descend: 3, leading: 5, pixelLength: 13)
            let tm2 = TextMetrics(ascend: 7, descend: 11, leading: 17, pixelLength: 23)

            let top1 = Value.topTextMetrics(tm1)
            let bottom1 = Value.bottomTextMetrics(tm1)
            let top2 = Value.topTextMetrics(tm2)
            let bottom2 = Value.bottomTextMetrics(tm2)

            #expect(top1.distance(to: top2) == nil)
            #expect(bottom1.distance(to: bottom2) == nil)

            #expect(top1.distance(to: bottom2)?.isApproximatelyEqual(to: 26) == true)
            #expect(bottom1.distance(to: top2)?.isApproximatelyEqual(to: 23) == true)

            #expect(d1.distance(to: top1) == 10.0)
            #expect(top1.distance(to: d1) == 10.0)
        }

        @Test
        func comparison() {
            let d1 = Value(10.0)
            let d2 = Value(20.0)

            // Distance comparison
            #expect(d1 < d2)
            #expect(!(d2 < d1))
            #expect(d1 == Value(10.0))

            // TextMetrics comparison
            let tm1 = TextMetrics(ascend: 2, descend: 3, leading: 5, pixelLength: 13)
            let tm2 = TextMetrics(ascend: 7, descend: 11, leading: 17, pixelLength: 23)

            let top1 = Value.topTextMetrics(tm1)
            let top2 = Value.topTextMetrics(tm2)
            let bottom1 = Value.bottomTextMetrics(tm1)
            let bottom2 = Value.bottomTextMetrics(tm2)

            // TextMetrics of same type comparison
            #expect(top1 < top2)
            #expect(bottom1 < bottom2)

            // Mixed type comparisons
            #expect(d1 < top1) // Distance < TopTextMetrics
            #expect(d1 < bottom1) // Distance < BottomTextMetrics
            #expect(top1 < bottom1) // TopTextMetrics < BottomTextMetrics

            // Equality
            #expect(top1 == Value.topTextMetrics(tm1))
            #expect(bottom1 == Value.bottomTextMetrics(tm1))
            #expect(top1 != bottom1)
            #expect(d1 != top1)
        }
    }

    // MARK: - Spacing Modification Tests

    @Test
    func incorporate() throws {
        var spacing1 = Spacing(minima: [
            Spacing.Key(category: nil, edge: .top): .distance(5),
            Spacing.Key(category: nil, edge: .left): .distance(10),
        ])

        let other = Spacing(minima: [
            Spacing.Key(category: nil, edge: .top): .distance(8),
            Spacing.Key(category: nil, edge: .left): .distance(3),
            Spacing.Key(category: nil, edge: .right): .distance(15),
        ])

        // Incorporate all edges
        spacing1.incorporate(.all, of: other)
        #expect(spacing1 == Spacing(minima: [
            Spacing.Key(category: nil, edge: .top): .distance(8),
            Spacing.Key(category: nil, edge: .left): .distance(10),
            Spacing.Key(category: nil, edge: .right): .distance(15),
        ]))

        // Test with partial edge set
        var spacing2 = Spacing(minima: [
            Spacing.Key(category: nil, edge: .top): .distance(5),
        ])

        spacing2.incorporate([.left], of: other)
        #expect(spacing2 == Spacing(minima: [
            Spacing.Key(category: nil, edge: .top): .distance(5),
            Spacing.Key(category: nil, edge: .left): .distance(3),
        ]))

        // Test with empty edge set
        var spacing3 = Spacing(minima: [
            Spacing.Key(category: nil, edge: .top): .distance(5),
        ])

        spacing3.incorporate([], of: other)
        #expect(spacing3 == Spacing(minima: [
            Spacing.Key(category: nil, edge: .top): .distance(5),
        ]))
    }

    @Test
    func clear() throws {
        // Test clear with AbsoluteEdge.Set

        var spacing1 = Spacing(minima: [
            Spacing.Key(category: nil, edge: .top): .distance(5),
            Spacing.Key(category: nil, edge: .left): .distance(10),
            Spacing.Key(category: nil, edge: .bottom): .distance(15),
            Spacing.Key(category: nil, edge: .right): .distance(20),
        ])

        // Clear vertical edges
        spacing1.clear([.top, .bottom])

        #expect(spacing1 == Spacing(minima: [
            Spacing.Key(category: nil, edge: .left): .distance(10),
            Spacing.Key(category: nil, edge: .right): .distance(20),
        ]))

        // Test clear with Edge.Set and LayoutDirection
        var spacing2 = Spacing(minima: [
            Spacing.Key(category: nil, edge: .top): .distance(5),
            Spacing.Key(category: nil, edge: .left): .distance(10),
            Spacing.Key(category: nil, edge: .right): .distance(15),
        ])
        var spacing3 = spacing2

        // In LTR, .leading is .left
        spacing2.clear(.leading, layoutDirection: .leftToRight)
        #expect(spacing2 == Spacing(minima: [
            Spacing.Key(category: nil, edge: .top): .distance(5),
            Spacing.Key(category: nil, edge: .right): .distance(15),
        ]))
        // In RTL, .leading is .right
        spacing3.clear(.leading, layoutDirection: .rightToLeft)
        #expect(spacing3 == Spacing(minima: [
            Spacing.Key(category: nil, edge: .top): .distance(5),
            Spacing.Key(category: nil, edge: .left): .distance(10),
        ]))

        // Test with empty edge set
        var spacing4 = Spacing(minima: [
            Spacing.Key(category: nil, edge: .top): .distance(5),
        ])

        spacing4.clear([])
        #expect(spacing4 == Spacing(minima: [
            Spacing.Key(category: nil, edge: .top): .distance(5),
        ]))
    }

    @Test
    func reset() throws {
        // Test reset with AbsoluteEdge.Set
        var spacing1 = Spacing(minima: [
            Spacing.Key(category: nil, edge: .top): .distance(5),
            Spacing.Key(category: nil, edge: .left): .distance(10),
            Spacing.Key(category: nil, edge: .bottom): .distance(15),
            Spacing.Key(category: nil, edge: .right): .distance(20),
        ])

        spacing1.reset([.top, .bottom])
        #expect(spacing1 == Spacing(minima: [
            Spacing.Key(category: .edgeBelowText, edge: .top): .distance(0),
            Spacing.Key(category: nil, edge: .left): .distance(10),
            Spacing.Key(category: .edgeAboveText, edge: .bottom): .distance(0),
            Spacing.Key(category: nil, edge: .right): .distance(20),
        ]))

        // Test reset with Edge.Set and LayoutDirection
        var spacing2 = Spacing(minima: [
            Spacing.Key(category: nil, edge: .top): .distance(5),
            Spacing.Key(category: nil, edge: .left): .distance(10),
            Spacing.Key(category: nil, edge: .right): .distance(15),
        ])
        var spacing3 = spacing2

        // In LTR, .leading is .left
        spacing2.reset(.leading, layoutDirection: .leftToRight)
        #expect(spacing2 == Spacing(minima: [
            Spacing.Key(category: nil, edge: .top): .distance(5),
            Spacing.Key(category: .edgeRightText, edge: .left): .distance(0),
            Spacing.Key(category: nil, edge: .right): .distance(15),
        ]))

        // In RTL, .leading is .right
        spacing3.reset(.leading, layoutDirection: .rightToLeft)
        #expect(spacing3 == Spacing(minima: [
            Spacing.Key(category: nil, edge: .top): .distance(5),
            Spacing.Key(category: nil, edge: .left): .distance(10),
            Spacing.Key(category: .edgeLeftText, edge: .right): .distance(0),
        ]))

        // Test with empty edge set
        var spacing4 = Spacing(minima: [
            Spacing.Key(category: nil, edge: .top): .distance(5),
        ])

        spacing4.reset([])
        #expect(spacing4 == Spacing(minima: [
            Spacing.Key(category: nil, edge: .top): .distance(5),
        ]))
    }

    // MARK: - Spacing Initialization Tests

    @Test
    func defaultInitialization() throws {
        let spacing = Spacing()

        // Verify default values are set for text edge categories
        let keys = [
            Spacing.Key(category: .edgeBelowText, edge: .top),
            Spacing.Key(category: .edgeRightText, edge: .left),
            Spacing.Key(category: .edgeAboveText, edge: .bottom),
            Spacing.Key(category: .edgeLeftText, edge: .right),
        ]

        for key in keys {
            let value = try #require(spacing.minima[key])
            #expect(value == .distance(0))
        }
    }

    @Test
    func customInitialization() throws {
        let minima: [Spacing.Key: Spacing.Value] = [
            Spacing.Key(category: nil, edge: .top): .distance(10),
            Spacing.Key(category: nil, edge: .left): .distance(20),
        ]

        let spacing = Spacing(minima: minima)

        #expect(spacing.minima.count == 2)

        let topKey = Spacing.Key(category: nil, edge: .top)
        let topValue = try #require(spacing.minima[topKey])
        #expect(topValue == .distance(10))

        let leftKey = Spacing.Key(category: nil, edge: .left)
        let leftValue = try #require(spacing.minima[leftKey])
        #expect(leftValue == .distance(20))
    }

    @Test
    func distanceToSuccessorView() {
        do {
            let spacing1 = Spacing(minima: [
                Spacing.Key(category: nil, edge: .top): .distance(2),
                Spacing.Key(category: nil, edge: .left): .distance(3),
                Spacing.Key(category: nil, edge: .bottom): .distance(7),
                Spacing.Key(category: nil, edge: .right): .distance(11),
            ])
            let spacing2 = Spacing(minima: [
                Spacing.Key(category: nil, edge: .top): .distance(13),
                Spacing.Key(category: nil, edge: .left): .distance(17),
                Spacing.Key(category: nil, edge: .bottom): .distance(21),
                Spacing.Key(category: nil, edge: .right): .distance(23),
            ])
            #expect(spacing1.distanceToSuccessorView(along: .horizontal, layoutDirection: .leftToRight, preferring: spacing2)!.isApproximatelyEqual(to: 17))
            #expect(spacing1.distanceToSuccessorView(along: .horizontal, layoutDirection: .rightToLeft, preferring: spacing2)!.isApproximatelyEqual(to: 23))
            #expect(spacing1.distanceToSuccessorView(along: .vertical, layoutDirection: .leftToRight, preferring: spacing2)!.isApproximatelyEqual(to: 13))
            #expect(spacing1.distanceToSuccessorView(along: .vertical, layoutDirection: .leftToRight, preferring: spacing2)!.isApproximatelyEqual(to: 13))

            #expect(spacing2.distanceToSuccessorView(along: .horizontal, layoutDirection: .leftToRight, preferring: spacing1)!.isApproximatelyEqual(to: 23))
            #expect(spacing2.distanceToSuccessorView(along: .horizontal, layoutDirection: .rightToLeft, preferring: spacing1)!.isApproximatelyEqual(to: 17))
            #expect(spacing2.distanceToSuccessorView(along: .vertical, layoutDirection: .leftToRight, preferring: spacing1)!.isApproximatelyEqual(to: 21))
            #expect(spacing2.distanceToSuccessorView(along: .vertical, layoutDirection: .leftToRight, preferring: spacing1)!.isApproximatelyEqual(to: 21))
        }
        do {
            let spacing1 = Spacing(minima: [
                Spacing.Key(category: .edgeBelowText, edge: .top): .distance(2),
                Spacing.Key(category: .edgeAboveText, edge: .bottom): .distance(3),
                Spacing.Key(category: .edgeRightText, edge: .left): .distance(5),
                Spacing.Key(category: .edgeLeftText, edge: .right): .distance(7),
            ])
            let spacing2 = Spacing(minima: [
                Spacing.Key(category: .edgeBelowText, edge: .top): .distance(13),
                Spacing.Key(category: .edgeAboveText, edge: .left): .distance(17),
                Spacing.Key(category: .edgeRightText, edge: .bottom): .distance(21),
                Spacing.Key(category: .edgeLeftText, edge: .right): .distance(23),
            ])
            #expect(spacing1.distanceToSuccessorView(along: .horizontal, layoutDirection: .leftToRight, preferring: spacing2) == nil)
            #expect(spacing1.distanceToSuccessorView(along: .horizontal, layoutDirection: .rightToLeft, preferring: spacing2) == nil)
            #expect(spacing1.distanceToSuccessorView(along: .vertical, layoutDirection: .leftToRight, preferring: spacing2) == nil)
            #expect(spacing1.distanceToSuccessorView(along: .vertical, layoutDirection: .leftToRight, preferring: spacing2) == nil)

            #expect(spacing2.distanceToSuccessorView(along: .horizontal, layoutDirection: .leftToRight, preferring: spacing1) == nil)
            #expect(spacing2.distanceToSuccessorView(along: .horizontal, layoutDirection: .rightToLeft, preferring: spacing1) == nil)
            #expect(spacing2.distanceToSuccessorView(along: .vertical, layoutDirection: .leftToRight, preferring: spacing1) == nil)
            #expect(spacing2.distanceToSuccessorView(along: .vertical, layoutDirection: .leftToRight, preferring: spacing1) == nil)
        }
        do {
            let spacing1 = Spacing(minima: [
                Spacing.Key(category: nil, edge: .top): .distance(2),
                Spacing.Key(category: nil, edge: .left): .distance(3),
                Spacing.Key(category: .edgeRightText, edge: .left): .distance(5),
                Spacing.Key(category: .edgeLeftText, edge: .right): .distance(7),
            ])
            let spacing2 = Spacing(minima: [
                Spacing.Key(category: .edgeBelowText, edge: .top): .distance(13),
                Spacing.Key(category: .edgeAboveText, edge: .left): .distance(17),
                Spacing.Key(category: nil, edge: .bottom): .distance(21),
                Spacing.Key(category: nil, edge: .right): .distance(23),
            ])
            #expect(spacing1.distanceToSuccessorView(along: .horizontal, layoutDirection: .leftToRight, preferring: spacing2) == nil)
            #expect(spacing1.distanceToSuccessorView(along: .horizontal, layoutDirection: .rightToLeft, preferring: spacing2)!.isApproximatelyEqual(to: 23))
            #expect(spacing1.distanceToSuccessorView(along: .vertical, layoutDirection: .leftToRight, preferring: spacing2) == nil)
            #expect(spacing1.distanceToSuccessorView(along: .vertical, layoutDirection: .leftToRight, preferring: spacing2) == nil)

            #expect(spacing2.distanceToSuccessorView(along: .horizontal, layoutDirection: .leftToRight, preferring: spacing1)!.isApproximatelyEqual(to: 23))
            #expect(spacing2.distanceToSuccessorView(along: .horizontal, layoutDirection: .rightToLeft, preferring: spacing1) == nil)
            #expect(spacing2.distanceToSuccessorView(along: .vertical, layoutDirection: .leftToRight, preferring: spacing1)!.isApproximatelyEqual(to: 21))
            #expect(spacing2.distanceToSuccessorView(along: .vertical, layoutDirection: .leftToRight, preferring: spacing1)!.isApproximatelyEqual(to: 21))
        }
    }

    @Test
    func distanceToSuccessorView2() {
        do {
            let m = Spacing.TextMetrics(ascend: 1, descend: 3, leading: 5, pixelLength: 7)
            let spacing1 = Spacing(minima: [
                Spacing.Key(category: .edgeLeftText, edge: .right): .distance(2),
            ])
            let spacing2 = Spacing(minima: [
                Spacing.Key(category: .edgeLeftText, edge: .left): .distance(13),
                Spacing.Key(category: .edgeRightText, edge: .left): .bottomTextMetrics(m),
            ])
            #expect(spacing1.distanceToSuccessorView(along: .horizontal, layoutDirection: .leftToRight, preferring: spacing2)!.isApproximatelyEqual(to: 15))
            #expect(spacing1.distanceToSuccessorView(along: .horizontal, layoutDirection: .rightToLeft, preferring: spacing2) == nil)

            #expect(spacing2.distanceToSuccessorView(along: .horizontal, layoutDirection: .leftToRight, preferring: spacing1) == nil)
            #expect(spacing2.distanceToSuccessorView(along: .horizontal, layoutDirection: .rightToLeft, preferring: spacing1)!.isApproximatelyEqual(to: 15))
        }
        do {
            let m = Spacing.TextMetrics(ascend: 1, descend: 3, leading: 5, pixelLength: 7)
            let spacing1 = Spacing(minima: [
                Spacing.Key(category: .edgeLeftText, edge: .left): .distance(2),
            ])
            let spacing2 = Spacing(minima: [
                Spacing.Key(category: .edgeLeftText, edge: .right): .distance(13),
                Spacing.Key(category: .edgeRightText, edge: .right): .bottomTextMetrics(m),
            ])
            #expect(spacing1.distanceToSuccessorView(along: .horizontal, layoutDirection: .leftToRight, preferring: spacing2) == nil)
            #expect(spacing1.distanceToSuccessorView(along: .horizontal, layoutDirection: .rightToLeft, preferring: spacing2)!.isApproximatelyEqual(to: 15))

            #expect(spacing2.distanceToSuccessorView(along: .horizontal, layoutDirection: .leftToRight, preferring: spacing1)!.isApproximatelyEqual(to: 15))
            #expect(spacing2.distanceToSuccessorView(along: .horizontal, layoutDirection: .rightToLeft, preferring: spacing1) == nil)
        }
        do {
            let m = Spacing.TextMetrics(ascend: 1, descend: 3, leading: 5, pixelLength: 7)
            let spacing1 = Spacing(minima: [
                Spacing.Key(category: .edgeLeftText, edge: .bottom): .distance(2),
            ])
            let spacing2 = Spacing(minima: [
                Spacing.Key(category: .edgeLeftText, edge: .top): .distance(13),
                Spacing.Key(category: .edgeRightText, edge: .top): .bottomTextMetrics(m),
            ])
            #expect(spacing1.distanceToSuccessorView(along: .vertical, layoutDirection: .leftToRight, preferring: spacing2)!.isApproximatelyEqual(to: 15))
            #expect(spacing1.distanceToSuccessorView(along: .vertical, layoutDirection: .rightToLeft, preferring: spacing2)!.isApproximatelyEqual(to: 15))

            #expect(spacing2.distanceToSuccessorView(along: .vertical, layoutDirection: .rightToLeft, preferring: spacing1) == nil)
            #expect(spacing2.distanceToSuccessorView(along: .vertical, layoutDirection: .rightToLeft, preferring: spacing1) == nil)
        }
        do {
            let m1 = Spacing.TextMetrics(ascend: 1, descend: 3, leading: 5, pixelLength: 3)
            let m2 = Spacing.TextMetrics(ascend: 9999, descend: 9999, leading: 5, pixelLength: 9999)
            let m3 = Spacing.TextMetrics(ascend: 9999, descend: 9999, leading: 1, pixelLength: 9999)

            let spacing1 = Spacing(minima: [
                Spacing.Key(category: .edgeLeftText, edge: .bottom): .bottomTextMetrics(m1),
            ])
            let spacing2 = Spacing(minima: [
                Spacing.Key(category: .edgeLeftText, edge: .top): .distance(13),
                Spacing.Key(category: .edgeRightText, edge: .top): .topTextMetrics(m2),
            ])
            let spacing3 = Spacing(minima: [
                Spacing.Key(category: .edgeLeftText, edge: .top): .distance(13),
                Spacing.Key(category: .edgeRightText, edge: .top): .topTextMetrics(m3),
            ])
            #expect(spacing1.distanceToSuccessorView(along: .vertical, layoutDirection: .leftToRight, preferring: spacing2)!.isApproximatelyEqual(to: 13))
            #expect(spacing1.distanceToSuccessorView(along: .vertical, layoutDirection: .leftToRight, preferring: spacing3)!.isApproximatelyEqual(to: 13))
        }
    }

    // MARK: - description Tests

    @Test
    func description() {
        // zero spacing
        #expect(Spacing.zero.description == #"""
        Spacing [
          (default, top) : 0.0
          (default, left) : 0.0
          (default, bottom) : 0.0
          (default, right) : 0.0
        ]
        """#)

        // Default spacing
        #expect(Spacing().description == #"""
        Spacing [
          (EdgeBelowText, top) : 0.0
          (EdgeRightText, left) : 0.0
          (EdgeAboveText, bottom) : 0.0
          (EdgeLeftText, right) : 0.0
        ]
        """#)

        // Empty case
        #expect(Spacing(minima: [:]).description == #"""
        Spacing (empty)
        """#)

        // spacing with metircs
        let m = Spacing.TextMetrics(ascend: 1, descend: 3, leading: 5, pixelLength: 7)
        #expect(Spacing(minima: [
            Spacing.Key(category: .edgeLeftText, edge: .left): .distance(13),
            Spacing.Key(category: nil, edge: .left): .bottomTextMetrics(m),
            Spacing.Key(category: .edgeAboveText, edge: .left): .topTextMetrics(m),
        ]).description == #"""
        Spacing [
          (default, left) : TextMetrics(ascend: 1.0, descend: 3.0, leading: 5.0, pixelLength: 7.0)
          (EdgeAboveText, left) : TextMetrics(ascend: 1.0, descend: 3.0, leading: 5.0, pixelLength: 7.0)
          (EdgeLeftText, left) : 13.0
        ]
        """#)

        // spacing with key ordering
        enum UnknownCategory {}

        #expect(Spacing(minima: [
            Spacing.Key(category: .edgeLeftText, edge: .right): .distance(0),
            Spacing.Key(category: nil, edge: .right): .distance(0),
            Spacing.Key(category: .edgeAboveText, edge: .right): .distance(0),
            Spacing.Key(category: Spacing.Category(UnknownCategory.self), edge: .right): .distance(0),
            Spacing.Key(category: .edgeLeftText, edge: .left): .distance(0),
            Spacing.Key(category: nil, edge: .left): .distance(0),
            Spacing.Key(category: .edgeAboveText, edge: .left): .distance(0),
            Spacing.Key(category: Spacing.Category(UnknownCategory.self), edge: .left): .distance(0),
        ]).description == #"""
        Spacing [
          (default, left) : 0.0
          (EdgeAboveText, left) : 0.0
          (EdgeLeftText, left) : 0.0
          (UnknownCategory, left) : 0.0
          (default, right) : 0.0
          (EdgeAboveText, right) : 0.0
          (EdgeLeftText, right) : 0.0
          (UnknownCategory, right) : 0.0
        ]
        """#)
    }

    // MARK: - isLayoutDirectionSymmetric Tests

    @Test
    func layoutDirectionSymmetry() {
        #expect(!Spacing().isLayoutDirectionSymmetric)
        #expect(Spacing.horizontal(10).isLayoutDirectionSymmetric)
        #expect(Spacing.vertical(10).isLayoutDirectionSymmetric)
        #expect(Spacing.all(10).isLayoutDirectionSymmetric)

        #expect(Spacing(minima: [Spacing.Key(category: nil, edge: .top): .distance(0)]).isLayoutDirectionSymmetric)
        #expect(Spacing(minima: [Spacing.Key(category: nil, edge: .top): .distance(5)]).isLayoutDirectionSymmetric)

        #expect(!Spacing(minima: [Spacing.Key(category: nil, edge: .left): .distance(0)]).isLayoutDirectionSymmetric)
        #expect(!Spacing(minima: [Spacing.Key(category: nil, edge: .left): .distance(5)]).isLayoutDirectionSymmetric)

        #expect(!Spacing(minima: [
            Spacing.Key(category: nil, edge: .left): .distance(5),
            Spacing.Key(category: nil, edge: .right): .distance(6),
        ]).isLayoutDirectionSymmetric)
        #expect(Spacing(minima: [
            Spacing.Key(category: nil, edge: .left): .distance(5),
            Spacing.Key(category: nil, edge: .right): .distance(5),
        ]).isLayoutDirectionSymmetric)

        #expect(!Spacing(minima: [
            Spacing.Key(category: .edgeAboveText, edge: .left): .distance(5),
            Spacing.Key(category: .edgeLeftText, edge: .right): .distance(5),
        ]).isLayoutDirectionSymmetric)

        #expect(Spacing(minima: [
            Spacing.Key(category: .edgeAboveText, edge: .left): .distance(5),
            Spacing.Key(category: .edgeAboveText, edge: .right): .distance(5),
        ]).isLayoutDirectionSymmetric)

        #expect(!Spacing(minima: [
            Spacing.Key(category: .edgeLeftText, edge: .left): .distance(5),
            Spacing.Key(category: .edgeRightText, edge: .right): .distance(5),
        ]).isLayoutDirectionSymmetric)
    }
}
