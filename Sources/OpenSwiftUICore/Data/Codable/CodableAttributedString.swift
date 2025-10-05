//
//  CodableAttributedString.swift
//  OpenSwiftUICore
//
//  Status: WIP

package import class Foundation.NSAttributedString
package import struct Foundation.NSRange

package struct CodableAttributedString {
    package struct Range {
        package var extent: NSRange
        package var attributes: [NSAttributedString.Key: Any]
    }

    package var base: NSAttributedString

    package init(_ base: NSAttributedString) {
        self.base = base
    }
}

extension CodableAttributedString: ProtobufMessage {
    package func encode(to encoder: inout ProtobufEncoder) throws {
        _openSwiftUIUnimplementedFailure()
    }

    package init(from decoder: inout ProtobufDecoder) throws {
        _openSwiftUIUnimplementedFailure()
    }
}

extension CodableAttributedString.Range: ProtobufMessage {
    package func encode(to encoder: inout ProtobufEncoder) throws {
        _openSwiftUIUnimplementedFailure()
    }

    package init(from decoder: inout ProtobufDecoder) throws {
        _openSwiftUIUnimplementedFailure()
    }
}
