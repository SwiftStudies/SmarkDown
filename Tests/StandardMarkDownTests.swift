//
//  SmarkDownTests.swift
//  SmarkDownTests
//
//  Copyright © 2016 Swift Studies. All rights reserved.
//

import XCTest
@testable import SmarkDown

class SmarkDownTests: XCTestCase {
    
    var bundle : NSBundle {
        return NSBundle(forClass: self.dynamicType)
    }
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    
    func doFileTest(fileName:String){
        let bundle = NSBundle(forClass: self.dynamicType)
        
        let inputFileName = bundle.pathForResource(fileName, ofType: "text")!
        let outputFileName = bundle.pathForResource(fileName, ofType: "html")!
        
        do {
            let input = try NSString(contentsOfFile: inputFileName, encoding: NSUTF8StringEncoding) as String
            let expectedOutput = try NSString(contentsOfFile: outputFileName, encoding: NSUTF8StringEncoding) as String
            
            let result = input.markdown
                        
            XCTAssert(result == expectedOutput, "\(fileName) not correctly processed got:\n\(result)\n...but expected...\n\(expectedOutput)\nDone")
            
            
            
        } catch {
            XCTAssert(false, "Could not load \(fileName).(text|html)")
        }
    }
    
    func testAmpsAndEncoding(){
        doFileTest("Amps and angle encoding")
    }
    
    func testAutoLinks(){
        doFileTest("Auto links")
    }
    
    func testBackslashEscapes(){
        doFileTest("Backslash escapes")
        
    }
    
    func testBlockquotesWithCodeBlocks(){
        doFileTest("Blockquotes with code blocks")
        
    }
    
    func testHardwrappedParagraphsWithListLikeLines(){
        doFileTest("Hard-wrapped paragraphs with list-like lines")
        
    }
    
    func testHorizontalRules(){
        doFileTest("Horizontal rules")
        
    }
    
    //Gruber's implementation fails this test
    func testInlineHTMLAdvanced(){
        doFileTest("Inline HTML (Advanced)")
        
    }

    func testInlineHTMLSimple(){
        doFileTest("Inline HTML (Simple)")
        
    }
    
    func testInlineHTMLComments(){
        doFileTest("Inline HTML comments")
        
    }
    
    func testLinksInlineStyle(){
        doFileTest("Links, inline style")
        
    }
    
    func testLinksReferenceStyle(){
        doFileTest("Links, reference style")
        
    }
    
    func testLiteralQuotesInTitles(){
        doFileTest("Literal quotes in titles")
        
    }
    
    func testMarkdownDocumentationBasics(){
        doFileTest("Markdown Documentation - Basics")
        
    }
    
    func testMarkdownDocumentationSyntax(){
        doFileTest("Markdown Documentation - Syntax")
        
    }
    
    func testNestedBlockQuotes(){
        doFileTest("Nested blockquotes")
        
    }
    
    func testOrderedAndUnorderedLists(){
        doFileTest("Ordered and unordered lists")
        
    }
    
    func testStrongAndEmTogether(){
        doFileTest("Strong and em together")
        
    }
    
    func testTabs(){
        doFileTest("Tabs")
        
    }
    
    //I prefer the way my code does it!
    func testTidyness(){
        doFileTest("Tidyness")
        
    }
    
    func testOverallPerformance() {
        // This is an example of a performance test case.
        self.measureBlock {
            self.doFileTest("Markdown Documentation - Syntax")
        }
    }
    
}
