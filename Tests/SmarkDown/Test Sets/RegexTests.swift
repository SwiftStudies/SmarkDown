//
//  InternalTests.swift
//  SmarkDown
//
//  Copyright © 2016 Swift Studies. All rights reserved.
//

import XCTest
import Foundation
@testable import SmarkDown

class InternalTests: XCTestCase {
	    
    func testSubstringWithNSRange(){
        
        func doTest(text:String,range:NSRange,expected:String){
            let result = text.substringWithNSRange(range)
            XCTAssert(result == expected, "Expected '\(expected)' but got '\(result)'")
            
            let nsStringVersion = NSString(string:text)
            let nsStringResult = String(nsStringVersion.substringWithRange(range))
            XCTAssert(nsStringResult == result, "NSString with NSRange returned \(nsStringResult) which is different to \(result) ")
        }
        
        let testString = "Hello World"

        doTest(testString, range: NSRange(location:0, length:1), expected: "H")
        doTest(testString, range: NSRange(location:0, length:5), expected: "Hello")
        doTest(testString, range: NSRange(location:6, length:5), expected: "World")
    }

    func testRegexSubstitution(){
        let after = regexSub("hello",pattern: "hello", template:"world")
        
        XCTAssert(
            regexSub("hello",pattern: "hello", template:"world")=="world",
            "Substituion not performed \(after)")
        
        XCTAssert(
            regexSub("\r\n", pattern: "\\r\\n", template: "\n") == "\n"
            , "Sub not done correctly"
        )
    }
    
    func testReplacePatternMatchesWithBlock(){
        func doTest(text:String, pattern:String, expected:String,block:RegexMatchReplaceBlock){
            let result = replacePatternMatchesWithBlock(text, pattern: pattern, block: block)
            
            XCTAssert(expected == result , "Expected '\(expected)' but got '\(result)'")
        }
        
        func inertTemplate(match:RegexMatchResult)->String{
            return match.match
        }
        
        doTest("Hello World", pattern: "kdjfkdlj", expected: "Hello World"){(match)->String in return match.match}
        doTest("Hello World", pattern: "Hello", expected:"Goodbye World"){
            (match)->String in
            return "Goodbye"
        }
        doTest("Hello Cruel World", pattern: "Cruel", expected:"Hello Wonderful World"){
            (match)->String in
            return "Wonderful"
        }
    }
    
    func doItalicsAndBold(input:String)->String{
        return SmarkDown().doItalicsAndBold(input)
    }
    
    func testEmphasis() {
        let input       = "*hello*"
        let expected    = "<em>hello</em>"
        let result      = doItalicsAndBold(input)
        
        XCTAssert(result == expected, "Failed for '\(input.exposedWhiteSpace)':\n'\(expected.exposedWhiteSpace)' but got \n'\(result.exposedWhiteSpace)'")
    }
    
    func testBold() {
        let input       = "**hello**"
        let expected    = "<strong>hello</strong>"
        let result      = doItalicsAndBold(input)
        
        XCTAssert(result == expected, "Failed for '\(input.exposedWhiteSpace)':\n'\(expected.exposedWhiteSpace)' but got \n'\(result.exposedWhiteSpace)'")
    }
    
    func testBoldAndEmphasis(){
        var input       = "***hello***"
        let expected    = "<strong><em>hello</em></strong>"
        let result      = doItalicsAndBold(input)
        
        XCTAssert(result == expected, "Failed for '\(input.exposedWhiteSpace)':\n'\(expected.exposedWhiteSpace)' but got \n'\(result.exposedWhiteSpace)'")
        input       = "___hello___"
        XCTAssert(result == expected, "Failed for '\(input.exposedWhiteSpace)':\n'\(expected.exposedWhiteSpace)' but got \n'\(result.exposedWhiteSpace)'")
        input       = "____hello____"
        XCTAssert(result == expected, "Failed for '\(input.exposedWhiteSpace)':\n'\(expected.exposedWhiteSpace)' but got \n'\(result.exposedWhiteSpace)'")
    }
    
    func doBlockQuotes(input:String)->String{
        return SmarkDown().doBlockQuotes(input)
    }
    
    
    func testBlockQuotes(){
        let input       = "> foo\n> foo\n"
        let expected    = "<blockquote>\n  <p>foo\n  foo</p>\n</blockquote>\n"
        let result      = input.markdown
        
        XCTAssert(result == expected, "Failed for '\(input.exposedWhiteSpace)':\n'\(expected.exposedWhiteSpace)' but got \n'\(result.exposedWhiteSpace)'")
    }
    
