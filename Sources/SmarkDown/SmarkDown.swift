//
//  SmarkDown.swift
//  SmarkDown
//
//  Copyright © 2016 Swift Studies. All rights reserved.
//

import Foundation
import Duration

#if os(Linux)
    import Glibc

    private func arc4random_uniform(max:UInt32)->UInt32{
	return UInt32(random()) % (max + 1)
    }
#endif

public extension String{
    var markdown : String {
        return SmarkDown().markdown(self)
    }
}

public class SmarkDown {
    private let nestedBracketPattern = "(?>[^\\[\\]]+|\\[(.*)\\])*"
    private let tabWidth : Int
    private let emptyElementSufix = " />"
    private var listLevel = 0

    private var htmlBlocks = [String:String]()
    private var urlHash = [String:String]()
    private var titles = [String:String]()
    
    public init(){
        tabWidth = 4
    }
    
    public init(tabWidth:Int){
        self.tabWidth = tabWidth
    }
    
    public func markdown(text:String)->String{
        
        Duration.pushLogStyle(.None)
        
        var text = text
        
        //Clear hashes
        htmlBlocks.removeAll()
        urlHash.removeAll()
        titles.removeAll()
        
        //Standardize line endings
        text = regexSub(text, pattern: "\\r\\n", template: "\n") //DOS to Unix
        text = regexSub(text, pattern: "\\r", template: "\n")    //Mac to Unix
        
        //Make sure text ends with a couple of new lines
        text += "\n\n"
        
        //Convert all tabs to spaces
        text = detab(text)
        
        //Strip any lines with only tabs and spaces
        text = regexSub(text, pattern: "^[ \\t]+$", template: "", multiline: true)
        
        //Turn block-level HTML blocks into hash entries
        text = hashHTMLBlocks(text)
        
        //Strip link definitions, store in hashes
        text = stripLinkDefinitions(text)
        
        text = runBlockGamut(text)
        
        text = unescapeSpecialCharacters(text)
        
        Duration.popLogStyle()
        
        return "\(text)\n"
    }

    //Called just once, not a big candidate for optimization
    internal func stripLinkDefinitions(text:String)->String{
        let lessThanTab = tabWidth-1
        
        //First grab nested blocks that are against the left margin
        var pattern : String =
        "^[ ]{0,\(lessThanTab)}\\[(.+)\\]:" +           //$1 = id
            "[ \\t]*" +
            "\\n?" +
            "[ \\t]*" +
            "<?(\\S+?)>?" +                                 //$2 = url
            "[ \\t]*" +
            "\\n?" +
            "[ \\t]*" +
            "(?:" +
            "(?<=\\s)" +
            "[\"(]" +
            "(.+?)" +                                   //$3 = title
            "[\")]" +
            "[ \\t]*" +
            ")?" +
        "(?:\\n+|\\Z)"
        
        //The lazy matches in the above pattern seem to break it
        pattern = "^[ ]{0,\(lessThanTab)}\\[(.+)\\]:[ \\t]*\\n?[ \\t]*<?(\\S+)>?[ \\t]*\\n?[ \\t]*(?:(?<=\\s)[\"(](.+)[\")][ \\t]*)?(?:\\n+|\\Z)"
        
        
        //TODO: Could just be a match, although will be a small gain
        return replacePatternMatchesWithBlock(text, pattern: pattern, multiline: true){
            (match)->String in
            
            var id : String = match[1]
            id = id.lowercaseString
            
            self.urlHash[id] = self.encodeAmpsAndAngles(match[2])
            if match[3] {
                self.titles[id] = regexSub(match[3], pattern: "\"", template: "&quot;")
            }
            
            
            return ""
        }
    }
    
    //For testing purposes
    internal func urlForId(id:String)->String?{
        return urlHash[id]
    }
    
    internal func titleForId(id:String)->String?{
        return titles[id]
    }
    
    internal func encodeAmpsAndAngles(text:String)->String{
        
        let text = regexSub(text, pattern: "&(?!#?[xX]?(?:[0-9a-fA-F]+|\\w+);)", template: "&amp;")
        
        
        return regexSub(text, pattern: "<(?![a-z/?\\$!])", template: "&lt;")
    }
    
