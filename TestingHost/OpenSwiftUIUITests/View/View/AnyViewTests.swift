//
//  AnyViewTests.swift
//  OpenSwiftUIUITests

import XCTest

#if OPENSWIFTUI
import OpenSwiftUI
#else
import SwiftUI
#endif

#if os(iOS)
import UIKit

#if !OPENSWIFTUI
@available(iOS 15, *)
#endif
final class AnyViewTests: XCTestCase {
}
#endif
