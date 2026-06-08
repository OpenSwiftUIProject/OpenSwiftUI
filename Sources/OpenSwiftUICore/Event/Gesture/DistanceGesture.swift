//
//  DistanceGesture.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: AE77061B4A25E6848CE6B7A87EEE80F8 (SwiftUICore)

package import Foundation

// MARK: - DistanceGesture

package struct DistanceGesture: Gesture {
    package struct StateType: GestureStateProtocol {
        var start: CGPoint?
        var maxDistance: CGFloat

        package init() {
            start = nil
            maxDistance = .zero
        }

        @inline(__always)
        mutating func updateDistance(to location: CGPoint) -> CGFloat {
            let movement: CGFloat
            if let start {
                movement = distance(start, location)
                maxDistance = max(maxDistance, movement)
            } else {
                start = location
                movement = .zero
            }
            return movement
        }
    }

    package var minimumDistance: CGFloat

    package var maximumDistance: CGFloat

    package init(
        minimumDistance: CGFloat = 0,
        maximumDistance: CGFloat = .infinity
    ) {
        self.minimumDistance = minimumDistance
        self.maximumDistance = maximumDistance
    }

    package var body: some Gesture<CGFloat> {
        let minimumDistance = minimumDistance
        let maximumDistance = maximumDistance
        return StateType.gesture(content: EventListener<SpatialEvent>()) { state, phase in
            switch phase {
            case let .possible(event):
                guard let event else {
                    return .possible(nil)
                }
                return .possible(state.updateDistance(to: event.location))
            case let .active(event):
                let distance = state.updateDistance(to: event.location)
                guard maximumDistance > distance else {
                    return .failed
                }
                guard state.maxDistance >= minimumDistance else {
                    return .possible(distance)
                }
                return .active(distance)
            case let .ended(event):
                let distance = state.updateDistance(to: event.location)
                guard state.maxDistance >= minimumDistance, maximumDistance > distance else {
                    return .failed
                }
                return .ended(distance)
            case .failed:
                return .failed
            }
        }
    }

    package typealias Value = CGFloat
}
