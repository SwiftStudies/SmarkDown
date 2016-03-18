//
//  DetabTests.swift
//  SmarkDown
//
//  Copyright © 2016 Swift Studies. All rights reserved.
//

import XCTest
@testable import SmarkDown

class DetabTests: XCTestCase {

    func detab(input:String)->String{
        return SmarkDown().detab(input)
    }

    func testSimpleDetab() {
        let input       = "\tHello"
        let expected    = "    Hello"
        let result      = detab(input)
        
        XCTAssert(result == expected, "Failed for '\(input.exposedWhiteSpace)':\n'\(expected.exposedWhiteSpace)' but got \n'\(result.exposedWhiteSpace)'")
    }

    func testAdvancedDetab() {
        let input       = " \tHello"
        let expected    = "    Hello"
        let result      = detab(input)
        
        XCTAssert(result == expected, "Failed for '\(input.exposedWhiteSpace)':\n'\(expected.exposedWhiteSpace)' but got \n'\(result.exposedWhiteSpace)'")
    }
    
    func testMultilineDetab(){
        let input       = "\tLine One\n \tLine Two\n  \tLine Three"
        let expected    = "    Line One\n    Line Two\n    Line Three"
        let result      = detab(input)
        
        XCTAssert(result == expected, "Failed for '\(input.exposedWhiteSpace)':\n'\(expected.exposedWhiteSpace)' but got \n'\(result.exposedWhiteSpace)'")
    }

    
    func testAdvancedMultilineDetab(){
        let input       = "\ta\n \tb\n   \tc\n    \td\n     \te"
        let expected    = "    a\n    b\n    c\n        d\n        e"
        let result      = detab(input)
        
        XCTAssert(result == expected, "Failed for '\(input.exposedWhiteSpace)':\n'\(expected.exposedWhiteSpace)' but got \n'\(result.exposedWhiteSpace)'")
    }
}

#if os(Linux)
	extension DetabTests : XCTestCaseProvider {
	    var allTests : [(String, () throws -> Void)] {
        	return [
            		("testAdvancedMultilineDetab", testAdvancedMultilineDetab),
            		("testMultilineDetab", testMultilineDetab),
        		]
   	    }	
	}
#endif
