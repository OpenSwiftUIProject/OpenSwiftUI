//
//  FontNonDarwinShims.swift
//  OpenSwiftUICore

#if !canImport(CoreText)
public import Foundation

// Placeholder for CoreText when not available.
public class CTFontDescriptor: NSObject {}

public class CTFont: NSObject {}

#endif
