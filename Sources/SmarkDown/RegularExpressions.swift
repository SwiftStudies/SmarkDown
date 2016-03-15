//
//  SmarkDownRegex.swift
//  SmarkDown
//
//  Copyright © 2016 Swift Studies. All rights reserved.
//

import Foundation

private var regexCache = [String:NSRegularExpression]()

internal func buildRegex(pattern:String, multiline:Bool, dotMatchesNewlines:Bool)->NSRegularExpression?{
    let key = "\(pattern)/\(multiline ? "m" : "")\(dotMatchesNewlines ? "s" : "")".md5
    if let cachedRegex = regexCache[key] {
        return cachedRegex
    }
    
    
    var options = [NSRegularExpressionOptions]()
    
    if multiline {
        options.append(NSRegularExpressionOptions.AnchorsMatchLines)
    }
    
    if dotMatchesNewlines{
        options.append(NSRegularExpressionOptions.DotMatchesLineSeparators)
    }
    
    let regex : NSRegularExpression
    do {
        regex = try NSRegularExpression(
            pattern: pattern,
            options: NSRegularExpressionOptions(options)
        )
    } catch {
        print("Could not create regular expression from \(pattern)")
        return nil
    }
    
    regexCache[key] = regex
    
    return regex
}

internal class RegexMatchResult : CustomStringConvertible{
    let nsResult : NSTextCheckingResult
    let string   : String
    
    init(nsResult:NSTextCheckingResult, forString:String){
        self.nsResult = nsResult
        self.string = forString
    }
    
    var range : Range<String.Index>{
        return self[0]
    }
    
    var match : String {
        return self[0]
    }
    
    var groups : Int {
        return nsResult.numberOfRanges
    }
    
    subscript(group:Int)->Bool{
        let rangeAtIndex = nsResult.rangeAtIndex(group)
        
        return rangeAtIndex.location != NSNotFound && rangeAtIndex.length > 0
    }
    
    subscript(group:Int)->Range<String.Index>{
        return string.rangeFromNSRange(nsResult.rangeAtIndex(group))
    }
    
    subscript(group:Int)->String{
        return string.substringWithNSRange(nsResult.rangeAtIndex(group))
    }
    
    var description : String {
        var result = "Match found:\n"
        
        for range in 0..<self.groups {
            result+="\t\(range). "
            if self[range]{
                result += self[range] as String
            } else {
                result += "<<Not Set>>"
            }
            result+="\n"
        }
        
        return result
    }
}

internal typealias RegexMatchReplaceBlock = (RegexMatchResult)->String
internal typealias RegexMatchBlock = (RegexMatchResult)->Void

internal func replacePatternMatchesWithBlock(text:String,pattern:String,block:RegexMatchReplaceBlock)->String{
    return replacePatternMatchesWithBlock(text, pattern: pattern, multiline: false, dotMatchesNewLines: false, block:block)
}

internal func replacePatternMatchesWithBlock(text:String,pattern:String,multiline:Bool,block:RegexMatchReplaceBlock)->String{
    return replacePatternMatchesWithBlock(text,pattern: pattern, multiline: multiline, dotMatchesNewLines:false,block:block)
}

internal func replacePatternMatchesWithBlock(text:String,pattern:String,multiline:Bool, dotMatchesNewLines:Bool, block:RegexMatchReplaceBlock)->String{
    guard let regex = buildRegex(pattern,multiline: multiline,dotMatchesNewlines: dotMatchesNewLines) else {
        return text
    }
    
    var lastMatchEnd = 0;
    var result = ""
    
    regex.enumerateMatchesInString(text,
        options: NSMatchingOptions(), range: NSMakeRange(0,text.characters.count)) { (textCheckingResult, matchingFlags, stop) -> Void in
            if let textCheckingResult = textCheckingResult {
                //Add anything in the result that's been skipped before this match
                let matchStartDelta = textCheckingResult.range.location - lastMatchEnd
                result += text.substringWithNSRange(NSRange(location:lastMatchEnd, length:matchStartDelta))
                
                //Now apply the template
                result += block(RegexMatchResult(nsResult: textCheckingResult, forString: text))
                
                //And advance the last match end
                lastMatchEnd = textCheckingResult.range.location+textCheckingResult.range.length
            }
    }
    
    //Add anything missed since the end of the last match
    result += text.substringWithNSRange(NSRange(location: lastMatchEnd,length: text.characters.count - lastMatchEnd))
    
    return result
}

internal func matchesWithBlock(text:String,pattern:String,block:RegexMatchBlock){
    return matchesWithBlock(text, pattern: pattern, multiline: false, dotMatchesNewLines: false, block: block)
}


internal func matchesWithBlock(text:String,pattern:String,multiline:Bool,block:RegexMatchBlock){
    return matchesWithBlock(text, pattern: pattern, multiline: multiline, dotMatchesNewLines: false, block: block)
}

internal func matchesWithBlock(text:String,pattern:String,multiline:Bool, dotMatchesNewLines:Bool, block:RegexMatchBlock){
    guard let regex = buildRegex(pattern,multiline: multiline,dotMatchesNewlines: dotMatchesNewLines) else {
        return
    }
    
    regex.enumerateMatchesInString(text,
        options: NSMatchingOptions(), range: NSMakeRange(0,text.characters.count)) { (textCheckingResult, matchingFlags, stop) -> Void in
            if let textCheckingResult = textCheckingResult {
                block(RegexMatchResult(nsResult: textCheckingResult, forString: text))
            }
    }
}

internal func regexSub(left:String,pattern:String,template:String)->String{
    return regexSub(left, pattern: pattern, template: template, multiline: false, dotMatchesNewLines: false)
}

internal func regexSub(left:String,pattern:String,template:String, multiline:Bool)->String{
    return regexSub(left, pattern: pattern, template: template, multiline: multiline, dotMatchesNewLines: false)
}

internal func regexSub(left:String,pattern:String,template:String, multiline:Bool, dotMatchesNewLines:Bool)->String{
    guard let regex = buildRegex(pattern,multiline: multiline,dotMatchesNewlines: dotMatchesNewLines) else {
        return left
    }
    
    let mutableText = NSMutableString()
    mutableText.setString(left)
    
    regex.replaceMatchesInString(
        mutableText,
        options: NSMatchingOptions(),
        range: NSMakeRange(0,mutableText.length),
        withTemplate: template
    )
    
    return mutableText as String
}

internal func regexMatches(text:String,pattern:String)->Bool{
    return regexMatches(text, pattern: pattern, multiline: false, dotMatchesNewLines: false)
}

internal func regexMatches(text:String,pattern:String, multiline:Bool)->Bool{
    return regexMatches(text, pattern: pattern, multiline: multiline, dotMatchesNewLines: false)
}

internal func regexMatches(text:String,pattern:String, multiline:Bool, dotMatchesNewLines:Bool)->Bool{
    guard let regex = buildRegex(pattern,multiline: multiline,dotMatchesNewlines: dotMatchesNewLines) else {
        return false
    }
    
    return regex.firstMatchInString(text, options: NSMatchingOptions(), range: NSMakeRange(0,text.characters.count)) != nil
}


