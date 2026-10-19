//
//  PlatformImage.swift
//  OpenSwiftUI

#if !os(Android) && canImport(UIKit)
typealias PlatformImage = UIImage
#elseif canImport(AppKit)
typealias PlatformImage = NSImage
#else
import Foundation
typealias PlatformImage = NSObject
#endif
