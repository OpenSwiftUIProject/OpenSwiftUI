//
//  HitTestingLayoutGesture.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: 08DD5C158FE36CD77A595A02C0B3F8E2 (SwiftUI)

@_spi(ForOpenSwiftUIOnly)
public import OpenSwiftUICore

// MARK: - View + hitTestingLayoutGesture

extension View {
    /// Rebinds hit-testable events to the frontmost child that contains the
    /// event location.
    ///
    /// A layout normally keeps an event bound to the child view that first
    /// received it, even after the event location leaves that child. With
    /// this modifier, each time the layout receives events, it checks the
    /// child that holds each hit-testable event. If that child no longer
    /// contains the event location, the layout rebinds the event to the last
    /// child, in declaration order, whose content shape contains the
    /// location. Later children draw in front of earlier children, so the
    /// search starts with the frontmost child. Events that are not
    /// hit-testable keep their binding.
    ///
    /// Use this modifier on a container whose children take over a touch or
    /// pointer as it moves across them, for example a segmented control that
    /// highlights the segment under the finger.
    ///
    /// - Returns: A view that rebinds hit-testable events to the child under
    ///   the event location.
    @_spi(DoNotImport)
    @available(OpenSwiftUI_v3_0, *)
    nonisolated public func hitTestingLayoutGesture() -> some View {
        layoutGesture { HitTestingLayoutGesture(responder: $0) }
    }
}

// MARK: - HitTestingLayoutGesture

private struct HitTestingLayoutGesture: LayoutGesture {
    var responder: MultiViewResponder

    func updateEventBindings(
        _ events: inout [EventID: any EventType],
        proxy: LayoutGestureChildProxy
    ) {
        for (id, event) in events {
            guard let binding = events[id]?.binding,
                  let hitTestableEvent = HitTestableEvent(event)
            else {
                continue
            }
            let location = hitTestableEvent.hitTestLocation
            guard let boundIndex = proxy.firstIndex(where: { $0.binds(binding) }),
                  !proxy[boundIndex].containsGlobalLocation(location)
            else {
                continue
            }
            for index in proxy.indices.reversed() where index != boundIndex {
                guard proxy[index].containsGlobalLocation(location),
                      let change = proxy.bindChild(index: index, event: event, id: id)
                else {
                    continue
                }
                var event = event
                event.binding = change.to
                events[id] = event
                break
            }
        }
    }
}
