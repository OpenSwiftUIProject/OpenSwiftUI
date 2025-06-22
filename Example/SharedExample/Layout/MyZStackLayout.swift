//
//  MyZStackLayout.swift
//  SharedExample
//
//  Modified from https://github.com/fatbobman/BlogCodes/blob/main/MyZStack/MyZStack/_MyZStackLayout.swift
//  Copyright © 2022 Yang Xu. All rights reserved.

import Foundation
#if OPENSWIFTUI
import OpenSwiftUI
#else
import SwiftUI
#endif

private struct _MyZStackLayout: Layout {
    let alignment: Alignment

    func makeCache(subviews: Subviews) -> CacheInfo {
        .init()
    }

    // 容器的父视图（父容器）将通过调用容器的 sizeThatFits 获取容器的需求尺寸,本方法通常会被多次调用,并提供不同的建议尺寸
    func sizeThatFits(
        proposal: ProposedViewSize, // 容器的父视图（父容器）提供的建议尺寸
        subviews: Subviews, // 当前容器内的所有子视图的代理
        cache: inout CacheInfo // 缓存数据，本例中用于保存子视图的返回的需求尺寸,减少调用次数
    ) -> CGSize {
        cache = .init() // 清除缓存
        for subview in subviews {
            // 为子视图提供建议尺寸,获取子视图的需求尺寸 (ViewDimensions)
            let viewDimension = subview.dimensions(in: proposal)
            // 根据 MyZStack 的 alignment 的设置获取子视图的 alignmentGuide
            let alignmentGuide: CGPoint = .init(
                x: viewDimension[alignment.horizontal],
                y: viewDimension[alignment.vertical]
            )
            // 以子视图的 alignmentGuide 为 (0,0) , 在虚拟的画布中,为子视图创建 CGRect
            let bounds: CGRect = .init(
                origin: .init(x: -alignmentGuide.x, y: -alignmentGuide.y),
                size: .init(width: viewDimension.width, height: viewDimension.height)
            )
            // 保存子视图在虚拟画布中的数据
            cache.subviewInfo.append(.init(viewDimension: viewDimension, bounds: bounds))
        }

        // 根据所有子视图在虚拟画布中的数据,生成 MyZtack 的 CGRect
        cache.cropBounds = cache.subviewInfo.map(\.bounds).cropBounds()
        // 返回当前容器的理想尺寸, 当前容器的父视图将使用该尺寸在它的内部进行摆放
        return cache.cropBounds.size
    }

    // 容器的父视图(父容器)将在需要的时机调用本方法,为本容器的子视图设置渲染位置
    func placeSubviews(
        in bounds: CGRect, // 根据当前容器在 sizeThatFits 提供的尺寸,在真实渲染处创建的 CGRect
        proposal: ProposedViewSize, // 容器的父视图（父容器）提供的建议尺寸
        subviews: Subviews, // 当前容器内的所有子视图的代理
        cache: inout CacheInfo // 缓存数据，本例中用于保存子视图的返回的需求尺寸,减少调用次数
    ) {
        // 虚拟画布左上角的偏移值 ( 到 0,0 )
        let offsetX = cache.cropBounds.minX * -1
        let offsetY = cache.cropBounds.minY * -1

        for index in subviews.indices {
            let info = cache.subviewInfo[index]
            // 将虚拟画布中的位置信息转换成渲染 bounds 的位置信息
            let x = transformPoint(original: info.bounds.minX, offset: offsetX, targetBoundsMinX: bounds.minX)
            let y = transformPoint(original: info.bounds.minY, offset: offsetY, targetBoundsMinX: bounds.minY)
            // 将转换后的位置信息设置到子视图上，并为子视图设置渲染尺寸
            subviews[index].place(at: .init(x: x, y: y), anchor: .topLeading, proposal: proposal)
        }
    }

    // SwiftUI 通过此方法来获取特定的对齐参考的显式值
    func explicitAlignment(
        of guide: VerticalAlignment, // 查询的对齐指导
        in bounds: CGRect, // 自定义容器的 bounds ，该 bounds 的尺寸由 sizeThatFits 方法计算得出，与 placeSubviews 的 bounds 参数一致
        proposal: ProposedViewSize, // 父视图的推荐尺寸
        subviews: Subviews, // 容器内的子视图代理
        cache: inout CacheInfo // 缓存数据，本例中，我们在缓存数据中保存了每个子视图的 viewDimension、虚拟 bounds 能信息
    ) -> CGFloat? {
        let offsetY = cache.cropBounds.minY * -1
        let infinity: CGFloat = .infinity

        // 检查子视图中是否有 显式 firstTextBaseline 不为 nil 的视图。如果有，则返回位置最高的 firstTextBaseline 值。
        if guide == .firstTextBaseline,!cache.subviewInfo.isEmpty {
            let firstTextBaseline = cache.subviewInfo.reduce(infinity) { current, info in
                let baseline = info.viewDimension[explicit: .firstTextBaseline] ?? infinity
                // 将子视图的显式 firstTextBaseline 转换成 bounds 中的偏移值
                let transformBaseline = transformPoint(original: baseline + info.bounds.minY, offset: offsetY, targetBoundsMinX: 0)
                // 返回位置最高的值（ 值最小 ）
                return min(current, transformBaseline)
            }
            return firstTextBaseline != infinity ? firstTextBaseline : nil
        }

        if guide == .lastTextBaseline,!cache.subviewInfo.isEmpty {
            let lastTextBaseline = cache.subviewInfo.reduce(-infinity) { current, info in
                let baseline = info.viewDimension[explicit: .lastTextBaseline] ?? -infinity
                let transformBaseline = transformPoint(original: baseline + info.bounds.minY, offset: offsetY, targetBoundsMinX: 0)
                return max(current, transformBaseline)
            }
            return lastTextBaseline != -infinity ? lastTextBaseline : nil
        }

        return nil
    }

    func transformPoint(original: CGFloat, offset: CGFloat, targetBoundsMinX: CGFloat) -> CGFloat {
        original + offset + targetBoundsMinX
    }
}

extension _MyZStackLayout {
    struct CacheInfo {
        var subviewInfo: [SubViewInfo] = []
        var cropBounds: CGRect = .zero
    }

    struct SubViewInfo {
        let viewDimension: ViewDimensions
        var bounds: CGRect = .zero
    }
}

private extension Array where Element == CGRect {
    func cropBounds() -> CGRect {
        let leading = self.reduce(0) { currentLeading, bounds in
            Swift.min(currentLeading, bounds.minX)
        }
        let top = self.reduce(0) { currentTop, bounds in
            Swift.min(currentTop, bounds.minY)
        }
        let trailing = self.reduce(0) { currentTrailing, bounds in
            Swift.max(currentTrailing, bounds.maxX)
        }
        let bottom = self.reduce(0) { currentBottom, bounds in
            Swift.max(currentBottom, bounds.maxY)
        }
        return .init(x: leading, y: top, width: trailing - leading, height: bottom - top)
    }
}

public struct MyZStack<Content>: View where Content: View {
    let alignment: Alignment
    let content: Content
    public init(alignment: Alignment = .center, @ViewBuilder content: () -> Content) {
        self.alignment = alignment
        self.content = content()
    }

    public var body: some View {
        _MyZStackLayout(alignment: alignment)() {
            content
        }
    }
}
