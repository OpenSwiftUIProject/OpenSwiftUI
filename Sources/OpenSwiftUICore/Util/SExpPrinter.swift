//
//  SExpPrinter.swift
//  OpenSwiftUICore
//
//  Audited for iOS 18.0
//  Status: Complete

package struct SExpPrinter {
    var output: String
    var depth: Int
    package internal(set) var indent: String
    
    package init(tag: String, singleLine: Bool = false) {
        output = "(\(tag)"
        depth = singleLine ? 0 : 1
        indent = singleLine ? "" : "  "
    }
    
    package mutating func end() -> String {
        pop()
        return output
    }
    
    package mutating func print(_ string: String, newline: Bool = true) {
        if newline, depth != 0 {
            output.append("\n\(indent)")
        } else {
            output.append(" ")
        }
        output.append(string)
    }
    
    package mutating func newline() {
        guard depth != 0 else {
            return
        }
        output.append("\n")
        output.append(indent)
    }
    
    package mutating func push(_ tag: String) {
        if depth == 0 {
            output.append("(\(tag)")
        } else {
            output.append("\n\(indent)(\(tag)")
            depth += 1
            indent.append("  ")
        }
    }
    
    package mutating func pop() {
        if depth != 0 {
            depth -= 1
            indent.removeLast(2)
        }
        output.append(")")
    }
}