    internal func runBlockGamut(text:String)->String{
        var text = doHeaders(text)
        
        //Horizontal rules
        text = regexSub(text, pattern: "^[ ]{0,2}([ ]?\\*[ ]?){3,}[ \\t]*$", template: "\n<hr\(emptyElementSufix)\n", multiline: true)
        text = regexSub(text, pattern:   "^[ ]{0,2}([ ]?-[ ]?){3,}[ \\t]*$", template: "\n<hr\(emptyElementSufix)\n", multiline: true)
        text = regexSub(text, pattern:   "^[ ]{0,2}([ ]?_[ ]?){3,}[ \\t]*$", template: "\n<hr\(emptyElementSufix)\n", multiline: true)
        
        text = doLists(text)
        text = doCodeBlocks(text)
        text = doBlockQuotes(text)
        text = hashHTMLBlocks(text)
        text = formParagraphs(text)
        
        return text
    }
    
    internal func hashHtml(html:String)->String{
        let key = html.md5
        
        htmlBlocks[key] = html
        
        return key
    }
    
    internal func runSpanGamut(text:String)->String{
        var text = text
        
        text = doCodeSpans(text)
        text = escapeSpecialChars(text)
        text = doImages(text)
        text = doAnchors(text)
        text = doAutolinks(text)
        text = encodeAmpsAndAngles(text)
        text = doItalicsAndBold(text)
        
        //Do hard-breaks
        
        text = regexSub(text, pattern: " {2,}\\n", template: "<br\(emptyElementSufix)>")
        
        return text
    }
    
    func doHeaders(text:String)->String{
        var text = text
        
        text = replacePatternMatchesWithBlock(text, pattern: "^(.+)[ \\t]*\\n=+[ \\t]*\\n+", multiline: true){
            (match)->String in
            
//            return self.hashHtml("<h1>\(self.runSpanGamut(match[1]))</h1>")+"\n\n"
            return "<h1>\(self.runSpanGamut(match[1]))</h1>\n\n"
        }
        
        text = replacePatternMatchesWithBlock(text, pattern: "^(.+)[ \\t]*\\n-+[ \\t]*\\n+", multiline: true){
            (match)->String in
//            return self.hashHtml("<h2>\(self.runSpanGamut(match[1]))</h1>")+"\n\n"
            return "<h2>\(self.runSpanGamut(match[1]))</h2>\n\n"
        }
        
        text = replacePatternMatchesWithBlock(text, pattern: "^(\\#{1,6})[ \\t]*(.+?)[ \\t]*\\#*\\n+",multiline: true){
            (match)->String in
            
            let headerDashes : String = match[1]
            let headerLevel = headerDashes.characters.count
            
//            return self.hashHtml("<h\(headerLevel)>\(self.runSpanGamut(match[2]))</h\(headerLevel)>")+"\n\n"
            return "<h\(headerLevel)>\(self.runSpanGamut(match[2]))</h\(headerLevel)>\n\n"
        }
        
        return text
    }
    
    func doItalicsAndBold(text:String)->String{
        
        let text = regexSub(text, pattern: "(\\*\\*|__)(?=\\S)(.+?[*_]*)(?<=\\S)\\1", template: "<strong>$2</strong>")
        
        return regexSub(text, pattern: "(\\*|_)(?=\\S)(.+?)(?<=\\S)\\1", template: "<em>$2</em>")
    }
    
    internal func unescapeSpecialCharacters(text:String)->String{
        var text = text
        
        for escapeCode in SpecialCharacter.all{
            text = escapeCode.unencodeToCharacters(inString: text)
        }
        
        return text
    }
    
