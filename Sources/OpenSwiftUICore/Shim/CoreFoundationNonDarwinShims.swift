//
//  CoreFoundationNonDarwinShims.swift
//  OpenSwiftUICore

#if canImport(CoreFoundation) && !canImport(ObjectiveC)
public import CoreFoundation
public import Foundation

extension CFDictionary: @retroactive Swift.Hashable {
    public static func == (lhs: CFDictionary, rhs: CFDictionary) -> Bool {
        CFEqual(lhs, rhs)
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(CFHash(self))
    }
}

private let cfCompatObjectClassName = strdup("OpenSwiftUICFCompatObject")!

private nonisolated(unsafe) var cfCompatObjectClass = CFRuntimeClass(
    version: 0,
    className: UnsafePointer(cfCompatObjectClassName),
    init: nil,
    copy: nil,
    finalize: nil,
    equal: { lhs, rhs in (lhs as? NSObject)?.isEqual(rhs) ?? false },
    hash: { value in CFHashCode(bitPattern: (value as? NSObject)?.hash ?? 0) },
    copyFormattingDesc: nil,
    copyDebugDesc: nil,
    reclaim: nil,
    refcount: nil,
    requiredAlignment: 0
)

private let cfCompatObjectTypeID: CFTypeID = withUnsafePointer(to: &cfCompatObjectClass) {
    _CFRuntimeRegisterClass($0)
}

/// A base class for shim types that are stored as CoreFoundation values, such as
/// `NSAttributedString` attribute values.
///
/// Without an ObjC runtime, CoreFoundation identifies an object by reading the
/// `_cfinfoa` field of `CFRuntimeBase`, which in the Swift layout sits directly after
/// the isa and the refcount — the same offset as the first stored property of a Swift
/// `NSObject` subclass. Reading an unrelated property as `_cfinfoa` usually yields the
/// type ID `_kCFRuntimeIDNotAType`, whose `equal` callback is `HALT`.
///
/// Declaring the `_cfinfoa` storage first and stamping it with a registered type ID makes
/// the object a valid CoreFoundation instance, so `CFEqual` and `CFHash` route back to
/// `isEqual(_:)` and `hash`.
open class CFCompatObject: NSObject {
    /// Overlays `CFRuntimeBase._cfinfoa` and must stay the first stored property of the
    /// class hierarchy.
    private var _cfinfoa: UInt64 = 0

    public override init() {
        super.init()
        _cfinfoa = UInt64(cfCompatObjectTypeID) << 8
    }
}
#endif
