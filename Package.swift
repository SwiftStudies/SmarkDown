import PackageDescription

let package = Package(
	name : "SmarkDown",
    dependencies: [
        .Package(url: "https://github.com/SwiftStudies/Duration.git", versions: Version(1,0,2)..<Version(2,0,0)),
    ],
    targets : [
        Target(
            name:"markdown",
            dependencies : [.Target(name:"SmarkDown")]
        ),
        Target(name:"SmarkDown"),
    ]
)