    func doCodeSpans(text:String)->String{
        return replacePatternMatchesWithBlock(text, pattern: "(`+)(.+?)(?<!`)\\1(?!`)"){
            (match)->String in
            
            var code : String = match[2]
            
            code = regexSub(code, pattern: "^[ \\t]*", template: "")
            code = regexSub(code, pattern: "[ \\t]*$", template: "")
            code = self.encodeCode(code)
            
            return "<code>\(code)</code>"
        }
    }
    
    
    func doImages(text:String)->String{
        
        //Reference style images
        var text = replacePatternMatchesWithBlock(text, pattern: "(!\\[(.*?)\\][ ]?(?:\\n[ ]*)?\\[(.*?)\\])",multiline: true){
            (match)->String in
            
            var result = ""
            let wholeMatch : String = match[1]
            var altText : String = match[2]
            var id : String = match[3].lowercaseString
            
            if id == "" {
                id = altText.lowercaseString
            }
            
            altText = regexSub(altText, pattern: "\"", template: "&quot;")
            
            if var url = self.urlHash[id] {
                url = url.stringByEncodingInstanceOf(.Star).stringByEncodingInstanceOf(.Underscore)
                
                result = "<img src=\"\(url)\" alt=\"\(altText)\""
                
                if var title = self.titles[id] {
                    title = title.stringByEncodingInstanceOf(.Star).stringByEncodingInstanceOf(.Underscore)
                    
                    result += " title=\"\(title)\""
                }
            } else {
                result = wholeMatch
            }
            
            return result + self.emptyElementSufix
        }
        
        //Inline images
        text = replacePatternMatchesWithBlock(text, pattern: "(!\\[(.*?)\\]\\([ \\t]*<?(\\S+?)>?[ \\t]*((['\"])(.*?)\\5[ \\t]*)?\\))"){
            (match)->String in
            
            var result = ""
            //        var wholeMatch : String = match[1]
            var altText : String = match[2]
            var url : String = match[3]
            var title = ""
            
            if match[6] {
                title = match[6]
            }
            
            altText = regexSub(altText, pattern: "\"", template: "&quot;")
            url = url.stringByEncodingInstanceOf(.Star).stringByEncodingInstanceOf(.Underscore)
            
            result = "<img src=\"\(url)\" alt=\"\(altText)\""
            
            title = title.stringByEncodingInstanceOf(.Star).stringByEncodingInstanceOf(.Underscore).stringByReplacingOccurrencesOfString("\"", withString: "&quot;")
            
            result += " title=\"\(title)\""
            
            result += self.emptyElementSufix
            
            return result
        }
        
        return text
    }
    
    func doAnchors(text:String)->String{
        //
        //Reference style links
        //
        var text = replacePatternMatchesWithBlock(text, pattern: "(\\[((?>[^\\[\\]]+)|\\[(.*)\\])*\\])[ ]?(?:\\n[ ]*)?\\[(.*?)\\]"){
            (match)->String in
            
            //        print("Reference link with pattern: (\\[((?>[^\\[\\]]+)|\\[(.*)\\])*\\])[ ]?(?:\\n[ ]*)?\\[(.*?)\\]")
            //        print("Produced \(match):")
            var result = ""
            let wholeMatch : String = match[0]
            
            let linkText : String
            
            if match[3] {
                //There are embedded brackets
                var withOuterBrackets = match[1] as String
                
                withOuterBrackets = withOuterBrackets.substringWithRange(withOuterBrackets.startIndex.advancedBy(1)..<withOuterBrackets.endIndex.predecessor())
                
                linkText = withOuterBrackets
            } else {
                linkText = match[2]
            }
            
            var id : String = match[4]
            
            if id == "" {
                id = linkText
            }
            
            if var url = self.urlHash[id]{
                url = url.stringByEncodingInstanceOf(.Star).stringByEncodingInstanceOf(.Underscore)
                
                
                result = "<a href=\"\(url)\""
                
                if var title = self.titles[id] {
                    title = title.stringByEncodingInstanceOf(.Star).stringByEncodingInstanceOf(.Underscore)
                    
                    result += " title=\"\(title)\""
                }
                result += ">\(linkText)</a>"
            } else {
                result = wholeMatch
            }
            
            return result
        }
        
        //
        //Inline style links
        //
        text = replacePatternMatchesWithBlock(text, pattern: "\\[((?>[^\\[\\]]+|\\[(.*)\\])*)\\]\\([ \\t]*<?(.*?)>?[ \\t]*((['\"])(.*?)\\5)?\\)"){
            (match)->String in
            
            var result = ""
            //        print (match)
            //        let wholeMatch : String = match[1]
            let linkText : String = match[1]
            var url : String = match[3]
            
            url = url.stringByEncodingInstanceOf(.Star).stringByEncodingInstanceOf(.Underscore)
            
            result = "<a href=\"\(url)\""
            
            if match[6] {
                var title : String = match[6]
                title = regexSub(title, pattern: "\"", template: "&quot;")
                title = title.stringByEncodingInstanceOf(.Star).stringByEncodingInstanceOf(.Underscore)
                
                result += " title=\"\(title)\""
            }
            
            result += ">\(linkText)</a>"
            
            return result
        }
        
        return text
        
    }
    
