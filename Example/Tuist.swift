import ProjectDescription

// Keep remote caches disabled to reduce metered network traffic.
let tuist = Tuist(
    fullHandle: "OpenSwiftUIProject/openswiftui",
    xcodeCache: .xcodeCache(
        upload: false
    ),
    project: .tuist(
        generationOptions: .options(
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
