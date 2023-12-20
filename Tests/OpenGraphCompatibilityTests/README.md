## OpenSwiftUICompatibilityTests

Test public API of OpenGraph and run it against with AttributeGraph on Apple Platform.

```swift
#if OPENGRAPH_COMPATIBILITY_TEST
import AttributeGraph
#else
import OpenGraph
#endif
```
