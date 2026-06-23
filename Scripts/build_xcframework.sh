#!/bin/bash

set -e

: "${OPENSWIFTUI_LIBRARY_TYPE:=dynamic}"
: "${OPENSWIFTUI_USE_LOCAL_DEPS:=1}"
: "${OPENSWIFTUI_SWIFTUI_RENDERER:=0}"
export OPENSWIFTUI_LIBRARY_TYPE
export OPENSWIFTUI_USE_LOCAL_DEPS
export OPENSWIFTUI_SWIFTUI_RENDERER

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd -P)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

cd "$PROJECT_ROOT"

PROJECT_BUILD_DIR="${PROJECT_BUILD_DIR:-"${PROJECT_ROOT}/build"}"
DERIVED_DATA_PATH="$PROJECT_BUILD_DIR/DerivedData"
XCODEPROJ="$PROJECT_ROOT/OpenSwiftUI.xcodeproj"
XCODEWORKSPACE="$PROJECT_ROOT/Workspace.xcworkspace"

# Parse arguments.
# --sdk and --archs are paired: --sdk <sdk> --archs <arch1,arch2>
# If --archs is omitted for an SDK, all default architectures are built.
SDKS=()
SDK_ARCHS=()
DEBUG_MODE=false
RUN_TUIST_INSTALL=true
EXPLICIT_FRAMEWORK_NAMES=false
FRAMEWORK_NAMES=()

DEFAULT_FRAMEWORK_NAMES=(
    "OpenAttributeGraphShims"
    "OpenCoreGraphicsShims"
    "OpenQuartzCoreShims"
    "OpenObservation"
    "OpenRenderBoxShims"
    "OpenSwiftUICore"
    "OpenSwiftUI"
)

