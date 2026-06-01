//
//  SafelySerializableDiscreteFormatStyle.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: WIP
//  ID: 6E7304511B702F2103288779936F04AA (SwiftUICore)

import Foundation

protocol SafelySerializableDiscreteFormatStyle: DiscreteFormatStyle where FormatOutput: AttributedStringConvertible {
    static func representation<Source>(
        of resolvable: TimeDataFormatting.Resolvable<Source, Self>,
        for version: ArchivedViewInput.DeploymentVersion
    ) -> any ResolvableStringAttributeRepresentation
        where Source: TimeDataSourceStorage, Source.Value == FormatInput
}

// TODO: Conformance
