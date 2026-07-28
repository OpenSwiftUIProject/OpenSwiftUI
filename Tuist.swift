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
                "OPENSWIFTUI_*",
            ]
        )
    )
)
