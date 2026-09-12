//
//  CurrentEventProvider.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete

#if os(iOS) || os(visionOS)
import UIKit

protocol CurrentEventProvider {
    var currentEvent: UIEvent? { get }
}
#endif
