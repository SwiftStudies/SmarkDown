import Foundation
import SmarkDown

guard Process.arguments.count == 2 else {
	print("Usage: markdown <filename>");
	exit(1)	
}

let fullPath = NSString(string:Process.arguments[1]).stringByExpandingTildeInPath
if let fileContent = try? NSString(contentsOfFile: fullPath, encoding: NSUTF8StringEncoding){
    //For some reason this isn't linking... generates linker error
    print(fileContent.description.markdown)
} else {
    print("Could not open \(fullPath)")
}



