//
//  DisplayList+String.swift
//  OpenSwiftUICore
//
//  Audited for iOS 18.0
//  Status: WIP
//  ID: 11125C146A81D1913BFBD53B89D010C6

extension DisplayList.Item {
    // TODO
    var features: DisplayList.Features { [] }
    var properties: DisplayList.Properties { [] }
    
    fileprivate func print(into printer: inout SExpPrinter) {
        printer.push("item")
        if identity.value != .zero {
            printer.print("#:identity \(identity.value)", newline: false)
        }
        printer.print("#:version \(version.value)", newline: false)
        if features.contains(.required) {
            printer.print("#:required true", newline: false)
        }
        if features.contains(.views) {
            printer.print("#:views true", newline: false)
        }
        printer.print("(frame (\(position.x) \(position.y); \(size.width) \(size.height)))")
        switch value {
        case .empty:
            break
        case let .content(content):
            printer.print("(content-seed \(content.seed.value))")
            switch content.value {
            case let .placeholder(id: identity):
                printer.print("(placeholder \(identity))")
            default:
                // TOOD
                break
            }
        default:
            // TODO
            break
        }
        printer.pop()
    }
    
    fileprivate func printMinimally(into printer: inout SExpPrinter) {
        printer.push("I:\(identity.value)")
        switch value {
        case .empty:
            break
        case let .content(content):
            switch content.value {
            case let .placeholder(id: identity):
                printer.print("@\(identity))")
            default:
                // TOOD
                break
            }
        default:
            // TODO
            break
        }
        printer.pop()
    }
}


extension DisplayList: CustomStringConvertible {
    public var description: String {
        var printer = SExpPrinter(tag: "display-list", singleLine: false)
        for item in items {
            item.print(into: &printer)
        }
        return printer.end()
    }

    package var minimalDescription: String {
        var printer = SExpPrinter(tag: "DL", singleLine: true)
        for item in items {
            item.printMinimally(into: &printer)
        }
        return printer.end()
    }
}
extension DisplayList.Item: CustomStringConvertible {
    package var description: String {
        var printer = SExpPrinter(tag: "display-list-item", singleLine: false)
        print(into: &printer)
        return printer.end()
    }
}
