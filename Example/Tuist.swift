import ProjectDescription

let tuist = Tuist(
    fullHandle: "OpenSwiftUIProject/openswiftui",
    xcodeCache: .xcodeCache(
        upload: Environment.isCI
    ),
    project: .tuist(
        generationOptions: .options(
            optionalAuthentication: true,
            enableCaching: Environment.isCI,
            manifestEnvironment: [
                "DARWINPRIVATEFRAMEWORKS_*",
                "OPENATTRIBUTEGRAPH_*",
                "OPENRENDERBOX_*",
                "OPENSWIFTUI_*",
            ]
        )
    )
)
