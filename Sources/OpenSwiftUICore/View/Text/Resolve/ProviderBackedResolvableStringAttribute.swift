//
//  ProviderBackedResolvableStringAttribute.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete

#if canImport(Darwin)

import OpenSwiftUI_SPI

protocol ProviderBackedResolvableStringAttribute: ConfigurationBasedResolvableStringAttribute {
    var provider: BaseDateProvider? { get }
}

//extension ProviderBackedResolvableStringAttribute {
//    var invalidationConfiguration: ResolvableAttributeConfiguration {
//        provider?.updateConfiguration ?? .none
//    }
//}

extension BaseDateProvider {
    var updateConfiguration: ResolvableAttributeConfiguration {
        let updateType = updateType
        switch updateType {
        case 0:
            return .interval(delay: updateInterval()?.doubleValue)
        case 1:
            let alignment = updateWallClockAlignment
            guard !alignment.isEmpty else {
                Log.internalError("No wall clock alignment provided")
                return .none
            }
            return .wallClock(alignment: alignment)
        case 2:
            guard let timerEndDate else {
                Log.internalError("No timer end provided")
                return .none
            }
            return .timer(end: timerEndDate)
        case 3, 4:
            guard let timerInterval else {
                Log.internalError("No timer interval provided")
                return .none
            }
            return .timerInterval(interval: timerInterval, countdown: updateType == 3)
        default:
            return .none
        }
    }
}
#endif
