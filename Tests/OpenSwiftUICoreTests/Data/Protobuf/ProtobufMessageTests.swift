//
//  ProtobufMessageTests.swift
//  OpenSwiftUICoreTests

import OpenSwiftUICore
import Testing

struct ProtobufMessageTests {
    struct IntMessage: ProtobufMessage {
        init(value: Int) {
            self.value = value
        }
        
        init(from decoder: inout ProtobufDecoder) throws {
            fatalError("TODO")
        }
        
        func encode(to encoder: inout ProtobufEncoder) throws {
            fatalError("TODO")
        }
        
        var value: Int
    }
    
    @Test
    func message() {
        _ = IntMessage(value: 3)
    }
}