    func testHorizontalRule(){
        let inputs      = ["---"," ---","  ---","----","***","****","******","********","  *********"]
        let expected    = "<hr />\n"
        
        for input in inputs {
            let result = (input+"\n").markdown
            XCTAssert(result == expected, "Failed for '\(input.exposedWhiteSpace)':\n'\(expected.exposedWhiteSpace)' but got \n'\(result.exposedWhiteSpace)'")
        }
        
    }
    
    func testAutoLinks(){
        
        var failures = [String:(expected:String,actual:String)]()
        
        let inputs = [
            "<http://www.google.com/>" : "<a href=\"http://www.google.com/\">http://www.google.com/</a>", //Auto-link
            "<http://www.google.com/>  \nNext Line\n" : "<a href=\"http://www.google.com/\">http://www.google.com/</a> <br />\nNext Line",
        ]
        
        for (input,expected) in inputs {
            let result      = input.markdown
            let expected    = "<p>\(expected)</p>\n"

            if result != expected {
                failures[input] = (expected,result)
            }
            
//            XCTAssert(result == expected, "Failed for '\(input.exposedWhiteSpace)':\n'\(expected.exposedWhiteSpace)' but got \n'\(result.exposedWhiteSpace)'")
        }
        
        var resultsSummary = ""
        for (input,results) in failures {
            resultsSummary += "Failed for '\(input.exposedWhiteSpace)':\n'\(results.expected.exposedWhiteSpace)' but got \n'\(results.actual.exposedWhiteSpace)'\n"
        }
        
        XCTAssert(failures.count == 0, "Failed for \(failures.count) out of \(inputs.count) cases:\n\(resultsSummary)")
    }
    
    func testReferenceLinkWithTitle(){
        let inputs = [
            "[Link][link-id]\n\n[link-id]: http://example.com/ \"title\"" : "<a href=\"http://example.com/\" title=\"title\">Link</a>", //Reference with title
        ]
        
        let smarkDown = SmarkDown()
        
        for (input,expected) in inputs {
            let result      = smarkDown.markdown(input)
            let expected    = "<p>\(expected)</p>\n"
            
            XCTAssert(smarkDown.titleForId("link-id") == "title","Incorrectly built title hash")
            XCTAssert(smarkDown.urlForId("link-id") == "http://example.com/", "URL hash not correct")
            
            
            XCTAssert(result == expected, "Failed for '\(input.exposedWhiteSpace)':\n'\(expected.exposedWhiteSpace)' but got \n'\(result.exposedWhiteSpace)'")
        }
    }
    
    
    func testReferenceLink(){
        let inputs = [
            "[Link][link-id]\n\n[link-id]: http://example.com/" : "<a href=\"http://example.com/\">Link</a>", //Reference
        ]
        
        let smarkDown = SmarkDown()
        
        
        for (input,expected) in inputs {
            let result      = smarkDown.markdown(input)
            let expected    = "<p>\(expected)</p>\n"
            
            XCTAssert(smarkDown.titleForId("link-id") == nil,"Incorrectly built title hash")
            XCTAssert(smarkDown.urlForId("link-id") == "http://example.com/", "URL hash not correct")
            
            XCTAssert(result == expected, "Failed for '\(input.exposedWhiteSpace)':\n'\(expected.exposedWhiteSpace)' but got \n'\(result.exposedWhiteSpace)'")
        }
    }
    
    
    func testInlineLinkWithTitle(){
        let inputs = [
            "[This link](http://example.net \"title\")" : "<a href=\"http://example.net\" title=\"title\">This link</a>",               //Inline with title
        ]
        
        for (input,expected) in inputs {
            let result      = input.markdown
            let expected    = "<p>\(expected)</p>\n"
            
            XCTAssert(result == expected, "Failed for '\(input.exposedWhiteSpace)':\n'\(expected.exposedWhiteSpace)' but got \n'\(result.exposedWhiteSpace)'")
        }
    }
    
    
    func testInlineLink(){
        let inputs = [
            "[This link](http://example.net)" : "<a href=\"http://example.net\">This link</a>",                                         //Inline
        ]
        
        for (input,expected) in inputs {
            let result      = input.markdown
            let expected    = "<p>\(expected)</p>\n"
            
            XCTAssert(result == expected, "Failed for '\(input.exposedWhiteSpace)':\n'\(expected.exposedWhiteSpace)' but got \n'\(result.exposedWhiteSpace)'")
        }
    }
    
