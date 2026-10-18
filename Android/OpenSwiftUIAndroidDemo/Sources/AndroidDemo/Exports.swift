import OpenSwiftUIAndroidDemo

// Retain the host object file, including the JNI entry point loaded by MainActivity.
@_cdecl("OpenSwiftUIAndroidDemoBootstrap")
public func bootstrap() {
    OpenSwiftUIAndroidDemoConfigureUIKit()
}
