//
//  CAFrameRateRangeUtil.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete

#if os(iOS) && canImport(QuartzCore)
import QuartzCore

extension CAFrameRateRange {
    package init(interval: Double) {
        guard interval != 0 else {
            self = .default
            return
        }
        let frameRate = round(1.0 / Float(interval))
        if frameRate <= 40.0 {
            self.init(minimum: frameRate, maximum: 60.0, preferred: frameRate)
        } else if frameRate < 80.0 {
            self = .default
        } else {
            self.init(minimum: 80.0, maximum: frameRate, preferred: frameRate)
        }
    }
}
#endif
