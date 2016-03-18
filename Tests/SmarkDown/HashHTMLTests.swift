//
//  HashHTMLTests.swift
//  SmarkDown
//
//  Copyright © 2016 Swift Studies. All rights reserved.
//

import XCTest
@testable import SmarkDown

class HashHTMLTests: XCTestCase {

    func hashHTMLBlocks(input:String)->String{
        return SmarkDown().hashHTMLBlocks(input)
    }
    
    func testBasic() {
        let input       = "<p>\n\tHello\n</p>"
        let expected    = "\n\n-4799450059411504638\n\n"
        let result      = hashHTMLBlocks(input)
        
        XCTAssert(result == expected, "Failed for '\(input.exposedWhiteSpace)':\n'\(expected.exposedWhiteSpace)' but got \n'\(result.exposedWhiteSpace)'")
    }

    func testHR() {
        let input       = "<hr />\n\n<hr/>\n\n<hr />\t  \n\n"
        let expected    = "\n\n4799450059455835336\n\n"+"\n\n"+"\n\n4799450060392745641\n\n"+"\n\n"+"\n\n-4799450059824225068\n\n\n\n"
        let result      = hashHTMLBlocks(input)
        
        print(input.markdown)
        
        XCTAssert(result == expected, "Failed for '\(input.exposedWhiteSpace)':\n'\(expected.exposedWhiteSpace)' but got \n'\(result.exposedWhiteSpace)'")
    }
    
    func testComments() {
        let input       = "<!-- this is a test \n of the functionality -->"
        let expected    = "\n\n4799450059719042522\n\n"
        let result      = hashHTMLBlocks(input)
        
        XCTAssert(result == expected, "Failed for '\(input.exposedWhiteSpace)':\n'\(expected.exposedWhiteSpace)' but got \n'\(result.exposedWhiteSpace)'")
    }

}

#if os(Linux)
    extension HashHTMLTests : XCTestCaseProvider{
        var allTests : [(String, () throws -> Void)] {
	    return [("testBasic",testBasic),
			("testHR",testHR),
			("testComments",testComments),
		]
	}
    }
#endif
