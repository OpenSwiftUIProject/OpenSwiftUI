//
//  ShaftRenderer.swift
//  OpenSwiftUIShaftBackend
//
//  Created by OpenSwiftUI integration with Shaft
//

import Foundation
@_spi(ForOpenSwiftUIOnly) import OpenSwiftUICore
import Shaft

final class ShaftRenderer {

    /// Converter for DisplayList to Shaft widgets
    private let converter = DisplayListConverter()

    /// Last rendered DisplayList version for incremental updates
    private var lastVersion: OpenSwiftUICore.DisplayList.Version?

    /// ValueNotifier that holds the current widget tree
    /// Updating this automatically triggers Shaft rebuilds via @Observable
    private let widgetNotifier: ValueNotifier<Widget>

    init(widgetNotifier: ValueNotifier<Widget>) {
        self.widgetNotifier = widgetNotifier
    }

    func render(
        rootView: AnyObject,
        from list: OpenSwiftUICore.DisplayList,
        time: OpenSwiftUICore.Time,
        version: OpenSwiftUICore.DisplayList.Version,
        maxVersion: OpenSwiftUICore.DisplayList.Version,
        environment: OpenSwiftUICore.DisplayList.ViewRenderer.Environment
    ) -> OpenSwiftUICore.Time {
        mark(
            "render(rootView: \(rootView), from: \(list), time: \(time), version: \(version), maxVersion: \(maxVersion), environment: \(environment))"
        )

        // Check if we need to update based on version
        let needsFullRebuild = lastVersion == nil || lastVersion != version

        if needsFullRebuild {
            // Convert DisplayList to Shaft widget tree
            let shaftWidget = converter.convertDisplayList(
                list,
                contentsScale: environment.contentsScale
            )

            // Update the ValueNotifier - this automatically triggers rebuild
            // thanks to Shaft's @Observable support
            widgetNotifier.value = shaftWidget

            lastVersion = version
        }

        return .zero
    }

    func renderAsync(
        to list: OpenSwiftUICore.DisplayList,
        time: OpenSwiftUICore.Time,
        targetTimestamp: OpenSwiftUICore.Time?,
        version: OpenSwiftUICore.DisplayList.Version,
        maxVersion: OpenSwiftUICore.DisplayList.Version
    ) -> OpenSwiftUICore.Time? {
        // Async rendering not supported initially
        return nil
    }
}
