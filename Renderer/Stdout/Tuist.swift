import ProjectDescription

let tuist = Tuist(
    project: .tuist(
        generationOptions: .options(
            defaultConfiguration: "Debug",
            manifestEnvironment: [
                "DARWINPRIVATEFRAMEWORKS_*",
                "OPENATTRIBUTEGRAPH_*",
                "OPENRENDERBOX_*",
                "OPENSWIFTUI_*",
            ]
        )
    )
)
