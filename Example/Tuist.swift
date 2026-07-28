import ProjectDescription

let tuist = Tuist(
    fullHandle: "OpenSwiftUIProject/openswiftui",
    xcodeCache: .xcodeCache(
        upload: Environment.isCI
    ),
    project: .tuist(
        generationOptions: .options(
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
