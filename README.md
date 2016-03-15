# SmarkDown

A pure Swift [markdown](http://daringfireball.net/projects/markdown/) implementation consistent with Gruber's 1.0.1 implement version. 

BSD. Use at your own risk, pull requests **very** welcome

## Use
There are two ways to use it, it provides an extension to String so you can simply do

    let myString = "# Cool\n\nThis markdown'd\n"
    print(myString.markdown)

or you can explicitly create an instance (which will have some minor performance improvements for repeated calls

    let smarkDown = SmarkDown()
    print(smarkDown.markdown(myString))

That's all for now. More to come. 
