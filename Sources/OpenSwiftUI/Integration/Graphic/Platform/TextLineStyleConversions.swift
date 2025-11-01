//
//  TextLineStyleConversions.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete

public import OpenSwiftUI_SPI

@available(OpenSwiftUI_v3_0, *)
extension Text.LineStyle {

    /// Creates a ``Text.LineStyle`` from ``NSUnderlineStyle``.
    ///
    /// > Note: Use this initializer only if you need to convert an existing
    /// ``NSUnderlineStyle`` to a OpenSwiftUI ``Text.LineStyle``.
    /// Otherwise, create a ``Text.LineStyle`` using an
    /// initializer like ``init(pattern:color:)``.
    ///
    /// - Parameter nsUnderlineStyle: A value of ``NSUnderlineStyle``
    /// to wrap with ``Text.LineStyle``.
    ///
    /// - Returns: A new ``Text.LineStyle`` or `nil` when
    /// `nsUnderlineStyle` contains styles not supported by ``Text.LineStyle``.
    public init?(nsUnderlineStyle: NSUnderlineStyle) {
        self.init(_nsUnderlineStyle: nsUnderlineStyle)
    }
}

@available(OpenSwiftUI_v3_0, *)
extension NSUnderlineStyle {

    /// Creates a ``NSUnderlineStyle`` from ``Text.LineStyle``.
    ///
    /// - Parameter lineStyle: A value of ``Text.LineStyle``
    /// to wrap with ``NSUnderlineStyle``.
    ///
    /// - Returns: A new ``NSUnderlineStyle``.
    public init(_ lineStyle: Text.LineStyle) {
        self = lineStyle.nsUnderlineStyle
    }
}
