//
//  Foundation+ProtobufMessage.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: WIP
//  Note: Data archiveWriter/archiveReader deduplication not yet implemented

package import Foundation

// MARK: - URL + ProtobufMessage

extension URL: ProtobufMessage {
    package func encode(to encoder: inout ProtobufEncoder) throws {
        try encoder.stringField(1, relativeString)
        if let baseURL {
            try encoder.messageField(2, baseURL)
        }
    }

    package init(from decoder: inout ProtobufDecoder) throws {
        var relativeString = ""
        var baseURL: URL? = nil
        while let field = try decoder.nextField() {
            switch field.tag {
            case 1: relativeString = try decoder.stringField(field)
            case 2: baseURL = try decoder.messageField(field)
            default: try decoder.skipField(field)
            }
        }
        guard let url = URL(string: relativeString, relativeTo: baseURL) else {
            throw ProtobufDecoder.DecodingError.failed
        }
        self = url
    }
}

// MARK: - UUID + ProtobufMessage

extension UUID: ProtobufMessage {
    package func encode(to encoder: inout ProtobufEncoder) throws {
        withUnsafeBytes(of: uuid) { buffer in
            encoder.dataField(1, buffer)
        }
    }

    package init(from decoder: inout ProtobufDecoder) throws {
        var uuidBytes: uuid_t = (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
        while let field = try decoder.nextField() {
            switch field.tag {
            case 1:
                let buffer = try decoder.dataBufferField(field)
                guard buffer.count == 16, let src = buffer.baseAddress else {
                    throw ProtobufDecoder.DecodingError.failed
                }
                withUnsafeMutableBytes(of: &uuidBytes) { $0.baseAddress!.copyMemory(from: src, byteCount: 16) }
            default:
                try decoder.skipField(field)
            }
        }
        self = UUID(uuid: uuidBytes)
    }
}

// MARK: - Data + ProtobufMessage [WIP]

extension Data: ProtobufMessage {
    package func encode(to encoder: inout ProtobufEncoder) throws {
        if /*let archiveWriter*/ false {
            // TODO
            _openSwiftUIUnreachableCode()
        } else {
            encoder.dataField(2, self)
        }
    }

    package init(from decoder: inout ProtobufDecoder) throws {
        self = Data()
        while let field = try decoder.nextField() {
            switch field.tag {
            case 2:
                self = try decoder.dataField(field)
            default:
                try decoder.skipField(field)
            }
        }
    }
}

// MARK: - Locale + ProtobufMessage

extension Locale: ProtobufMessage {
    package func encode(to encoder: inout ProtobufEncoder) throws {
        try encoder.stringField(1, identifier)
    }

    package init(from decoder: inout ProtobufDecoder) throws {
        var identifier = ""
        while let field = try decoder.nextField() {
            switch field.tag {
            case 1: identifier = try decoder.stringField(field)
            default: try decoder.skipField(field)
            }
        }
        self = Locale(identifier: identifier)
    }
}
