//
//  SExpPrinterTests.swift
//  OpenSwiftUICoreTests

import OpenSwiftUICore
import OpenGraphShims
import Testing

struct SExpPrinterTests {
    @Test
    func singleLine() {
        var printer = SExpPrinter(tag: "(test", singleLine: true)
        printer.push("A")
        printer.push("B")
        printer.pop()
        printer.pop()
        let end = printer.end()
        #expect(end == "((test(A(B)))")
    }
    
    @Test
    func multiLine() {
        var printer = SExpPrinter(tag: "(test", singleLine: false)
        printer.push("A")
        printer.push("B")
        printer.pop()
        printer.pop()
        let end = printer.end()
        #expect(end == """
        ((test
          (A
            (B)))
        """)
    }
    
    @Test
    func newline() {
        var printer = SExpPrinter(tag: "(test", singleLine: false)
        printer.push("A")
        printer.newline()
        printer.push("B")
        printer.newline()
        printer.pop()
        printer.pop()
        let end = printer.end()
        #expect(end == """
        ((test
          (A
            
            (B
              )))
        """)
        printer.newline()
        let newEnd = printer.end()
        #expect(newEnd == """
        ((test
          (A
            
            (B
              ))))
        """)
    }
    
    @Test
    func printString() {
        do {
            var printer = SExpPrinter(tag: "(test", singleLine: false)
            printer.push("A")
            printer.print("B")
            printer.print("C")
            printer.pop()
            let end = printer.end()
            #expect(end == """
            ((test
              (A
                B
                C))
            """)
        }
        do {
            var printer = SExpPrinter(tag: "(test", singleLine: false)
            printer.push("A")
            printer.print("B")
            printer.pop()
            _ = printer.end()
            printer.print("C")
            let end = printer.end()
            #expect(end == """
            ((test
              (A
                B)) C)
            """)
        }
        do {
            var printer = SExpPrinter(tag: "(test", singleLine: true)
            printer.push("A")
            printer.print("B")
            printer.print("C")
            printer.pop()
            let end = printer.end()
            #expect(end == """
            ((test(A B C))
            """)
        }
        do {
            var printer = SExpPrinter(tag: "(test", singleLine: true)
            printer.push("A")
            printer.print("B")
            printer.pop()
            printer.print("C")
            let end = printer.end()
            #expect(end == """
            ((test(A B) C)
            """)
        }
    }
    
    @Test
    func pushPop() {
        var printer = SExpPrinter(tag: "(test", singleLine: false)
        printer.push("A")
        printer.push("B")
        printer.pop()
        printer.push("C")
        printer.pop()
        printer.pop()
        let end = printer.end()
        #expect(end == """
        ((test
          (A
            (B)
            (C)))
        """)
    }
}
