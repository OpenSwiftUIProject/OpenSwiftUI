## OpenSwiftUISymbolDualTests

Test non-public API of SwiftUI via SymbolLocator.

```c
DEFINE_SL_STUB_SLF(OpenSwiftUITestStub_CGSizeHasZero, SwiftUI, $sSo6CGSizeV7SwiftUIE7hasZeroSbvg);
```

```swift
import SwiftUI

extension CGSize {
    var swiftUI_hasZero: Bool {
        @_silgen_name("OpenSwiftUITestStub_CGSizeHasZero")
        get
    }
}

let size = CGSize(width: 0, height: 0)
#expect(size.swiftUI_hasZero == true)
```
