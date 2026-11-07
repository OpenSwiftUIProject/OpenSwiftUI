//
//  BackdropEffect.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete

// MARK: - BackdropEffect

package struct BackdropEffect: Equatable {
    package var scale: Float

    package var color: Color.Resolved

    package var filters: [GraphicsFilter]

    #if os(visionOS)
    package var captureOnly: Bool
    #endif

    package init(
        scale: Float = 1,
        color: Color.Resolved = .black,
        filters: [GraphicsFilter] = [],
        captureOnly: Bool = false
    ) {
        self.scale = scale
        self.color = color
        self.filters = filters
        #if os(visionOS)
        self.captureOnly = captureOnly
        #endif
    }
}

extension BackdropEffect: ProtobufMessage {
    package func encode(to encoder: inout ProtobufEncoder) throws {
        encoder.floatField(1, scale)
        try encoder.messageField(2, color)
        for filter in filters {
            try encoder.messageField(3, filter)
        }
        #if os(visionOS)
        encoder.boolField(4, captureOnly)
        #endif
    }

    package init(from decoder: inout ProtobufDecoder) throws {
        self.init()
        while let field = try decoder.nextField() {
            switch field.tag {
            case 1: scale = try decoder.floatField(field)
            case 2: color = try decoder.messageField(field)
            case 3: filters.append(try decoder.messageField(field))
            #if os(visionOS)
            case 4: captureOnly = try decoder.boolField(field)
            #endif
            default: try decoder.skipField(field)
            }
        }
    }
}

// MARK: - BackdropView

struct BackdropView: RendererLeafView {
    nonisolated static func _makeView(
        view: _GraphValue<BackdropView>,
        inputs: _ViewInputs
    ) -> _ViewOutputs {
        makeLeafView(view: view, inputs: inputs)
    }

    func content() -> DisplayList.Content.Value {
        .backdrop(BackdropEffect(color: .clear))
    }
}
