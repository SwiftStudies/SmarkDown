[![Build Status](https://travis-ci.org/SwiftStudies/SmarkDown.svg?branch=master)](https://travis-ci.org/SwiftStudies/SmarkDown)

# SmarkDown

A pure Swift [markdown](http://daringfireball.net/projects/markdown/) implementation consistent with Gruber's 1.0.1  version. It is released under the BSD license so please feel free to use (at your own risk). 

Pull requests are ***very*** welcome, see the vision for where I would like this to go. 

## Vision

Version 1.0 is a very minor Swift-ification of Gruber's original Perl implementation. Lots of regular expressions. The initial performance of this implementation yielded about 28s to process the large Markdown Syntax test. This has improved in 1.0.2 to 7s with some pretty simple optimization of what's there. 

However, I would next like to achieve two things

 1. Refactor to support easier extension for particular variants of Markdown
 2. Change the fundamental strategy from regular expressions to a higher performance scanner. In fact there are some seeds already sown there, but I want to clear out regular expressions. They are slow, opaque and the implementation has significant overhead. 

Once again, I would ***love*** to receive pull requests towards this goal. 

## Building and Running with Swift Package Manager

### Install Swift toolchain if you don't already have it

If you don't already have the latest Swift tool-chain it, it's not a huge download for the binary (<200Mb), it **doesn't** impact or need anything specific from XCode (unless you want to integrate them), and it comes with an installer. You can [download it here](https://swift.org/download/).

Once you've done that all you will need to do is open a terminal window, make sure the latest tool-chain is in your path

	export PATH=/Library/Developer/Toolchains/swift-latest.xctoolchain/usr/bin:"${PATH}"
	
Change to the SmarkDown package directory (where you can see this readme and the Sources, Tests, and Data directories for example).

### Building and running

There are two modules in the package `SmarkDown` is the library you can use in your own projects, and the second is a command line tool `markdown` which takes a single parameter (which should be a .md markdown file) and outputs the resultant html. You can do a quick test with 

	swift build
	.build/debug/markdown README.md
	
You should see the HTML version of the read me! As a side note, you have to love Swift Package Manager... it is so very easy to use and get going with!

## Use in your code

There are two ways to use it, it provides an extension to String so you can simply do

    let myString = "# Cool\n\nThis markdown'd\n"
    print(myString.markdown)

or you can explicitly create an instance (which will have some minor performance improvements for repeated calls

    let smarkDown = SmarkDown()
    print(smarkDown.markdown(myString))

## Integrating with your project
SmarkDown uses the [Swift Package Manager](https://swift.org/package-manager/) so if you are using this for your builds you simply need to add a dependency to your manifest

	import PackageDescription
	
	let package = Package(
		name : "Your Project",
		dependencies : [
			//Add the SmarkDown dependency
			.Package(url:"https://github.com/SwiftStudies/SmarkDown.git", majorVersion:1),
		]
	)

Alternatively you can clone (or download) the repository to your computer and add the following files (if you are cloning then I would suggest adding without copying) to your project

 * `SmarkDown.swift`
 * `SpecialCharacters.swift`
 * `Strings.swift`
 * `RegularExpressions.swift`
 
I'd recommend doing this in another target (such as library or framework) as there are some extensions you may not want to be exposed to (i.e. are internal to the module). 

## Reporting Issues

Please do so using Github's own system. 
