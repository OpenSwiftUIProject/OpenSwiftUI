//
//  Collection+ExtensionTests.swift
//  OpenSwiftUICoreTests

import Testing
@testable import OpenSwiftUICore

// MARK: - Collection Extension Tests

struct Collection_ExtensionTests {

    // MARK: - Index Extension Tests
    
    @Test
    func indexAtOffset() {
        let string = "Hello"
        let index = string.index(atOffset: 2)
        
        #expect(string[index] == "l")
    }
    
    @Test
    func indexAtOffsetLimited() {
        let string = "Hello"
        let limitIndex = string.index(string.startIndex, offsetBy: 3)
        let result = string.index(atOffset: 5, limitedBy: limitIndex)
        
        #expect(result == nil)
    }
    
    @Test
    func offsetOfIndex() {
        let string = "Hello"
        let index = string.index(string.startIndex, offsetBy: 2)
        let offset = string.offset(of: index)
        
        #expect(offset == 2)
    }
    
    @Test
    func safeSubscriptValid() {
        let string = "Hello"
        let index = string.index(string.startIndex, offsetBy: 1)
        let result = string[safe: index]
        
        #expect(result == "e")
    }
    
    @Test
    func safeSubscriptInvalid() {
        let string = "Hello"
        let result = string[safe: string.endIndex]
        
        #expect(result == nil)
    }
    
    // MARK: - Common Prefix Tests
    
    @Test
    func commonPrefixIdenticalStrings() {
        let str1 = "hello"
        let str2 = "hello"
        let (prefix1, prefix2) = str1.commonPrefix(with: str2)
        
        #expect(String(prefix1) == "hello")
        #expect(String(prefix2) == "hello")
    }
    
    @Test
    func commonPrefixPartialMatch() {
        let str1 = "hello world"
        let str2 = "hello swift"
        let (prefix1, prefix2) = str1.commonPrefix(with: str2)
        
        #expect(String(prefix1) == "hello ")
        #expect(String(prefix2) == "hello ")
    }
    
    @Test
    func commonPrefixNoMatch() {
        let str1 = "apple"
        let str2 = "banana"
        let (prefix1, prefix2) = str1.commonPrefix(with: str2)
        
        #expect(String(prefix1) == "")
        #expect(String(prefix2) == "")
    }
    
    @Test
    func commonPrefixEmptyStrings() {
        let str1 = ""
        let str2 = ""
        let (prefix1, prefix2) = str1.commonPrefix(with: str2)
        
        #expect(String(prefix1) == "")
        #expect(String(prefix2) == "")
    }
    
    @Test
    func commonPrefixOneEmpty() {
        let str1 = "hello"
        let str2 = ""
        let (prefix1, prefix2) = str1.commonPrefix(with: str2)
        
        #expect(String(prefix1) == "")
        #expect(String(prefix2) == "")
    }
    
    @Test
    func commonPrefixDifferentLengths() {
        let str1 = "test"
        let str2 = "testing"
        let (prefix1, prefix2) = str1.commonPrefix(with: str2)
        
        #expect(String(prefix1) == "test")
        #expect(String(prefix2) == "test")
    }
    
    // MARK: - Common Suffix Tests
    
    @Test
    func commonSuffixIdenticalStrings() {
        let str1 = "hello"
        let str2 = "hello"
        let (suffix1, suffix2) = str1.commonSuffix(with: str2)
        
        #expect(String(suffix1) == "hello")
        #expect(String(suffix2) == "hello")
    }
    
    @Test
    func commonSuffixPartialMatch() {
        let str1 = "world hello"
        let str2 = "swift hello"
        let (suffix1, suffix2) = str1.commonSuffix(with: str2)
        
        #expect(String(suffix1) == " hello")
        #expect(String(suffix2) == " hello")
    }
    
    @Test
    func commonSuffixNoMatch() {
        let str1 = "apple"
        let str2 = "banana"
        let (suffix1, suffix2) = str1.commonSuffix(with: str2)
        
        #expect(String(suffix1) == "")
        #expect(String(suffix2) == "")
    }
    
    @Test
    func commonSuffixEmptyStrings() {
        let str1 = ""
        let str2 = ""
        let (suffix1, suffix2) = str1.commonSuffix(with: str2)
        
        #expect(String(suffix1) == "")
        #expect(String(suffix2) == "")
    }
    
    @Test
    func commonSuffixOneEmpty() {
        let str1 = "hello"
        let str2 = ""
        let (suffix1, suffix2) = str1.commonSuffix(with: str2)
        
        #expect(String(suffix1) == "")
        #expect(String(suffix2) == "")
    }
    
    @Test
    func commonSuffixDifferentLengths() {
        let str1 = "testing"
        let str2 = "ing"
        let (suffix1, suffix2) = str1.commonSuffix(with: str2)
        
        #expect(String(suffix1) == "ing")
        #expect(String(suffix2) == "ing")
    }
    
    @Test
    func commonSuffixComplexCase() {
        let str1 = "filename.txt"
        let str2 = "document.txt"
        let (suffix1, suffix2) = str1.commonSuffix(with: str2)
        
        #expect(String(suffix1) == ".txt")
        #expect(String(suffix2) == ".txt")
    }
}