    func encodeBackslashEscapes(text:String)->String{
        var text = text
        
        for specialCharacter in SpecialCharacter.all{
            text = text.stringByEncodingEscapedInstanceOf(specialCharacter)
        }
        
        return text
    }
    
    func tokenizeHtml(str:String)->[(type:String,value:String)]{
        var tokens = [(type:String,value:String)]()
        var pos = 0
        
        let len = str.characters.count
        let depth = 6
        let nestedTags = ("(?:<[a-z/!$](?:[^<>]" ✕ depth).joinWithSeparator("|") + ")*>)" ✕ depth
        
        
        let pattern = "(?s:<!(--.*?--\\s*)+>)|" +
            "(?s:<\\?.*?\\?>)|" +
        nestedTags
        
        replacePatternMatchesWithBlock(str, pattern: pattern){
            (match)->String in
            
            let wholeTag : String = match[0]
            let secStart = match.nsResult.range.location+match.nsResult.range.length
            let tagStart = secStart - wholeTag.characters.count
            
            if (pos < tagStart){
                tokens.append((type: "text", value: str.substringWithNSRange(NSMakeRange(pos, tagStart-pos))))
            }
            
            tokens.append((type: "tag", value: wholeTag))
            pos = secStart
            return ""
        }
        
        tokens.append((type:"text",value:str.substringWithNSRange(NSMakeRange(pos, len-pos))))
        
        return tokens
    }
    
    func escapeSpecialChars(text:String)->String{
        
        let tokens = tokenizeHtml(text)
        
        var text = ""
        
        for currentToken in tokens{
            if (currentToken.type == "tag"){
                text += currentToken.value.stringByEncodingInstanceOf(.Star).stringByEncodingInstanceOf(.Underscore)
            } else {
                text += encodeBackslashEscapes(currentToken.value)
            }
        }
        
        return text
    }

    func encodeEmailAddress(address:String)->String{
        
        let encoders : [(String)->String] = [
            {(shift)->String in return "&#\(shift.ord);"},
            {(shift)->String in return "&#x\(String(shift.ord, radix: 16, uppercase: false));"},
            {(shift)->String in return shift},
        ]
        
        var address = replacePatternMatchesWithBlock(address, pattern: "(.)"){
            (match)->String in
            
            let char : String = match[1]
            
            if char == "@" {
                return encoders[Int(arc4random_uniform(2))](char)
            } else if char != ":" {
                return encoders[Int(arc4random_uniform(3))](char)
            }
            
            return char
        }
        
        address = "<a href=\"\(address)\">\(address)</a>"
        
        return regexSub(address, pattern: "\">.+?:", template: "\">")
    }
    
    
    func doAutolinks(text:String)->String{
        var text = regexSub(text, pattern: "<((https?|ftp):[^'\">\\s]+)>", template: "<a href=\"$1\">$1</a>")
        
        text = replacePatternMatchesWithBlock(text, pattern: "<(?:mailto:)?([-.\\w]+\\@[-a-z0-9]+(\\.[-a-z0-9]+)*\\.[a-z]+)>"){
            (match)->String in
            
            return self.encodeEmailAddress(self.unescapeSpecialCharacters(match[0]))
        }
        
        return text
        
    }
    
