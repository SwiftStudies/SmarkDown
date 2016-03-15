//
//  SpecialCharacters.swift
//  SmarkDown
//
//  Copyright © 2016 Swift Studies. All rights reserved.
//

import Foundation

enum SpecialCharacter : String{
    case Backslash="\\", Tick="`", Star="*", Underscore="_", GreaterThan=">"
    case Hash="#", Plus="+", Minus="-", Period=".", Pling="!"
    case OpenCurly="{", CloseCurly="}"
    case OpenSquare="[", CloseSquare="]"
    case OpenBrace="(", CloseBrace=")"
    
    var  encodedValue : String {
        return String(rawValue.hashValue, radix: 36, uppercase:false)
    }
    
    var escapedValue : String {
        return "\\\(rawValue)"
    }
    
    func encodeEscapedValue(inString text:String)->String{
        return text.stringByReplacingOccurrencesOfString(escapedValue, withString: encodedValue)
    }
    
    func encodeCharacter(inString text:String)->String{
        return text.stringByReplacingOccurrencesOfString(rawValue, withString: encodedValue)
    }
    
    func unencodeToCharacters(inString text:String)->String{
        return text.stringByReplacingOccurrencesOfString(encodedValue, withString: rawValue)
    }
    
    static var all : [SpecialCharacter] {
        return [
            .Backslash,
            .Tick,
            .Star,
            .Underscore,
            .GreaterThan,
            .Hash,
            .Plus,
            .Minus,
            .Period,
            .Pling,
            .OpenCurly,
            .CloseCurly,
            .OpenSquare,
            .CloseSquare,
            .OpenBrace,
            .CloseBrace
        ]
    }
}

extension String{
    func stringByEncodingInstanceOf(specialCharacter:SpecialCharacter)->String{
        return specialCharacter.encodeCharacter(inString: self)
    }
    func stringByEncodingEscapedInstanceOf(specialCharacter:SpecialCharacter)->String{
        return specialCharacter.encodeEscapedValue(inString: self)
    }
}
