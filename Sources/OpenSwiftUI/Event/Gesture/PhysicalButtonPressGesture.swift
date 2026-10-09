//
//  PhysicalButtonPressGesture.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: 239A42CFB2879B10E971E788DAD9A1E6 (SwiftUI)

#if os(iOS) || os(visionOS)

@_spi(ForOpenSwiftUIOnly)
import OpenSwiftUICore

// MARK: - PhysicalButtonPressGesture

struct PhysicalButtonPressGesture: Gesture {
    var allowedButtonTypes: AllowedButtonTypes

    var body: some Gesture<PhysicalButtonEvent.ButtonType> {
        EventListener<PhysicalButtonEvent>()
            .mapPhase { phase -> GesturePhase<PhysicalButtonEvent.ButtonType> in
                switch phase {
                case .possible:
                    .possible(nil)
                case let .active(event):
                    allowedButtonTypes.contains(event.type) ? .active(event.type) : .possible(nil)
                case let .ended(event):
                    allowedButtonTypes.contains(event.type) ? .ended(event.type) : .failed
                case .failed:
                    .failed
                }
            }
            .dependency(.failIfActive)
    }
}

// MARK: - PhysicalButtonPressGesture.AllowedButtonTypes

extension PhysicalButtonPressGesture {
    struct AllowedButtonTypes: OptionSet {
        typealias Element = PhysicalButtonEvent.ButtonType

        let rawValue: Int

        init(rawValue: Int) {
            self.rawValue = rawValue
        }

        private init(_ button: Element) {
            rawValue = switch button {
            case .upArrow: 1 << 0
            case .downArrow: 1 << 1
            case .leftArrow: 1 << 2
            case .rightArrow: 1 << 3
            case .select: 1 << 4
            case .menu: 1 << 5
            case .playPause: 1 << 6
            case .pageUp: 1 << 7
            case .pageDown: 1 << 8
            case .back: 1 << 9
            }
        }

        func contains(_ member: Element) -> Bool {
            rawValue & Self(member).rawValue != 0
        }

        @discardableResult
        mutating func insert(_ newMember: Element) -> (inserted: Bool, memberAfterInsert: Element) {
            let inserted = !contains(newMember)
            if inserted {
                formUnion(Self(newMember))
            }
            return (inserted, newMember)
        }

        @discardableResult
        mutating func remove(_ member: Element) -> Element? {
            let removed = contains(member) ? member : nil
            subtract(Self(member))
            return removed
        }

        @discardableResult
        mutating func update(with newMember: Element) -> Element? {
            let oldMember = contains(newMember) ? newMember : nil
            formUnion(Self(newMember))
            return oldMember
        }
    }
}

#endif