    func doLists(text:String)->String{
        let lessThanTab = tabWidth - 1
        let markerULPattern = "[*+-]"
        let markerOLPattern = "\\d+[.]"
        let markerAnyPattern = "(?:\(markerULPattern)|\(markerOLPattern))"
        
        func listSearchMatch(match:RegexMatchResult)->String{
            var list        = match[1] as String
            let listType    = regexMatches(match[3],pattern:markerULPattern) ? "ul" : "ol"
            
            list = regexSub(list, pattern: "\\n{2,}", template: "\n\n\n")
            
            let result = processListItems(list, marker: markerAnyPattern)
            
            //Doesn't work becauase it has recursively compressed itself
//            return hashHtml("<\(listType)>\n\(result)</\(listType)>")+"\n\n"
            return "<\(listType)>\n\(result)</\(listType)>\n"
        }
        
        
        var text = text
        
        let wholeList = "(([ ]{0,\(lessThanTab)}(\(markerAnyPattern))[ \\t]+)(?s:.+?)(\\z|\\n{2,}(?=\\S)(?![ \\t]*\(markerAnyPattern)[ \\t]+)))"
        
        if listLevel > 0 {
            text = replacePatternMatchesWithBlock(text, pattern: "^\(wholeList)", multiline: true, block:listSearchMatch)
        } else {
            text = replacePatternMatchesWithBlock(text, pattern: "(?:(?<=\\n\\n)|\\A\\n?)\(wholeList)", multiline: true, block: listSearchMatch)
        }
        
        return text
    }
    
    func processListItems(listString:String, marker:String)->String{
        listLevel += 1
        
        var listString = regexSub(listString, pattern: "\\n{2,}\\z", template: "\n")
        
        listString = replacePatternMatchesWithBlock(listString, pattern: "(\\n)?(^[ \\t]*)(\(marker))[ \\t]+((?s:.+?)(\\n{1,2}))(?=\\n*(\\z|\\2(\(marker))[ \\t]+))", multiline: true){
            (match)->String in
            
            var item = match[4] as String
            let leadingLine = match[1] ?  match[1] as String : ""
            
            if leadingLine.characters.count > 0 || regexMatches(item, pattern: "\\n{2,}"){
                item = self.runBlockGamut(self.outdent(item))
            } else {
                item = self.doLists(self.outdent(item))
                item = item.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
                item = self.runSpanGamut(item)
            }
            
            return "<li>\(item)</li>\n"
        }
        
        listLevel -= 1
        
        return listString
    }
    
    func encodeCode(text:String)->String{
        var text = text.stringByReplacingOccurrencesOfString("&", withString: "&amp;")
        text = text.stringByReplacingOccurrencesOfString("<", withString: "&lt;")
        text = text.stringByReplacingOccurrencesOfString(">", withString: "&gt;")
        
        text = text.stringByEncodingInstanceOf(.Star)
        text = text.stringByEncodingInstanceOf(.Underscore)
        text = text.stringByEncodingInstanceOf(.OpenCurly)
        text = text.stringByEncodingInstanceOf(.CloseCurly)
        text = text.stringByEncodingInstanceOf(.OpenSquare)
        text = text.stringByEncodingInstanceOf(.CloseSquare)
        text = text.stringByEncodingInstanceOf(.Backslash)
        
        return text
    }
    
    func outdent(text:String)->String{
        return regexSub(text, pattern: "^(\\t|[ ]{1,\(tabWidth)})", template: "", multiline: true)
    }
    
    func doCodeBlocks(text:String)->String{
        var text = text
        
        let pattern = "(?:\\n\\n|\\A)((?:(?:[ ]{\(tabWidth)}|\\t).*\\n+)+)((?=^[ ]{0,\(tabWidth)}\\S)|\\Z)"
        
        text = replacePatternMatchesWithBlock(text, pattern: pattern, multiline: true){
            (match)->String in
            
            var codeBlock : String = match[1]
            
            codeBlock = self.encodeCode(self.outdent(codeBlock))
            codeBlock = self.detab(codeBlock)
            codeBlock = regexSub(codeBlock, pattern: "\\A\\n+", template: "")
            codeBlock = regexSub(codeBlock, pattern: "\\s+\\z", template: "")
            
            return "\n\n"+self.hashHtml("<pre><code>\(codeBlock)\n</code></pre>")+"\n\n"
//            return "\n\n<pre><code>\(codeBlock)\n</code></pre>\n\n"
        }
        
        return text
    }
    
