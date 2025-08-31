//
//  ObservationUtilTests.swift
//  OpenSwiftUICoreTests
//

import Testing
import OpenAttributeGraphShims
@_spi(OpenSwiftUI)
import OpenObservation
@_spi(ForOpenSwiftUIOnly)
import OpenSwiftUICore

@Suite("ObservationUtil Tests")
struct ObservationUtilTests {
    
    @Observable
    final class TestModel {
        var value: Int = 0
        var text: String = ""
    }
    
    @Test("_withObservation tracks property access")
    func withObservationTracking() {
        let model = TestModel()
        
        // Test that we can track observation access
        let (result, accessList) = _withObservation {
            // Access the model's properties
            let _ = model.value
            let _ = model.text
            return model.value + 10
        }
        
        // Verify the result
        #expect(result == 10)
        
        // Verify that an access list was created
        #expect(accessList != nil)
    }

    @MainActor
    @Test(
        "_withObservation with attribute installation",
        .disabled("retain a invalid ptr and cause crash. Investigate it later.") // TODO
    )
    func withObservationAttribute() {
        let model = TestModel()
        let viewGraph = ViewGraph(rootViewType: EmptyView.self)
        viewGraph.rootSubgraph.apply {
            let attribute = Attribute(value: 0)

            // Use _withObservation with an attribute
            let result = _withObservation(attribute: attribute) {
                // Access the model's properties
                let sum = model.value + 5
                return sum
            }

            #expect(result == 5)
        }
    }
    
    @Test("Nested observation contexts")
    func nestedObservationContexts() {
        let model1 = TestModel()
        let model2 = TestModel()
        
        model1.value = 10
        model2.value = 20
        
        let (outerResult, outerAccessList) = _withObservation {
            let val1 = model1.value
            
            // Nested observation context
            let (innerResult, innerAccessList) = _withObservation {
                let val2 = model2.value
                return val2 * 2
            }
            
            #expect(innerResult == 40)
            #expect(innerAccessList != nil)

            return val1 + innerResult
        }
        
        #expect(outerResult == 50)
        #expect(outerAccessList != nil)
    }
    
    @Test("ObservationRegistrar latestAccessLists tracking")
    func latestAccessListsTracking() {
        let model = TestModel()
        
        // Clear any previous access lists
        ObservationRegistrar.latestAccessLists = []
        
        let (_, accessList) = _withObservation {
            let _ = model.value
            return "test"
        }
        
        // Verify that an access list was created and recorded
        #expect(accessList != nil)
        #expect(!ObservationRegistrar.latestAccessLists.isEmpty)
    }
}
