//
//  PlatformImage.swift
//  OpenSwiftUI

#if canImport(UIKit)
typealias PlatformImage = UIImage
#elseif canImport(AppKit)
typealias PlatformImage = NSImage
#else
import Foundation
typealias PlatformImage = NSObject
#endif
