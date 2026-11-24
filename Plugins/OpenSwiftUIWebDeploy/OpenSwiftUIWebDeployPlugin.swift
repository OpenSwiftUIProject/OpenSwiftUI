#if canImport(PackagePlugin)
@preconcurrency import struct Foundation.Data
@preconcurrency import class Foundation.FileManager
@preconcurrency import class Foundation.Process
@preconcurrency import class Foundation.ProcessInfo
@preconcurrency import struct Foundation.URL
@preconcurrency import func Foundation.exit
@preconcurrency import func Foundation.fputs
@preconcurrency import var Foundation.stderr
import PackagePlugin

@main
struct OpenSwiftUIWebDeployPlugin: CommandPlugin {
    struct Options {
        var product: String?
        var outputPath: String?
        var configuration: String?
        var title: String?
        var background: String = "#111216"
        var verbose: Bool = false
    }

    func performCommand(context: PluginContext, arguments: [String]) throws {
        if arguments.contains(where: { $0 == "-h" || $0 == "--help" }) {
            printUsage()
            return
        }

        let options = try parseOptions(arguments)
        let productName = try options.product ?? deriveDefaultProduct(in: context.package)
        let title = options.title ?? productName

        guard let jsKitPackage = findPackageInDependencies(
            package: context.package,
            includingProduct: "JavaScriptEventLoop"
        ) else {
            emitError(
                "JavaScriptKit was not found in the package graph. Set OPENSWIFTUI_WASI=1 when invoking swift package."
            )
            exit(1)
        }

        let buildConfig: PackageManager.BuildConfiguration
        if let rawConfig = options.configuration?.lowercased() {
            guard let parsed = PackageManager.BuildConfiguration(rawValue: rawConfig) else {
                emitError("Invalid build configuration '\(rawConfig)'. Expected debug or release.")
                exit(1)
            }
            buildConfig = parsed
        } else {
            buildConfig = .inherit
        }

        var parameters = PackageManager.BuildParameters(
            configuration: buildConfig,
            logging: options.verbose ? .verbose : .concise
        )
        parameters.echoLogs = true
        parameters.otherSwiftcFlags = [
            "-color-diagnostics",
            "-static-stdlib",
            "-Xclang-linker",
            "-mexec-model=reactor",
        ]
        parameters.otherCFlags = [
            "-D_WASI_EMULATED_SIGNAL",
            "-D_WASI_EMULATED_MMAN",
        ]
        parameters.otherLinkerFlags = [
            "--export-if-defined=__main_argc_argv",
        ]

        let buildResult = try packageManager.build(.product(productName), parameters: parameters)
        guard buildResult.succeeded else {
            if buildResult.logText.contains("-static-stdlib is no longer supported for Apple platforms")
                || buildResult.logText.contains("unknown option")
            {
                emitError("Missing WebAssembly Swift SDK. Pass `--swift-sdk <wasm-sdk-id>` to `swift package`.")
            }
            exit(1)
        }

        let wasmArtifact = try findWasmArtifact(in: buildResult, product: productName).resolvingSymlinksInPath()
        let wasmFilename = "\(productName).wasm"

        let outputDir: URL
        if let outputPath = options.outputPath {
            outputDir = URL(
                fileURLWithPath: outputPath,
                relativeTo: URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
            ).standardizedFileURL
        } else {
            outputDir = context.package.directoryURL
                .appending(path: "dist")
                .appending(path: productName)
        }

        let bundleDir = outputDir.appending(path: "Bundle")
        try FileManager.default.createDirectory(at: bundleDir, withIntermediateDirectories: true)

        let runtimeSource = jsKitPackage.directoryURL
            .appending(path: "Sources/JavaScriptKit/Runtime/index.mjs")
            .resolvingSymlinksInPath()
        guard FileManager.default.fileExists(atPath: runtimeSource.path) else {
            emitError("JavaScriptKit runtime not found at \(runtimeSource.path)")
            exit(1)
        }

        let runtimeDest = bundleDir.appending(path: "runtime.js")
        try replaceItem(from: runtimeSource, to: runtimeDest)

        let wasmDest = bundleDir.appending(path: wasmFilename)
        let isRelease = wasmArtifact.deletingLastPathComponent().lastPathComponent == "release"
        if isRelease, let wasmOpt = findExecutable("wasm-opt") {
            try runProcess(wasmOpt, arguments: ["--strip-dwarf", "-Os", "-o", wasmDest.path, wasmArtifact.path])
        } else {
            try replaceItem(from: wasmArtifact, to: wasmDest)
        }

        let bundleIndexJS = makeBundleIndexJS(wasmFilename: wasmFilename)
        try Data(bundleIndexJS.utf8).write(to: bundleDir.appending(path: "index.js"))

        let appJS = makeAppJS()
        try Data(appJS.utf8).write(to: outputDir.appending(path: "app.js"))

        let indexHTML = makeIndexHTML(title: title, background: options.background)
        try Data(indexHTML.utf8).write(to: outputDir.appending(path: "index.html"))

        print("Packaged static Web site at \(outputDir.path)")
    }