    func doBlockQuotes(text:String)->String{
        var text = text
        
        let pattern =   "(" +                               //wrap whole match in $1
            "(" +
            "^[ \\t]*>[ \\t]?" +        // > at the start of a line
            ".+\\n" +                   // rest of first line
            "(.+\\n)*" +                // subsequent consecutive lines
            "\\n*" +                    // blanks
            ")+" +
        ")"
        
        text = replacePatternMatchesWithBlock(text, pattern: pattern, multiline: true){
            (match)->String in
            
            var bq : String = match[1]
            bq = regexSub(bq, pattern: "^[ \\t]*>[ \\t]?", template: "", multiline: true) //trim one level of quoting
            bq = regexSub(bq, pattern: "^[ \\t]+$", template: "")                         //trim whitespace-only lines
            bq = self.runBlockGamut(bq)                                                        //recurse
            bq = regexSub(bq, pattern: "^", template: "  ", multiline: true)
            
            //Leading spaces cause problems with <pre> content, so we need to fix that
            bq = replacePatternMatchesWithBlock(bq, pattern: "(\\s*<pre>.+?<\\/pre>)",multiline: false,dotMatchesNewLines: true){
                (match)->String in
                
                let removedSpaces = regexSub(match[0],pattern: "^  ",template: "", multiline:true)
                
                return removedSpaces
            }
            
            return self.hashHtml("<blockquote>\n\(bq)\n</blockquote>")+"\n\n"
//            return "<blockquote>\n\(bq)\n</blockquote>\n\n"
        }
        
        return text
    }
    
    func formParagraphs(text:String)->String{
        var text = text
        
        text = regexSub(text, pattern: "\\A\\n+", template: "")
        text = regexSub(text, pattern: "\\n+\\z", template: "")
        
        var paragraphs = regexSub(text, pattern: "\\n{2,}", template: "&&&&&&").componentsSeparatedByString("&&&&&&")
        
        text = ""
        var first = true
        for p in 0..<paragraphs.count{
            if !first {
                text += "\n\n"
            } else {
                first = false
            }
            
            if let htmlBlock = htmlBlocks[paragraphs[p]]{
                text += htmlBlock
            } else {
                let result = regexSub(runSpanGamut(paragraphs[p]),
                    pattern: "^([ \\t]*)", template: "<p>")+"</p>";
                
                if result != "<p></p>" {
                    text += result
                } else {
                    //Skip double new line on the next paragraph
                    first = true
                }
            }
        }
        
        
        return text
    }
    
    internal func detab(text:String)->String{
        return detab(text,tabWidth: tabWidth)
    }
    
    internal func detab(text:String, tabWidth:Int)->String{
        
        return replacePatternMatchesWithBlock(text, pattern: "(.*?)\t"){
            (match)->String in
            
            var spaces = ""
            
            for _ in 0..<tabWidth - (match[1].characters.count % tabWidth) {
                spaces += " "
            }
            
            return "\(match[1] as String)\(spaces)"
        }
    }
    
