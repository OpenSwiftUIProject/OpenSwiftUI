//
//  FocusRingHelper.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: 1E6F543B2B96E8B73646864D883C37DC (SwiftUI)

#if os(macOS)
import AppKit
@_spi(ForOpenSwiftUIOnly)
import OpenSwiftUICore

// MARK: - FocusRingHelper

class FocusRingHelper {
    weak var responder: ViewResponder?
    weak var focusRingView: NSView?
    private var _focusRingPath: Path?

    init(responder: ViewResponder?, focusRingView: NSView?) {
        self.responder = responder
        self.focusRingView = focusRingView
    }

    var focusRingMaskBounds: CGRect {
        resolvedFocusRingPath.boundingRect
    }

    func drawFocusRingMask() {
        let path = resolvedFocusRingPath.cgPath
        if path.isEmpty {
            focusRingView?.bounds.fill()
        } else if let context = NSGraphicsContext.current?.cgContext {
            context.addPath(path)
            context.drawPath(using: .fill)
        }
    }

    private var resolvedFocusRingPath: Path {
        if let _focusRingPath {
            return _focusRingPath
        }
        var path = Path()
        responder?.addContentPath(
            to: &path,
            kind: .focusEffect,
            in: .id(focusCoordinateSpace),
            observer: self
        )
        if path.isEmpty {
            responder?.addContentPath(
                to: &path,
                kind: .interaction,
                in: .id(focusCoordinateSpace),
                observer: self
            )
            if !path.isContinuous {
                path = Path(path.boundingRect)
            }
        }
        _focusRingPath = path
        return path
    }
}

extension FocusRingHelper: TrivialContentPathObserver {
    func contentPathDidChange(for parent: ViewResponder) {
        _focusRingPath = nil
        focusRingView?.noteFocusRingMaskChanged()
    }
}

// MARK: - Path + isContinuous

extension Path {
    fileprivate var isContinuous: Bool {
        var isContinuous = true
        var hasDrawingElement = false
        forEach { element in
            if case .move = element {
                isContinuous = !hasDrawingElement
            } else {
                hasDrawingElement = true
            }
        }
        return isContinuous
    }
}
#endif