print_usage() {
    cat <<'USAGE'
Usage: Scripts/build_xcframework.sh [options] [framework ...]

Options:
  --sdk <sdk>             Build for an SDK. May be passed multiple times.
  --archs <arch1,arch2>   Override architectures for the previous --sdk.
  --debug                 Keep release metadata and copy dSYMs.
  --compute               Build OpenAttributeGraphShims with the Compute source backend.
  --skip-tuist-install    Skip tuist install.
  --framework <name>      Build one framework. May be passed multiple times.
  --help                  Show this help.
USAGE
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --help|-h)
            print_usage
            exit 0
            ;;
        --sdk)
            SDKS+=("$2")
            SDK_ARCHS+=("")
            shift 2
            ;;
        --archs)
            if [ ${#SDKS[@]} -gt 0 ]; then
                SDK_ARCHS[$((${#SDK_ARCHS[@]} - 1))]="$2"
            fi
            shift 2
            ;;
        --debug)
            DEBUG_MODE=true
            shift
            ;;
        --compute)
            OPENSWIFTUI_OPENATTRIBUTESHIMS_ATTRIBUTEGRAPH=0
            OPENSWIFTUI_OPENATTRIBUTESHIMS_DANCEUIGRAPH=0
            OPENSWIFTUI_OPENATTRIBUTESHIMS_COMPUTE=1
            OPENSWIFTUI_OPENATTRIBUTESHIMS_COMPUTE_BINARY=0
            export OPENSWIFTUI_OPENATTRIBUTESHIMS_ATTRIBUTEGRAPH
            export OPENSWIFTUI_OPENATTRIBUTESHIMS_DANCEUIGRAPH
            export OPENSWIFTUI_OPENATTRIBUTESHIMS_COMPUTE
            export OPENSWIFTUI_OPENATTRIBUTESHIMS_COMPUTE_BINARY
            shift
            ;;
        --skip-tuist-install)
            RUN_TUIST_INSTALL=false
            shift
            ;;
        --framework)
            EXPLICIT_FRAMEWORK_NAMES=true
            FRAMEWORK_NAMES+=("$2")
            shift 2
            ;;
        *)
            FRAMEWORK_NAMES+=("$1")
            shift
            ;;
    esac
done

# By default, build the full binary distribution set. Keep
# `Scripts/build_xcframework.sh OpenSwiftUI` compatible with the historical CI
# invocation while switching it to the multi-xcframework distribution.
if [ ${#FRAMEWORK_NAMES[@]} -eq 0 ] ||
   ([ "$EXPLICIT_FRAMEWORK_NAMES" = false ] &&
    [ ${#FRAMEWORK_NAMES[@]} -eq 1 ] &&
    [ "${FRAMEWORK_NAMES[0]}" = "OpenSwiftUI" ]); then
    FRAMEWORK_NAMES=("${DEFAULT_FRAMEWORK_NAMES[@]}")
fi

# Default: macosx and iphonesimulator. Compute builds also include iphoneos.
# Note: iphoneos SDK support is blocked by an AG issue. See #835.
if [ ${#SDKS[@]} -eq 0 ]; then
    if [ "${OPENSWIFTUI_OPENATTRIBUTESHIMS_COMPUTE:-0}" = "1" ]; then
        SDKS=("macosx" "iphonesimulator" "iphoneos")
        SDK_ARCHS=("" "" "")
    else
        SDKS=("macosx" "iphonesimulator")
        SDK_ARCHS=("" "")
    fi
fi

if [ "${OPENSWIFTUI_SKIP_TUIST_INSTALL:-0}" = "1" ]; then
    RUN_TUIST_INSTALL=false
fi

if ! command -v tuist >/dev/null 2>&1; then
    echo "Error: tuist is required to generate $XCODEPROJ."
    exit 1
fi

if [ "$RUN_TUIST_INSTALL" = true ]; then
    echo "Installing Tuist dependencies..."
    tuist install
else
    echo "Skipping tuist install."
fi

echo "Generating Xcode project with Tuist..."
tuist generate --no-open

if [ ! -d "$XCODEPROJ" ]; then
    echo "Error: Expected Tuist to generate $XCODEPROJ."
    exit 1
fi

if [ ! -d "$XCODEWORKSPACE" ]; then
    echo "Error: Expected Tuist to generate $XCODEWORKSPACE."
    exit 1
fi

remove_generated_macro_references() {
    local project_path="$1"
    local target_name="$2"
    local macro_name="$3"

    if [ ! -f "$project_path/project.pbxproj" ]; then
        return
    fi

    ruby - "$project_path/project.pbxproj" "$target_name" "$macro_name" <<'RUBY'
path, target_name, macro_name = ARGV
text = File.read(path)
object_pattern = /^		([A-Za-z0-9]+) \/\* [^*]+ \*\/ = \{\n.*?^		\};\n/m

dependency_names = {}
text.scan(object_pattern) do |capture|
  id = Array(capture).first
  block = Regexp.last_match(0)
  next unless block.include?("isa = PBXTargetDependency;")

  dependency_names[id] =
    block[/^			name = ([^;]+);$/, 1] ||
    block[/^			target = [A-Za-z0-9]+ \/\* ([^*]+) \*\//, 1]
end

macro_phase_ids = []
text.scan(object_pattern) do |capture|
  id = Array(capture).first
  block = Regexp.last_match(0)
  next unless block.include?("isa = PBXShellScriptBuildPhase;")
  next unless block.include?(macro_name)

  macro_phase_ids << id
end

macro_target_ids = []
text.scan(object_pattern) do |capture|
  id = Array(capture).first
  block = Regexp.last_match(0)
  next unless block.include?("isa = PBXNativeTarget;")
  next unless block.match?(/^			name = #{Regexp.escape(macro_name)};$/)

  macro_target_ids << id
end

target_dependency_ids = []
text.scan(object_pattern) do |_capture|
  block = Regexp.last_match(0)
  next unless block.include?("isa = PBXNativeTarget;")
  next unless block.match?(/^			name = #{Regexp.escape(target_name)};$/)

  dependencies = block[/^			dependencies = \(\n(.*?)^			\);$/m, 1]
  target_dependency_ids = dependencies.to_s.scan(/^\s+([A-Za-z0-9]+) \/\* PBXTargetDependency \*\/,/).flatten
  break
end

dependency_ids_to_remove = target_dependency_ids.select { |id| dependency_names[id] == macro_name }

# Tuist can leave a standalone macro PBXTargetDependency in derived projects even
# when the framework target does not list it in `dependencies`. Xcode's automatic
# scheme discovery can still pull that target into archive builds, so prune it
# when it is unambiguous.
if dependency_ids_to_remove.empty?
  matching_ids = dependency_names.select { |_id, name| name == macro_name }.keys
  dependency_ids_to_remove = matching_ids if matching_ids.one?
end

changed = false

dependency_ids_to_remove.each do |id|
  text.gsub!(/^			#{Regexp.escape(id)} \/\* PBXTargetDependency \*\/,\n/, "")
  removed = text.gsub!(/^		#{Regexp.escape(id)} \/\* PBXTargetDependency \*\/ = \{\n.*?^		\};\n/m, "")
  changed ||= !!removed
end

macro_phase_ids.each do |id|
  text.gsub!(/^				#{Regexp.escape(id)} \/\* [^*]+ \*\/,\n/, "")
  removed = text.gsub!(/^		#{Regexp.escape(id)} \/\* [^*]+ \*\/ = \{\n.*?^		\};\n/m, "")
  changed ||= !!removed
end

macro_target_ids.each do |id|
  removed = text.gsub!(/^				#{Regexp.escape(id)} \/\* #{Regexp.escape(macro_name)} \*\/,\n/, "")
  changed ||= !!removed
end

plugin_path = '$BUILD_DIR/Debug$EFFECTIVE_PLATFORM_NAME/' + macro_name + '#' + macro_name
plugin_path_pattern = Regexp.escape(plugin_path)
removed_flags = text.gsub!(
  /^(\t+)"-load-plugin-executable",\n\1"#{plugin_path_pattern}",\n/,
  ""
)
changed ||= !!removed_flags

exit unless changed

File.write(path, text)
puts "Removed #{macro_name} archive references from #{File.dirname(path)}"
RUBY
}

# The xcframework archive path sets OPENSWIFTUI_XCFRAMEWORK_BUILD, which expands
# macro usages inline where needed. Avoid forcing generated macro tool targets to
# archive for simulator SDKs, where Xcode can try to build them for the target
# platform instead of the host platform.
remove_generated_macro_references "$PROJECT_ROOT/.build/tuist-derived/OpenObservation/OpenObservation.xcodeproj" "OpenObservation" "OpenObservationMacros"
remove_generated_macro_references "$PROJECT_ROOT/../OpenObservation/OpenObservation.xcodeproj" "OpenObservation" "OpenObservationMacros"
remove_generated_macro_references "$XCODEPROJ" "OpenSwiftUICore" "OpenSwiftUIMacros"
remove_generated_macro_references "$XCODEPROJ" "OpenSwiftUICore" "OpenObservationMacros"

echo "SDKs: ${SDKS[*]}"
for i in "${!SDKS[@]}"; do
    if [ -n "${SDK_ARCHS[$i]}" ]; then
        echo "  ${SDKS[$i]}: ARCHS=${SDK_ARCHS[$i]}"
    else
        echo "  ${SDKS[$i]}: (default archs)"
    fi
done
echo "Debug mode: $DEBUG_MODE"
echo "Frameworks: ${FRAMEWORK_NAMES[*]}"

sdk_destination() {
    case "$1" in
        iphonesimulator) echo "generic/platform=iOS Simulator" ;;
        iphoneos) echo "generic/platform=iOS" ;;
        macosx) echo "generic/platform=macOS" ;;
        *) echo "generic/platform=$1" ;;
    esac
}

framework_path() {
    local archive_path="$1"
    local scheme="$2"
    echo "$archive_path/Products/Library/Frameworks/$scheme.framework"
}

xcframework_path() {
    local scheme="$1"
    echo "$PROJECT_BUILD_DIR/$scheme.xcframework"
}

framework_modules_path() {
    local framework="$1"
    if [ -d "$framework/Versions" ]; then
        echo "$framework/Versions/Current/Modules"
    else
        echo "$framework/Modules"
    fi
}

strip_release_metadata() {
    local modules_path="$1"
    if [ "$DEBUG_MODE" = false ]; then
        find "$modules_path" -name "*.abi.json" -delete
        find "$modules_path" -name "*.package.swiftinterface" -delete
        find "$modules_path" -name "*.private.swiftinterface" -delete
    fi
}

first_existing_project() {
    local candidate
    for candidate in "$@"; do
        if [ -d "$candidate" ]; then
            echo "$candidate"
            return
        fi
    done

    echo "$1"
}

project_args_for_scheme() {
    local scheme="$1"

    case "$scheme" in
        COpenSwiftUI|OpenSwiftUI|OpenSwiftUICore|OpenSwiftUI_SPI|OpenSwiftUISymbolDualTestsSupport)
            echo "-workspace" "$XCODEWORKSPACE"
            ;;
        _AttributeGraphDeviceSwiftShims)
            echo "-project" "$(first_existing_project "$PROJECT_ROOT/../DarwinPrivateFrameworks/DarwinPrivateFrameworks.xcodeproj" "$PROJECT_ROOT/.build/tuist-derived/DarwinPrivateFrameworks/DarwinPrivateFrameworks.xcodeproj")"
            ;;
        OpenAttributeGraphShims)
            echo "-project" "$(first_existing_project "$PROJECT_ROOT/../OpenAttributeGraph/OpenAttributeGraph.xcodeproj" "$PROJECT_ROOT/.build/tuist-derived/OpenAttributeGraph/OpenAttributeGraph.xcodeproj")"
            ;;
        OpenCoreGraphics|OpenCoreGraphicsShims|OpenQuartzCore|OpenQuartzCoreShims)
            echo "-project" "$(first_existing_project "$PROJECT_ROOT/../OpenCoreGraphics/OpenCoreGraphics.xcodeproj" "$PROJECT_ROOT/.build/tuist-derived/OpenCoreGraphics/OpenCoreGraphics.xcodeproj")"
            ;;
        OpenObservation|OpenObservationCxx)
            echo "-project" "$(first_existing_project "$PROJECT_ROOT/../OpenObservation/OpenObservation.xcodeproj" "$PROJECT_ROOT/.build/tuist-derived/OpenObservation/OpenObservation.xcodeproj")"
            ;;
        OpenRenderBoxShims)
            echo "-project" "$(first_existing_project "$PROJECT_ROOT/../OpenRenderBox/OpenRenderBox.xcodeproj" "$PROJECT_ROOT/.build/tuist-derived/OpenRenderBox/OpenRenderBox.xcodeproj")"
            ;;
        SymbolLocator)
            echo "-project" "$PROJECT_ROOT/.build/tuist-derived/SymbolLocator/SymbolLocator.xcodeproj"
            ;;
        *)
            echo "Error: No Xcode project mapping for $scheme." >&2
            exit 1
            ;;
    esac
}

build_framework() {
    local sdk="$1"
    local destination="$2"
    local scheme="$3"
    local archs="$4"

    local archive_path="$PROJECT_BUILD_DIR/$scheme-$sdk.xcarchive"
    local project_args
    read -r -a project_args <<<"$(project_args_for_scheme "$scheme")"

    rm -rf "$archive_path"

    local xcodebuild_args=(
        archive
        "${project_args[@]}"
        -scheme "$scheme"
        -configuration Release
        -archivePath "$archive_path"
        -sdk "$sdk"
        -destination "$destination"
        -derivedDataPath "$DERIVED_DATA_PATH"
        -skipPackagePluginValidation
        -skipMacroValidation
        INSTALL_PATH=Library/Frameworks
        SKIP_INSTALL=NO
        BUILD_LIBRARY_FOR_DISTRIBUTION=YES
        SWIFT_EMIT_MODULE_INTERFACE=YES
        "SWIFT_ACTIVE_COMPILATION_CONDITIONS=\$(inherited) OPENSWIFTUI_XCFRAMEWORK_BUILD"
        ENABLE_USER_SCRIPT_SANDBOXING=NO
    )

    if [ -n "$archs" ]; then
        xcodebuild_args+=("ARCHS=${archs//,/ }")
    fi

    xcodebuild "${xcodebuild_args[@]}"

    local framework
    framework="$(framework_path "$archive_path" "$scheme")"
    if [ ! -d "$framework" ]; then
        echo "Error: Archive did not contain $framework."
        exit 1
    fi

    local modules_path
    modules_path="$(framework_modules_path "$framework")"
    mkdir -p "$modules_path"

    if [ "$sdk" = "macosx" ]; then
        rm -rf "$framework/Modules"
        ln -s Versions/Current/Modules "$framework/Modules"
    fi

    strip_release_metadata "$modules_path"
}

create_xcframework() {
    local scheme="$1"
    local output_path
    output_path="$(xcframework_path "$scheme")"

    rm -rf "$output_path"

    local create_args=()
    for sdk in "${SDKS[@]}"; do
        create_args+=(-framework "$(framework_path "$PROJECT_BUILD_DIR/$scheme-$sdk.xcarchive" "$scheme")")
    done

    xcodebuild -create-xcframework "${create_args[@]}" -output "$output_path"
}

copy_debug_symbols() {
    local scheme="$1"

    if [ "$DEBUG_MODE" = false ]; then
        return
    fi

    local sdk
    for sdk in "${SDKS[@]}"; do
        local local_dsym_dir=""
        case "$sdk" in
            iphonesimulator) local_dsym_dir=$(ls -d "$(xcframework_path "$scheme")"/ios-*simulator 2>/dev/null | head -1) ;;
            iphoneos) local_dsym_dir=$(ls -d "$(xcframework_path "$scheme")"/ios-arm64 2>/dev/null | head -1) ;;
            macosx) local_dsym_dir=$(ls -d "$(xcframework_path "$scheme")"/macos-* 2>/dev/null | head -1) ;;
        esac

        if [ -n "$local_dsym_dir" ] && [ -d "$PROJECT_BUILD_DIR/$scheme-$sdk.xcarchive/dSYMs" ]; then
            cp -R "$PROJECT_BUILD_DIR/$scheme-$sdk.xcarchive/dSYMs" "$local_dsym_dir/"
        fi
    done
}

rm -rf "$DERIVED_DATA_PATH"
mkdir -p "$PROJECT_BUILD_DIR"

for scheme in "${FRAMEWORK_NAMES[@]}"; do
    echo "Building $scheme..."
    for i in "${!SDKS[@]}"; do
        build_framework "${SDKS[$i]}" "$(sdk_destination "${SDKS[$i]}")" "$scheme" "${SDK_ARCHS[$i]}"
    done
    create_xcframework "$scheme"
    copy_debug_symbols "$scheme"
    echo "Created $(xcframework_path "$scheme")"
done

if [ "$DEBUG_MODE" = false ]; then
    echo "Skipping dSYMs. Pass --debug to include them in the XCFrameworks."
else
    echo "Copied dSYMs into the XCFrameworks."
fi

echo "Created ${#FRAMEWORK_NAMES[@]} XCFrameworks in $PROJECT_BUILD_DIR."
