//
//  PlatformImage.swift
//  OpenSwiftUI

#if !os(Android) && canImport(UIKit)
import UIKit
typealias PlatformImage = UIImage
#elseif canImport(AppKit)
import AppKit
typealias PlatformImage = NSImage
#else
import Foundation
typealias PlatformImage = NSObject
#endif
