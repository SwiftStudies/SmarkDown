import PackageDescription

let package = Package(
	name : "SmarkDown",
    targets : [
        Target(
            name:"markdown",
            dependencies : [.Target(name:"SmarkDown")]
        ),
        Target(name:"SmarkDown"),
    ]
)