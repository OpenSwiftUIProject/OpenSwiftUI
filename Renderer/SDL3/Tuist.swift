import ProjectDescription

let tuist = Tuist(
    project: .tuist(
        generationOptions: .options(
            defaultConfiguration: "Debug",
            optionalAuthentication: true,
            enableCaching: false,
            manifestEnvironment: [
                "DARWINPRIVATEFRAMEWORKS_*",
                "OPENATTRIBUTEGRAPH_*",
                "OPENRENDERBOX_*",
                "OPENSWIFTUI_*",
            ]
        ),
        cacheOptions: .options(storages: [.local])
    )
)