    private let blockTagsA = "pre|div|h[1-6]|blockquote|p|table|dl|ol|ul|script|noscript|form|fieldset|iframe|math|ins|del"
    private let blockTagsB = "pre|div|h[1-6]|blockquote|p|table|dl|ol|ul|script|noscript|form|fieldset|iframe|math"
    
    
    internal func hashHTMLBlocks(text:String)->String{
        
        func codeLine(text:String, matchStart:String.Index)->Bool{
//            Duration.startMeasurement("Code test")
            var lineStart = matchStart
            
            var inlineBlock = false
            
            var scanDepth = 0
            
            //Scan back to the new line
            while text.characters[lineStart] != "\n"{
                scanDepth += 1
                
                if lineStart == text.startIndex {
                    break
                }
                
                lineStart = lineStart.predecessor()
                if inlineBlock {
                    if text.characters[lineStart] != "\\"{
//                        Duration.stopMeasurement("inline code-block (\(scanDepth))")
                        return true
                    }
                } else if text.characters[lineStart] == "`" {
                    inlineBlock = true
                }
            }
            var linePrefix = text.substringWithRange(lineStart..<matchStart)
            
            if linePrefix.hasPrefix("\n"){
                linePrefix = linePrefix.substringFromIndex(linePrefix.startIndex.advancedBy(1))
            }
            
            if linePrefix.hasPrefix("    "){
//                Duration.stopMeasurement("code-block (\(scanDepth))")
                return true
            }
            
            if linePrefix.hasPrefix("\t"){
//                Duration.stopMeasurement("code-block (\(scanDepth))")
                return true
            }
            
//            Duration.stopMeasurement("not code")
            return false
        }
        
        enum HTMLBlock {
            case Open(tag:String,start:Int)
            case Block(range:Range<String.Index>)
        }
        
        //Here's the rub... an open block should be less than three spaces before a newline or start of file
        let pattern = "(?:<(\\/?)(\(blockTagsA)|hr)(.*?)(\\/?)>|((<!--).*?-->))[ \\t]*"
        
        var depth = 0
        var blocks = [HTMLBlock]()
        
        var expensiveTags = 0
        var reallyExpensiveTags = 0
        var totalTags = 0
        
        var textPos = 0
        var textIndex = text.startIndex
        
        Duration.startMeasurement("hashHTML")
        
        Duration.startMeasurement("Finding tags")
        matchesWithBlock(text, pattern: pattern, multiline: false, dotMatchesNewLines: true){
            (tagMatch) in
            
            totalTags += 1
            
            textIndex = textIndex.advancedBy(tagMatch.nsResult.range.location - textPos)
            textPos = tagMatch.nsResult.range.location
            
            var matchType = "Code Line"
            Duration.startMeasurement("Match")
            if !codeLine(text, matchStart: textIndex){
                //It's a comment
                if tagMatch[5] {
                    blocks.append(HTMLBlock.Block(range: tagMatch[0]))
                    Duration.stopMeasurement("Comment")
                    return
                }
                
                let close           = tagMatch[1] as Bool

                //Is this a single element (open and close)
                if depth == 0 && !close && tagMatch[4] {
                    blocks.append(HTMLBlock.Block(range:tagMatch[0]))
                    Duration.stopMeasurement("Open/Close")
                    return
                }

                expensiveTags += 1
                
                let tag = tagMatch[2] as String
                
                //Special case for hr
                if depth == 0 && tag == "hr" {
                    blocks.append(HTMLBlock.Block(range:tagMatch[0]))
                    Duration.stopMeasurement("hr")
                    return
                }
                                
                if close {
                    depth -= 1
                    //If the close brings us back to depth 0 then we should see if it has a matching pair
                    if depth == 0 {
                        //If the last block was an open for the same tag, remove it and add a single new block
                        //for the full range
                        if let lastBlock = blocks.last{
                            switch lastBlock{
                            case .Open(let openBlock) where openBlock.tag == tag:
                                blocks.removeLast()
                                blocks.append(HTMLBlock.Block(range: text.rangeFromNSRange(NSMakeRange(openBlock.start, (tagMatch.nsResult.range.location+tagMatch.nsResult.range.length)-openBlock.start))))
                                reallyExpensiveTags += 1
                            default:
                                break
                            }
                        }
                    }
                }
                
                //            print("\t" ✕ (depth) + (close ? "/" : "") + tag)
                
                if !close {
                    if depth == 0 {
                        blocks.append(HTMLBlock.Open(tag: tag, start: tagMatch.nsResult.range.location))
                    }
                    depth += 1
                }

                matchType="\(tag)"
                
            }
            Duration.stopMeasurement(matchType)
            
            return
        }
        Duration.stopMeasurement()
        
        var pos = text.startIndex
        var result = ""
        
        Duration.startMeasurement("Adding hashes")
        for block in blocks {
            switch block {
            case .Block(let blockRange):
                if pos < blockRange.startIndex {
                    result += text.substringWithRange(pos..<blockRange.startIndex)
                }
                
                let htmlBlock = text.substringWithRange(blockRange)
                
                let key = htmlBlock.md5
                
                htmlBlocks[key] = htmlBlock
                
                result += "\n\n\(key)\n\n"
                
                pos = blockRange.endIndex
            default:
                break
            }
        }
        
        if pos < text.endIndex{
            result += text.substringWithRange(pos..<text.endIndex)
        }
        Duration.stopMeasurement()
        
        Duration.stopMeasurement("Tags \(totalTags)\\\(expensiveTags)\\\(reallyExpensiveTags)")
        
        return result
    }
    
    
}