    private func parseOptions(_ arguments: [String]) throws -> Options {
        var extractor = ArgumentExtractor(arguments)
        var options = Options()
        options.product = extractor.extractOption(named: "product").last
        options.outputPath = extractor.extractOption(named: "output").last
        options.configuration = extractor.extractOption(named: "configuration").last
            ?? extractor.extractOption(named: "c").last
        options.title = extractor.extractOption(named: "title").last
        if let background = extractor.extractOption(named: "background").last {
            options.background = background
        }
        options.verbose = extractor.extractFlag(named: "verbose") > 0
        if !extractor.remainingArguments.isEmpty {
            emitError("Unexpected arguments: \(extractor.remainingArguments.joined(separator: " "))")
            printUsage()
            exit(1)
        }
        return options
    }

    private func printUsage() {
        printStderr(
            """
            OVERVIEW: Build an OpenSwiftUI executable product for WASI and emit a deployable static Web directory.

            USAGE:
              OPENSWIFTUI_WASI=1 swift package --build-system native --swift-sdk <wasm-sdk> \\
                plugin --allow-writing-to-package-directory web-deploy [options]

            OPTIONS:
              --product <name>         Executable product to build (required when package has multiple executables)
              --output <path>          Output directory for static Web files (default: ./dist/<product>)
              -c, --configuration <c>  Build configuration: debug or release
              --title <title>          HTML document title (default: <product>)
              --background <css-color> Page background color (default: #111216)
              --verbose                Enable verbose build logs
            """
        )
    }

    private func deriveDefaultProduct(in package: Package) throws -> String {
        let products = package.products(ofType: ExecutableProduct.self)
        guard !products.isEmpty else {
            emitError("No executable products found in package '\(package.displayName)'.")
            exit(1)
        }
        guard products.count == 1 else {
            let names = products.map(\.name).joined(separator: ", ")
            emitError("Multiple executable products found (\(names)). Pass `--product <name>`.")
            exit(1)
        }
        return products[0].name
    }

    private func findWasmArtifact(
        in buildResult: PackageManager.BuildResult,
        product: String
    ) throws -> URL {
        let matches = buildResult.builtArtifacts.filter {
            $0.kind == .executable && $0.url.lastPathComponent == "\(product).wasm"
        }
        guard let artifact = matches.first else {
            emitError("Could not find built artifact '\(product).wasm'. Ensure `--swift-sdk <wasm-sdk>` was passed.")
            exit(1)
        }
        return artifact.url
    }

    private func findPackageInDependencies(
        package: Package,
        includingProduct productName: String
    ) -> Package? {
        var visited: Set<Package.ID> = []
        func visit(_ current: Package) -> Package? {
            guard visited.insert(current.id).inserted else { return nil }
            if current.products.contains(where: { $0.name == productName }) {
                return current
            }
            for dependency in current.dependencies {
                if let match = visit(dependency.package) {
                    return match
                }
            }
            return nil
        }
        return visit(package)
    }

    private func replaceItem(from source: URL, to destination: URL) throws {
        let fm = FileManager.default
        try? fm.setAttributes([.posixPermissions: 0o644], ofItemAtPath: destination.path)
        try? fm.removeItem(at: destination)
        let data = try Data(contentsOf: source.resolvingSymlinksInPath())
        try data.write(to: destination)
    }

    private func findExecutable(_ name: String) -> URL? {
        let paths = (ProcessInfo.processInfo.environment["PATH"] ?? "").split(separator: ":")
        for dir in paths {
            let candidate = URL(fileURLWithPath: String(dir)).appending(path: name)
            if FileManager.default.isExecutableFile(atPath: candidate.path) {
                return candidate
            }
        }
        return nil
    }

    private func runProcess(_ executable: URL, arguments: [String]) throws {
        let process = Process()
        process.executableURL = executable
        process.arguments = arguments
        try process.run()
        process.waitUntilExit()
        guard process.terminationStatus == 0 else {
            emitError("\(executable.lastPathComponent) exited with code \(process.terminationStatus)")
            exit(1)
        }
    }

    private func escapeHTML(_ text: String) -> String {
        text
            .replacingOccurrences(of: "&", with: "&amp;")
            .replacingOccurrences(of: "<", with: "&lt;")
            .replacingOccurrences(of: ">", with: "&gt;")
            .replacingOccurrences(of: "\"", with: "&quot;")
    }

