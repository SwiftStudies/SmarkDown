//
//  SmarkDownTests.swift
//  SmarkDownTests
//
//  Copyright © 2016 Swift Studies. All rights reserved.
//

import XCTest
import Foundation

@testable import SmarkDown

class SmarkDownTests: XCTestCase {
    
    #if !os(Linux)
    var bundle : NSBundle {
        return NSBundle(forClass: self.dynamicType)
    }
    #endif
    
        
    func doFileTest(fileName:String){
	    
        var inputFileName  = "./Data/\(fileName).text"
        var outputFileName = "./Data/\(fileName).html"

		//If we are not on linux see if we are running through XCode and 
		//need to get at the test data from the bundle	    	    
	    #if !os(Linux)
	        let bundle = NSBundle(forClass: self.dynamicType)
			if let fromBundle = bundle.pathForResource(fileName, ofType: "text"){
	            inputFileName = fromBundle
			}
			
			if let fromBundle = bundle.pathForResource(fileName, ofType: "html"){
            	outputFileName = fromBundle
			}
  	    #endif        
                
        do {
            let input : String = try NSString(contentsOfFile: inputFileName, encoding: NSUTF8StringEncoding).description 
            let expectedOutput : String = try NSString(contentsOfFile: outputFileName, encoding: NSUTF8StringEncoding).description
            
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
    
    // Measure block not supported on linux yet
    #if !os(Linux)
    func testOverallPerformance() {
        // This is an example of a performance test case.
        self.measureBlock {
            self.doFileTest("Markdown Documentation - Syntax")
        }
    }
    #endif
    
}

#if os(Linux)
	extension SmarkDownTests : XCTestCaseProvider {
	    var allTests : [(String, () throws -> Void)] {
        	return [
            		("testMarkdownDocumentationSyntax", testMarkdownDocumentationSyntax),
        		]
   	    }	
	}
#endif

