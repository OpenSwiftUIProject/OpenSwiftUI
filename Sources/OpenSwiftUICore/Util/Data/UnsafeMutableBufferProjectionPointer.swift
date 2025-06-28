//
//  UnsafeMutableBufferProjectionPointer.swift
//  OpenSwiftUICore
//
//  Status: Complete

// MARK: - UnsafeMutableBufferProjectionPointer [6.5.4]

package struct UnsafeMutableBufferProjectionPointer<Scene, Subject>: RandomAccessCollection, MutableCollection {
    package var startIndex: Int { 0 }

    private let _start: UnsafeMutableRawPointer

    package let endIndex: Int

    @inline(__always)
    package init() {
        _start = UnsafeMutableRawPointer(mutating: UnsafePointer<Subject>.null)
        endIndex = 0
    }

    @inline(__always)
    package init(start: UnsafeMutablePointer<Subject>, count: Int) {
        _start = UnsafeMutableRawPointer(start)
        endIndex = count
    }

    @inline(__always)
    package init(
        _ base: UnsafeMutableBufferPointer<Scene>,
        _ keyPath: WritableKeyPath<Scene, Subject>
    ) {
        if base.isEmpty {
            _start = UnsafeMutableRawPointer(mutating: UnsafePointer<Subject>.null)
        } else {
            // FIXME: We should use a more safer call. eg. swift_modifyAtWritableKeyPath
            _start = UnsafeMutableRawPointer(base.baseAddress!.pointer(to: keyPath)!)
        }
        endIndex = base.count
    }

    package subscript(i: Int) -> Subject {
        @_transparent
        unsafeAddress {
            UnsafeRawPointer(_start)
                .advanced(by: MemoryLayout<Scene>.stride * i)
                .assumingMemoryBound(to: Subject.self)
        }
        @_transparent
        nonmutating unsafeMutableAddress {
            _start
                .advanced(by: MemoryLayout<Scene>.stride * i)
                .assumingMemoryBound(to: Subject.self)
        }
    }

    package typealias Element = Subject
}
