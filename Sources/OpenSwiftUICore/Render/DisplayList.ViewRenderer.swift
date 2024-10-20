//
//  DisplayList.ViewRenderer.swift
//  OpenSwiftUICore
//
//  Audited for RELEASE_2024
//  Status: WIP

import Foundation

@_spi(ForOpenSwiftUIOnly)
extension DisplayList {
    final public class ViewRenderer {
        package struct Environment: Equatable {
            package var contentScale: CGFloat
            package static let invalid = Environment(contentScale: .zero)
            
            package init(contentScale: CGFloat) {
                self.contentScale = contentScale
            }
        }
    }
}
