//
//  protocol ContentTransitionProvidingFormatStyle.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: WIP (Blocked by SystemFormatStyle)

package import Foundation

package protocol ContentTransitionProvidingFormatStyle<FormatInput>: FormatStyle {
    func contentTransition<Source>(
        for source: Source
    ) -> ContentTransition where Source: TimeDataSourceStorage, Source.Value == FormatInput
}