    func testBasic(){
        let input       = "hello"
        let expected    = "<p>hello</p>\n"
        let result      = input.markdown
        
        XCTAssert(result == expected, "Failed for '\(input.exposedWhiteSpace)':\n'\(expected.exposedWhiteSpace)' but got \n'\(result.exposedWhiteSpace)'")
    }
    
    func testInlineImage(){
        let input       = "![An Image](/someimage.jpg)"
        let expected    = "<p><img src=\"/someimage.jpg\" alt=\"An Image\" title=\"\" /></p>\n"
        let result      = input.markdown
        
        XCTAssert(result == expected, "Failed for '\(input.exposedWhiteSpace)':\n'\(expected.exposedWhiteSpace)' but got \n'\(result.exposedWhiteSpace)'")
    }

    func testInlineImageWithTitle(){
        let input       = "![An Image](/someimage.jpg 'title')"
        let expected    = "<p><img src=\"/someimage.jpg\" alt=\"An Image\" title=\"title\" /></p>\n"
        let result      = input.markdown
        
        XCTAssert(result == expected, "Failed for '\(input.exposedWhiteSpace)':\n'\(expected.exposedWhiteSpace)' but got \n'\(result.exposedWhiteSpace)'")
    }

    func testReferenceImage(){
        let smarkDown = SmarkDown()
        
        let input       = "![Alt text][image]\n\n[image]: /someimage.jpg"
        let expected    = "<p><img src=\"/someimage.jpg\" alt=\"Alt text\" /></p>\n"
        let result      = smarkDown.markdown(input)
        
        XCTAssert(smarkDown.titleForId("image") == nil,"Incorrectly built title hash")
        XCTAssert(smarkDown.urlForId("image") == "/someimage.jpg", "URL hash not correct")
        
        
        XCTAssert(result == expected, "Failed for '\(input.exposedWhiteSpace)':\n'\(expected.exposedWhiteSpace)' but got \n'\(result.exposedWhiteSpace)'")
    }

    func testReferenceImageWithTitle(){
        let smarkDown = SmarkDown()
        
        let input       = "![Alt text][image]\n\n[image]: /someimage.jpg \"title\""
        let expected    = "<p><img src=\"/someimage.jpg\" alt=\"Alt text\" title=\"title\" /></p>\n"
        let result      = smarkDown.markdown(input)

        XCTAssert(smarkDown.titleForId("image") == "title","Incorrectly built title hash")
        XCTAssert(smarkDown.urlForId("image") == "/someimage.jpg", "URL hash not correct")
        
        
        XCTAssert(result == expected, "Failed for '\(input.exposedWhiteSpace)':\n'\(expected.exposedWhiteSpace)' but got \n'\(result.exposedWhiteSpace)'")
    }
    

    func testCodeBlock(){
        let input       = "Here is an example of AppleScript:\n\n    tell application \"Foo\"\n        beep\n    end tell"
        let expected    = "<p>Here is an example of AppleScript:</p>\n\n<pre><code>tell application \"Foo\"\n    beep\nend tell\n</code></pre>\n"
        let result      = input.markdown
        
        XCTAssert(result == expected, "Failed for '\(input.exposedWhiteSpace)':\n'\(expected.exposedWhiteSpace)' but got \n'\(result.exposedWhiteSpace)'")
    }
    
    func testSimpleHeader(){
        let input       = "## Unordered\n\nResults"
        let expected    = "<h2>Unordered</h2>\n\n<p>Results</p>\n"
        let result      = input.markdown
        
        XCTAssert(result == expected, "Failed for '\(input.exposedWhiteSpace)':\n'\(expected.exposedWhiteSpace)' but got \n'\(result.exposedWhiteSpace)'")
    }
    
    func testMalformedHr(){
        let input       = "Hr's:\n\n<hr>\n"
        let expected    = "<p>Hr's:</p>\n\n<hr>\n"
        let result      = input.markdown
        
        XCTAssert(result == expected, "Failed for '\(input.exposedWhiteSpace)':\n'\(expected.exposedWhiteSpace)' but got \n'\(result.exposedWhiteSpace)'")
    }
}

#if os(Linux)
	extension InternalTests : XCTestCaseProvider {
	    var allTests : [(String, () throws -> Void)] {
        	return [
            		("testMalformedHr", testMalformedHr),
            		("testSimpleHeader", testSimpleHeader),
        		]
   	    }	
	}
#endif
