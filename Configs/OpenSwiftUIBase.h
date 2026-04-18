// Proxy header for Tuist/Xcode builds.
// Forwards to the real OpenSwiftUIBase.h in OpenSwiftUI_SPI without putting the
// SPI root directory on header search paths (which would trigger Clang
// auto-discovery of the SPM module.modulemap with conflicting sub-modules).
#include "../Sources/OpenSwiftUI_SPI/OpenSwiftUIBase.h"
