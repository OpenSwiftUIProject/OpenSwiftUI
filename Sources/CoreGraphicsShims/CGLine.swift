//
//  CGLine.swift
//  CoreGraphicsShims

#if !canImport(CoreGraphics)

/// Line join styles
public enum CGLineJoin: Int32, @unchecked Sendable {
    case miter = 0
    case round = 1
    case bevel = 2
}

/// Line cap styles
public enum CGLineCap : Int32, @unchecked Sendable {
    case butt = 0
    case round = 1
    case square = 2
}

#endif
