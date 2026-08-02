//
//  Shader.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Empty

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

    package struct ResolvedShader {
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

// FIXME: RB
package class ORBShader {}