    private func makeBundleIndexJS(wasmFilename: String) -> String {
        """
        import { SwiftRuntime } from "./runtime.js";
        import {
          WASI,
          File,
          OpenFile,
          ConsoleStdout,
          PreopenDirectory,
        } from "https://cdn.jsdelivr.net/npm/@bjorn3/browser_wasi_shim@0.4.1/+esm";

        export const MODULE_PATH = "./\(wasmFilename)";

        function createDefaultBridgeJSImports() {
          return new Proxy(
            {},
            {
              get(_target, name) {
                return () => {
                  throw new Error(`Unexpected call to unlinked BridgeJS stub: ${String(name)}`);
                };
              },
            }
          );
        }

        export async function init(options = {}) {
          const args = options.args ?? [];
          const onStdoutLine = options.onStdoutLine ?? ((line) => console.log(line));
          const onStderrLine = options.onStderrLine ?? ((line) => console.error(line));
          const wasi = new WASI(
            [MODULE_PATH, ...args],
            [],
            [
              new OpenFile(new File([])),
              ConsoleStdout.lineBuffered(onStdoutLine),
              ConsoleStdout.lineBuffered(onStderrLine),
              new PreopenDirectory("/", new Map()),
            ],
            { debug: false }
          );

          const swift = new SwiftRuntime();
          const importObject = {
            javascript_kit: swift.wasmImports,
            wasi_snapshot_preview1: wasi.wasiImport,
            bjs: createDefaultBridgeJSImports(),
          };
          options.addToCoreImports?.(importObject);

          const responsePromise = options.module ?? fetch(new URL(MODULE_PATH, import.meta.url));
          let module;
          let instance;
          if (typeof WebAssembly.instantiateStreaming === "function") {
            try {
              const result = await WebAssembly.instantiateStreaming(responsePromise, importObject);
              module = result.module;
              instance = result.instance;
            } catch {
              const fallbackResponse = await fetch(new URL(MODULE_PATH, import.meta.url));
              const bytes = await fallbackResponse.arrayBuffer();
              module = await WebAssembly.compile(bytes);
              instance = await WebAssembly.instantiate(module, importObject);
            }
          } else {
            const response = await responsePromise;
            const bytes = await response.arrayBuffer();
            module = await WebAssembly.compile(bytes);
            instance = await WebAssembly.instantiate(module, importObject);
          }

          wasi.initialize(instance);
          swift.setInstance(instance);
          swift.main();
          return { module, instance, swift };
        }
        """
    }

    private func makeAppJS() -> String {
        """
        const loading = document.getElementById("loading");

        try {
          const { init } = await import(new URL("./Bundle/index.js", import.meta.url).href);
          if (document.fonts?.ready) {
            await document.fonts.ready;
          }
          await init();
          await new Promise(requestAnimationFrame);

          const canvas = document.getElementById("canvas");
          if (!canvas?.dataset.displayListVersion) {
            throw new Error("OpenSwiftUI Web renderer did not emit an initial frame.");
          }
          document.documentElement.dataset.webRendererStatus = "ready";
          setTimeout(() => loading?.remove(), 220);
        } catch (error) {
          const message = error instanceof Error ? `${error.message}\\n${error.stack ?? ""}` : String(error);
          document.documentElement.dataset.webRendererStatus = "failed";
          document.documentElement.dataset.webRendererError = message;
          if (loading) {
            loading.textContent = `Failed to start Web app:\\n${error instanceof Error ? error.message : String(error)}`;
          }
          console.error(error);
        }
        """
    }

    private func makeIndexHTML(title: String, background: String) -> String {
        let escapedTitle = escapeHTML(title)
        let escapedBackground = escapeHTML(background)
        return """
        <!doctype html>
        <html lang="en">
        <head>
          <meta charset="utf-8">
          <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no, viewport-fit=cover">
          <title>\(escapedTitle)</title>
          <style>
            :root {
              --app-bg: \(escapedBackground);
            }
            html, body {
              margin: 0;
              padding: 0;
              width: 100%;
              height: 100%;
              overflow: hidden;
              background: var(--app-bg);
              font-family: -apple-system, BlinkMacSystemFont, system-ui, sans-serif;
              -webkit-user-select: none;
              user-select: none;
            }
            #canvas {
              display: block;
              width: 100vw;
              height: 100dvh;
              touch-action: none;
              outline: none;
            }
            #loading {
              position: fixed;
              inset: 0;
              display: grid;
              place-items: center;
              background: var(--app-bg);
              color: #55504a;
              font-size: 15px;
              font-weight: 500;
              transition: opacity 160ms ease;
              pointer-events: none;
            }
            html[data-web-renderer-status="ready"] #loading {
              opacity: 0;
            }
            html[data-web-renderer-status="failed"] #loading {
              opacity: 1;
              color: #b42318;
              padding: 24px;
              text-align: center;
              pointer-events: auto;
              white-space: pre-wrap;
            }
          </style>
        </head>
        <body>
          <canvas id="canvas" aria-label="\(escapedTitle)"></canvas>
          <div id="loading">Loading \(escapedTitle)…</div>
          <script type="module" src="./app.js"></script>
        </body>
        </html>
        """
    }
}

private func printStderr(_ message: String) {
    fputs(message + "\n", stderr)
}

private func emitError(_ message: String) {
    printStderr("\u{001B}[1m\u{001B}[91merror:\u{001B}[0m \(message)")
}
#endif
