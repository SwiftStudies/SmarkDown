//
//  SmarkDownStrings.swift
//  SmarkDown
//
//  Copyright © 2016 Swift Studies. All rights reserved.
//

import Foundation

internal extension String{
    func substringWithNSRange(nsRange:NSRange)->String{
        return self.substringWithRange(rangeFromNSRange(nsRange))
    }
}

internal extension String {
    func rangeFromNSRange(nsRange:NSRange)->Range<String.Index>{
        return self.startIndex.advancedBy(nsRange.location)..<self.startIndex.advancedBy(nsRange.location+nsRange.length)
    }
}

internal extension String{
    var md5 : String {
        return "\(self.hashValue)"
    }
}

internal extension String {
    var exposedWhiteSpace : String {
        var text = self
        
        text=regexSub(text, pattern: " ", template: "▫︎")
        text=regexSub(text,pattern: "\\t",template: "⇥")
        text=regexSub(text,pattern: "\\n",template: "↩︎")
        text=regexSub(text,pattern: "\\r",template: "⇢")
        
        return text
    }
}

internal extension String{
    var ord : Int {
        guard let first = self.unicodeScalars.first else {
            return 0
        }
        
        return Int(first.value)
    }
}

infix operator ✕ {associativity left precedence 160}

func ✕ (left:String, right:Int)->String{
    var result = ""
    
    for _ in 0..<(right >= 0 ? right : 0){
        result += left
    }
    
    return result
}

func ✕ (left:String, right:Int)->[String]{
    var result = [String]()
    
    for _ in 0..<right{
        result.append(left)
    }
    
    return result
}
