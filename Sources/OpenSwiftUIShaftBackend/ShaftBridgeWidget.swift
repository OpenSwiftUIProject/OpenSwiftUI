//
//  ShaftBridgeWidget.swift
//  OpenSwiftUIShaftBackend
//
//  Bridge widget that holds OpenSwiftUI's converted widget tree
//

import Foundation
import Shaft

/// A Shaft StatelessWidget that bridges OpenSwiftUI DisplayList updates
///
/// This widget uses a ValueNotifier to hold the current widget tree.
/// When the DisplayList changes and updates the notifier, Shaft's @Observable
/// system automatically triggers a rebuild.
final class ShaftBridgeWidget: StatelessWidget {
    init(widgetNotifier: ValueNotifier<Widget>) {
        self.widgetNotifier = widgetNotifier
    }
    
    /// ValueNotifier holding the current converted widget tree
    /// When this changes, the widget automatically rebuilds thanks to @Observable
    let widgetNotifier: ValueNotifier<Widget>
    
    public func build(context: BuildContext) -> Widget {
        print("widgetNotifier.value: \(widgetNotifier.value)")
        
        // Reading .value automatically subscribes to changes
        return widgetNotifier.value
    }
}

/// Empty widget used as initial placeholder
final class EmptyWidget: StatelessWidget {
    init() {}
    
    public func build(context: BuildContext) -> Widget {
        SizedBox(width: 0, height: 0)
    }
}

