#!/usr/bin/env bash
set -euo pipefail

usage() {
    cat <<'USAGE'
Usage: Scripts/android-demo.sh [options]

Build, install, and launch the Android controls demo (arm64, API 28+).
  --prepare          Resolve remote sources only; also prepares Android Studio
  --build-only       Build the APK without connecting to a device
  --no-build         Install and launch the existing APK
  --avd NAME         Start or reuse this installed arm64 emulator
  --serial SERIAL    Use this adb device (or set ANDROID_SERIAL)
  --demo NAME        breathing (default), text, or static
  --print-tree       Capture DisplayList output in the app's files/display-list.log
  -h, --help         Show this help

Requires Swift/Swift Android SDK 6.3.2, NDK r27d, Android SDK 35, and JDK 17+.
See Android/OpenSwiftUIAndroidDemo/README.md for installation and overrides.
USAGE
}

mode=run
no_build=0
avd=
serial="${ANDROID_SERIAL:-}"
demo=breathing
print_tree=false
while [[ $# -gt 0 ]]; do
    case "$1" in
        --prepare|--build-only) mode="${1#--}"; shift ;;
        --no-build) no_build=1; shift ;;
        --avd|--serial|--demo)
            [[ $# -ge 2 && "$2" != --* ]] || { printf 'Missing value for %s\n' "$1" >&2; exit 2; }
            case "$1" in --avd) avd="$2" ;; --serial) serial="$2" ;; --demo) demo="$2" ;; esac
            shift 2 ;;
        --print-tree) print_tree=true; shift ;;
        -h|--help) usage; exit 0 ;;
        *) printf 'Unknown option: %s\n' "$1" >&2; usage >&2; exit 2 ;;
    esac
done
[[ "$mode" == run || "$no_build" == 0 ]] || { printf '%s\n' '--no-build cannot be combined with --prepare/--build-only.' >&2; exit 2; }
[[ -z "$avd" || -z "$serial" ]] || { printf '%s\n' 'Choose either --avd or --serial/ANDROID_SERIAL.' >&2; exit 2; }
case "$demo" in breathing|text|static) ;; *) printf 'Unknown demo: %s\n' "$demo" >&2; exit 2 ;; esac

source "$(dirname "${BASH_SOURCE[0]}")/Android/common.sh"
apk="$ANDROID_PROJECT/app/build/outputs/apk/debug/app-arm64-v8a-debug.apk"
if [[ "$no_build" == 0 ]]; then
    resolve_android
    if [[ "$mode" == prepare ]]; then
        printf 'Dependencies ready. Android Studio project: %s\n' "$ANDROID_PROJECT"
        exit 0
    fi
    [[ -f "$ANDROID_HOME/platforms/android-35/android.jar" ]] || fail 'Install platforms;android-35 with Android SDK Manager, or set ANDROID_HOME.'
    command -v java >/dev/null 2>&1 || fail 'Install JDK 17+ or set JAVA_HOME to Android Studio JBR.'
    bash "$ANDROID_PROJECT/gradlew" \
        -p "$ANDROID_PROJECT" --no-daemon :app:assembleDebug
fi
[[ -f "$apk" ]] || fail "APK not found: $apk"
printf 'APK: %s\n' "$apk"
[[ "$mode" != build-only ]] || exit 0
command -v adb >/dev/null 2>&1 || fail 'Install Android SDK platform-tools, or set ANDROID_HOME.'

find_avd() {
    local candidate name
    while read -r candidate; do
        name="$(adb -s "$candidate" emu avd name 2>/dev/null | tr -d '\r' | head -n 1)"
        if [[ "$name" == "$avd" ]]; then printf '%s' "$candidate"; return; fi
    done < <(adb devices | awk '$1 ~ /^emulator-/ && $2 == "device" {print $1}')
    return 0
}

if [[ -n "$avd" ]]; then
    command -v emulator >/dev/null 2>&1 || fail 'Install Android SDK emulator.'
    emulator -list-avds | grep -Fxq "$avd" || fail "Unknown AVD: $avd"
    serial="$(find_avd)"
    if [[ -z "$serial" ]]; then
        mkdir -p "$ANDROID_BUILD"
        nohup emulator -avd "$avd" -no-snapshot-save > "$ANDROID_BUILD/emulator.log" 2>&1 &
        emulator_pid=$!
        deadline=$((SECONDS + 180))
        until [[ -n "$serial" ]]; do
            kill -0 "$emulator_pid" 2>/dev/null || fail "Emulator exited. See $ANDROID_BUILD/emulator.log"
            [[ $SECONDS -lt $deadline ]] || fail "Timed out starting $avd. See $ANDROID_BUILD/emulator.log"
            sleep 2
            serial="$(find_avd)"
        done
    fi
elif [[ -z "$serial" ]]; then
    devices=()
    while read -r candidate; do devices+=("$candidate"); done < <(adb devices | awk '$2 == "device" {print $1}')
    [[ ${#devices[@]} -eq 1 ]] || fail 'Connect one arm64 device, or select --serial SERIAL / --avd NAME.'
    serial="${devices[0]}"
fi

adb_device=(adb -s "$serial")
deadline=$((SECONDS + 180))
until [[ "$("${adb_device[@]}" shell getprop sys.boot_completed 2>/dev/null | tr -d '\r')" == 1 ]]; do
    [[ $SECONDS -lt $deadline ]] || fail "Timed out waiting for $serial to boot."
    sleep 2
done
abi="$("${adb_device[@]}" shell getprop ro.product.cpu.abilist | tr -d '\r')"
[[ ",$abi," == *,arm64-v8a,* ]] || fail "This APK requires arm64-v8a; $serial supports $abi."
api="$("${adb_device[@]}" shell getprop ro.build.version.sdk | tr -d '\r')"
[[ "$api" =~ ^[0-9]+$ && "$api" -ge 28 ]] || fail "This APK requires API 28+; got $api."
"${adb_device[@]}" install -r "$apk"
"${adb_device[@]}" shell am start -S -W -n org.openswiftui.androiddemo/.MainActivity \
    --es demo "$demo" --ez printTree "$print_tree"
sleep 2
"${adb_device[@]}" shell pidof org.openswiftui.androiddemo >/dev/null || fail "App exited; inspect adb -s $serial logcat -d -b crash."
printf 'Running on %s.\n' "$serial"
if [[ "$serial" == emulator-* ]]; then
    printf 'Stop emulator: adb -s %s emu kill\n' "$serial"
fi
