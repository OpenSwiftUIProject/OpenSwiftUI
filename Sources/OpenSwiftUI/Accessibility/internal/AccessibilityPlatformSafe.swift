//
//  AccessibilityPlatformSafe.swift
//  OpenSwiftUI
//
//  Audited for RELEASE_2021
//  Status: Complete

import Foundation

protocol AccessibilityPlatformSafe {}

extension String: AccessibilityPlatformSafe {}
extension Double: AccessibilityPlatformSafe {}
extension Int: AccessibilityPlatformSafe {}
extension UInt: AccessibilityPlatformSafe {}
extension UInt8: AccessibilityPlatformSafe {}
extension Bool: AccessibilityPlatformSafe {}
extension NSNumber: AccessibilityPlatformSafe {}
extension Optional: AccessibilityPlatformSafe where Wrapped: AccessibilityPlatformSafe {}
