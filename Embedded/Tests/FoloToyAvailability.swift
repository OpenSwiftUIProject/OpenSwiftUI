//
//  FoloToyAvailability.swift
//  OpenSwiftUIEmbeddedTests

import OpenSwiftUI

// Scripts/test_embedded.sh requires all three APIs to be absent in generic
// builds and requires this same client to typecheck in FoloToy builds.
func buttonType() -> PhysicalButton { .select }

func buttonModifier() {
    _ = Color.red.onPhyicButton(.select) {}
}

func buttonDispatch() {
    let host = EmbeddedViewHost { Color.red }
    _ = host.send(.select)
}
