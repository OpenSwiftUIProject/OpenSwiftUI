//
//  Shader.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: WIP

package import Foundation
package import OpenCoreGraphicsShims
// package import OpenRenderBoxShims

// MARK: - Shader [TODO]

public struct Shader {

    // MARK: - Shader.Options

    package struct Options: OptionSet {
        package let rawValue: UInt32

        package init(rawValue: UInt32) {
            self.rawValue = rawValue
        }

        package static let dithersColor: Options = .init(rawValue: 1 << 0)

        package static let colorFilter: Options = .init(rawValue: 1 << 1)

        package static let distortionFilter: Options = .init(rawValue: 1 << 2)

        package static let alphaOnlyLayer: Options = .init(rawValue: 1 << 3)
    }

    // MARK: - Shader.ResolvedShader

    package struct ResolvedShader: Equatable {
        package var rbShader: ORBShader?

        package var maxSampleOffset: CGSize

        package var options: Options

        package init(
            rbShader: ORBShader? = nil,
            maxSampleOffset: CGSize,
            options: Shader.Options
        ) {
            self.rbShader = rbShader
            self.maxSampleOffset = maxSampleOffset
            self.options = options
        }
    }
}

// MARK: - Shader.ResolvedShader + ProtobufMessage [TBA]

extension Shader.ResolvedShader: ProtobufMessage {
    package func encode(to encoder: inout ProtobufEncoder) throws {
        if rbShader != nil {
            // TODO: Encode the RenderBox shader through its archive delegate.
            _openSwiftUIUnimplementedFailure()
        }
        try encoder.messageField(2, maxSampleOffset, defaultValue: .zero)
        encoder.uintField(3, UInt(options.rawValue))
    }

    package init(from decoder: inout ProtobufDecoder) throws {
        self.init(maxSampleOffset: .zero, options: [])
        while let field = try decoder.nextField() {
            switch field.tag {
            case 1:
                // TODO: Decode the RenderBox shader through its archive delegate.
                _openSwiftUIUnimplementedFailure()
            case 2: maxSampleOffset = try decoder.messageField(field)
            case 3: options = .init(rawValue: try decoder.uint32Field(field))
            default: try decoder.skipField(field)
            }
        }
    }
}

// FIXME: RB
package class ORBShader: NSObject {}
