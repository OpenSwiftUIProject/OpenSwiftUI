//
//  FontNonDarwinShims.swift
//  OpenSwiftUICore

#if !canImport(CoreText)
public import Foundation

// Placeholder for CoreText when not available.
public class CTFontDescriptor: CFCompatObject {}

public class CTFont: CFCompatObject {}

#endif
