# ViewDebug 完整实现计划

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 实现完整的 `_ViewDebug` 数据收集管线，使 Xcode Debug View Hierarchy 能看到 OpenSwiftUI 的视图层级。

**Architecture:** 分三层实现——(1) OpenAttributeGraph 添加 tree reading Swift API；(2) OpenSwiftUICore 实现 `appendDebugData` 核心遍历逻辑；(3) OpenSwiftUI 的 CoreGlue 层实现 `updateData` 处理 displayList。整体数据流为：`makeViewDebugData()` → `viewDebugData()` → `makeDebugData(subgraph:)` → `appendDebugData(from:to:)` → JSON 序列化 → Xcode 消费。

**Tech Stack:** Swift, OpenAttributeGraph (C++/Swift), OpenSwiftUICore, OpenSwiftUI

---

## 文件结构

### OpenAttributeGraph 仓库（需修改）
| 文件 | 职责 |
|------|------|
| `Sources/OpenAttributeGraph/Graph/Subgraph.swift` | 添加 tree reading Swift API（treeRoot, TreeElement, TreeValue 迭代器） |

### OpenSwiftUI 仓库
| 文件 | 职责 |
|------|------|
| `Sources/OpenSwiftUICore/View/ViewDebug.swift` | 实现 `appendDebugData`，修复 `treeRoot()` stub |
| `Sources/OpenSwiftUICore/Util/CoreGlue.swift` | 取消注释 `updateData`，定义基类方法 |
| `Sources/OpenSwiftUI/Util/OpenSwiftUIGlue.swift` | override `updateData`，读取 DisplayList |

### 依赖关系
- Task 2 依赖 Task 1（需要 OAG tree reading API）
- Task 3 依赖 Task 2（需要 `treeRoot()` 和 `appendDebugData` 签名）
- Task 4 可与 Task 2/3 并行（仅需 `OAGTreeValue` 类型和 `_ViewDebug.Data`）
- Task 5 依赖 Task 3 和 Task 4（端到端集成验证）
- Task 6 依赖 Task 5（Xcode 测试）

---

## Task 1: OpenAttributeGraph 添加 Tree Reading Swift API

**Depends on:** 无

**Files:**
- Modify: `<OAG>/Sources/OpenAttributeGraph/Graph/Subgraph.swift`

C++ 层的 tree reading API 已全部实现（`OAGSubgraph.cpp:382-448`），但 Swift 层缺少封装。需要添加 `treeRoot()`、`TreeElement`、`TreeValue` 的 Swift 迭代器。

C API 参考（已有 `OAG_REFINED_FOR_SWIFT`，Swift 中以 `__` 前缀导入）：
```c
OAGTreeElement OAGSubgraphGetTreeRoot(const void * subgraph);   // → __OAGSubgraphGetTreeRoot
uint32_t OAGTreeElementGetFlags(OAGTreeElement element);         // → __OAGTreeElementGetFlags
uintptr_t OAGTreeElementGetType(OAGTreeElement element);         // → __OAGTreeElementGetType
uint32_t OAGTreeElementGetValue(OAGTreeElement element);         // → __OAGTreeElementGetValue
OAGTreeChildIterator OAGTreeElementMakeChildIterator(OAGTreeElement element);  // → __OAGTreeElementMakeChildIterator
OAGTreeElement OAGTreeElementGetNextChild(OAGTreeChildIterator *);             // → __OAGTreeElementGetNextChild
OAGTreeValueIterator OAGTreeElementMakeValueIterator(OAGTreeElement element);  // → __OAGTreeElementMakeValueIterator
OAGTreeValue OAGTreeElementGetNextValue(OAGTreeValueIterator *);               // → __OAGTreeElementGetNextValue
const char * OAGTreeValueGetKey(OAGTreeValue value);                           // → __OAGTreeValueGetKey
uint32_t OAGTreeValueGetValue(OAGTreeValue value);                             // → __OAGTreeValueGetValue
```

类型定义：`OAGTreeElement = uint32_t`, `OAGTreeValue = uint32_t`（0 表示无效/终止）。

**注意**: `OAGSubgraphGetTreeRoot` 的参数类型是 `const void *`，而不是 `OAGSubgraphRef`。需要将 `Subgraph`（即 `OAGSubgraphRef`，CF-bridged 类型）转换为 `UnsafeRawPointer`。可能需要使用 `Unmanaged.passUnretained(self).toOpaque()` 或直接通过 `unsafeBitCast`。编译时验证 Swift 编译器是否自动桥接。

- [ ] **Step 1: 在 Subgraph.swift 添加 treeRoot 方法和 TreeElement/TreeValue 封装**

在 `Subgraph.swift` 末尾的 tree element 相关 extension 之后，添加 tree reading API：

```swift
// MARK: - Tree Reading APIs

extension Subgraph {
    /// Returns the root tree element for this subgraph.
    /// Returns 0 if no tree was recorded.
    public func treeRoot() -> OAGTreeElement {
        // OAGSubgraphGetTreeRoot takes `const void *` — Subgraph (OAGSubgraphRef)
        // may need explicit bridging if the compiler doesn't auto-bridge.
        __OAGSubgraphGetTreeRoot(self)
    }
}

extension OAGTreeElement {
    /// The flags associated with this tree element.
    /// Bit 0 (0x1) = viewList element (children only, no own data).
    public var flags: UInt32 {
        __OAGTreeElementGetFlags(self)
    }

    /// The type metadata pointer for the view/modifier stored in this element.
    /// Returns nil if no type is recorded.
    public var type: UnsafeRawPointer? {
        let raw = __OAGTreeElementGetType(self)
        return raw == 0 ? nil : UnsafeRawPointer(bitPattern: raw)
    }

    /// The attribute ID for the view value stored in this element.
    public var value: AnyAttribute {
        AnyAttribute(rawValue: __OAGTreeElementGetValue(self))
    }

    /// Iterates over child elements.
    public func forEachChild(_ body: (OAGTreeElement) -> Void) {
        var iterator = __OAGTreeElementMakeChildIterator(self)
        while true {
            let child = __OAGTreeElementGetNextChild(&iterator)
            guard child != 0 else { break }
            body(child)
        }
    }

    /// Iterates over tree values attached to this element.
    public func forEachValue(_ body: (OAGTreeValue) -> Void) {
        var iterator = __OAGTreeElementMakeValueIterator(self)
        while true {
            let treeValue = __OAGTreeElementGetNextValue(&iterator)
            guard treeValue != 0 else { break }
            body(treeValue)
        }
    }
}

extension OAGTreeValue {
    /// The string key for this tree value (e.g. "transform", "position", "size").
    public var key: UnsafePointer<CChar>? {
        __OAGTreeValueGetKey(self)
    }

    /// The attribute ID for this tree value.
    public var attribute: AnyAttribute {
        AnyAttribute(rawValue: __OAGTreeValueGetValue(self))
    }
}
```

- [ ] **Step 2: 验证编译**

```bash
cd <OAG> && swift build 2>&1 | xcsift
```

Expected: BUILD SUCCEEDED。如果 `__OAGSubgraphGetTreeRoot(self)` 编译失败（`const void *` 桥接问题），改为：
```swift
public func treeRoot() -> OAGTreeElement {
    let ptr = Unmanaged.passUnretained(self as AnyObject).toOpaque()
    return __OAGSubgraphGetTreeRoot(ptr)
}
```

- [ ] **Step 3: Commit**

```bash
git add Sources/OpenAttributeGraph/Graph/Subgraph.swift
git commit -m "Add tree reading Swift API for ViewDebug support"
```

---

## Task 2: 修复 Subgraph.treeRoot() stub 并实现 makeDebugData

**Depends on:** Task 1

**Files:**
- Modify: `Sources/OpenSwiftUICore/View/ViewDebug.swift:206-217`

当前 `Subgraph.treeRoot()` 始终返回 `nil`（FIXME stub），`makeDebugData` 因此永远返回空数组。

反编译参考（`makeDebugData` at 0x1e7c18ae0）：
```
v3 = emptyArray
TreeRoot = AGSubgraphGetTreeRoot(subgraph)
if TreeRoot != 0:
    appendDebugData(from: TreeRoot, to: &result)
    return result
return emptyArray
```

- [ ] **Step 1: 删除 Subgraph stub，修改 makeDebugData 使用真实 treeRoot**

在 `ViewDebug.swift` 中：

1. 删除 FIXME stub（第 206-208 行）：
```swift
// 删除:
// extension Subgraph {
//     func treeRoot() -> Int? { nil }
// }
```

2. 修改 `makeDebugData`（第 210-217 行）：
```swift
extension _ViewDebug {
    package static func makeDebugData(subgraph: Subgraph) -> [_ViewDebug.Data] {
        var result: [_ViewDebug.Data] = []
        let rootElement = subgraph.treeRoot()
        if rootElement != 0 {
            appendDebugData(from: rootElement, to: &result)
        }
        return result
    }
}
```

3. 同时更新 `appendDebugData` 的签名（保持 stub body 以便编译）：
```swift
private static func appendDebugData(from element: OAGTreeElement, to result: inout [_ViewDebug.Data]) {
    // TODO: Implement in Task 3
}
```

- [ ] **Step 2: 验证编译**

```bash
swift build 2>&1 | xcsift
```

Expected: BUILD SUCCEEDED（appendDebugData 是空函数，但签名正确）

- [ ] **Step 3: Commit**

```bash
git add Sources/OpenSwiftUICore/View/ViewDebug.swift
git commit -m "Replace Subgraph.treeRoot() stub with real OAG call"
```

---

## Task 3: 实现 appendDebugData 核心逻辑

**Depends on:** Task 2

**Files:**
- Modify: `Sources/OpenSwiftUICore/View/ViewDebug.swift`

这是整个 ViewDebug 的核心函数。根据反编译结果（0x1e7c18b28，约 0xb94 字节）。

### 算法概述

1. **viewList 元素**（flags & 1）：不创建自己的 Data，直接递归遍历所有子节点
2. **无效元素**（attribute == .nil 或 type == nil）：同上，直接递归子节点
3. **正常元素**：
   a. 创建 `_ViewDebug.Data()`
   b. 设置 `.type` = 元素的 metatype（使用 `Self.properties` 静态属性检查）
   c. ~~设置 `.value` = 通过动态类型 AGGraphGetValue 读取~~ **Phase 2**
   d. 遍历 tree values，根据 key 字符串匹配（使用 `strcmp` 做 C 字符串比较以避免 String 分配）
   e. 对每个匹配的 key，先检查 `treeValue.attribute != .nil`，再调用 `OAGGraphGetValue`
   f. 递归遍历子节点，填充 childData
   g. 将此 Data 追加到 result 数组

### 关键类型映射（Property rawValue → dictionary key → Properties bit）
| Property | rawValue | bit mask | tree key | Value Type |
|----------|----------|----------|----------|------------|
| .type | 0 | 0x1 | (from element type) | Any.Type |
| .value | 1 | 0x2 | (from element value) | Any (dynamic) — **Phase 2** |
| .transform | 2 | 0x4 | "transform" | ViewTransform |
| .position | 3 | 0x8 | "position" | CGPoint |
| .size | 4 | 0x10 | "size" | CGSize |
| .environment | 5 | 0x20 | "environment" | EnvironmentValues |
| .phase | 6 | 0x40 | "phase" | _GraphInputs.Phase |
| .layoutComputer | 7 | 0x80 | "layoutComputer" | LayoutComputer |
| .displayList | 8 | 0x100 | "displayList" | (via CoreGlue) |

### OAGGraphGetValue 使用方式

Swift 泛型封装签名（`Attribute.swift:305-309`）：
```swift
@_silgen_name("OAGGraphGetValue")
func OAGGraphGetValue<Value>(_ attribute: AnyAttribute, options: OAGValueOptions = [], type: Value.Type = Value.self) -> OAGValue
```

`OAGValue` 结构体（`OAGValue.h`）：
```c
typedef struct OAGValue {
    const void *value;  // → UnsafeRawPointer in Swift (non-optional)
    OAGChangedValueFlags flags;
} OAGValue;
```

调用模式：`OAGGraphGetValue(attribute, type: CGSize.self)` → 返回 `OAGValue`，通过 `.value` 指针读取实际数据。

**注意**：`OAGValue.value` 是 `UnsafeRawPointer`（非 Optional），不需要 nil 检查。但 `treeValue.attribute` 可能为 `.nil`（rawValue 0），必须在调用 `OAGGraphGetValue` 前检查。

- [ ] **Step 1: 实现 appendDebugData（Phase 1: 已知类型属性，跳过 .value）**

替换 `ViewDebug.swift` 中的 `appendDebugData` stub：

```swift
private static func appendDebugData(from element: OAGTreeElement, to result: inout [_ViewDebug.Data]) {
    // viewList elements (flags & 1): just recurse into children, no own data
    if element.flags & 1 != 0 {
        element.forEachChild { child in
            appendDebugData(from: child, to: &result)
        }
        return
    }

    // Invalid elements (nil attribute or no type): recurse into children
    let attribute = element.value
    guard attribute != .nil, let typePointer = element.type else {
        element.forEachChild { child in
            appendDebugData(from: child, to: &result)
        }
        return
    }

    // Create debug data for this element
    var debugData = _ViewDebug.Data()

    // Set .type property (metatype of the view/modifier)
    let anyType = unsafeBitCast(typePointer, to: Any.Type.self)
    if Self.properties.contains(.type) {
        debugData.data[.type] = anyType
    }

    // TODO: Phase 2 — Set .value property using dynamic type projection
    // Requires VWT-based Any boxing with runtime type metadata.

    // Process tree values (use strcmp for C string comparison to avoid allocation)
    element.forEachValue { treeValue in
        guard let keyPtr = treeValue.key else { return }
        guard treeValue.attribute != .nil else { return }
        let attr = treeValue.attribute

        if Self.properties.contains(.environment) && strcmp(keyPtr, "environment") == 0 {
            let oagValue = OAGGraphGetValue(attr, type: EnvironmentValues.self)
            debugData.data[.environment] = oagValue.value
                .assumingMemoryBound(to: EnvironmentValues.self).pointee

        } else if Self.properties.contains(.position) && strcmp(keyPtr, "position") == 0 {
            let oagValue = OAGGraphGetValue(attr, type: CGPoint.self)
            debugData.data[.position] = oagValue.value
                .assumingMemoryBound(to: CGPoint.self).pointee

        } else if Self.properties.contains(.size) && strcmp(keyPtr, "size") == 0 {
            let oagValue = OAGGraphGetValue(attr, type: CGSize.self)
            debugData.data[.size] = oagValue.value
                .assumingMemoryBound(to: CGSize.self).pointee

        } else if Self.properties.contains(.phase) && strcmp(keyPtr, "phase") == 0 {
            let oagValue = OAGGraphGetValue(attr, type: _GraphInputs.Phase.self)
            debugData.data[.phase] = oagValue.value
                .assumingMemoryBound(to: _GraphInputs.Phase.self).pointee

        } else if Self.properties.contains(.transform) && strcmp(keyPtr, "transform") == 0 {
            let oagValue = OAGGraphGetValue(attr, type: ViewTransform.self)
            debugData.data[.transform] = oagValue.value
                .assumingMemoryBound(to: ViewTransform.self).pointee

        } else if Self.properties.contains(.layoutComputer) && strcmp(keyPtr, "layoutComputer") == 0 {
            let oagValue = OAGGraphGetValue(attr, type: LayoutComputer.self)
            debugData.data[.layoutComputer] = oagValue.value
                .assumingMemoryBound(to: LayoutComputer.self).pointee

        } else if Self.properties.contains(.displayList) && strcmp(keyPtr, "displayList") == 0 {
            CoreGlue.shared.updateData(&debugData, value: treeValue)
        }
    }

    // Recurse into children
    element.forEachChild { child in
        appendDebugData(from: child, to: &debugData.childData)
    }

    result.append(debugData)
}
```

**关键改动 vs 初版**:
- 使用 `Self.properties` 明确引用静态属性
- 使用 `strcmp` 而非 `String(cString:)` 避免堆分配
- 添加 `treeValue.attribute != .nil` 防护
- 移除 `.value` 属性处理（Phase 2）
- `OAGValue.value` 直接使用（非 Optional）

- [ ] **Step 2: 确认 `OAGGraphGetValue` import 可用**

`OAGGraphGetValue` 通过 `@_silgen_name` 定义在 `OpenAttributeGraph` 模块中。OpenSwiftUICore 通过 `import OpenAttributeGraphShims` 访问 OAG。需要确认 `OAGGraphGetValue` 这个泛型函数在 `OpenSwiftUICore` 中是否可见。如果不可见，可能需要在 OpenSwiftUICore 中添加类似的 `@_silgen_name` 声明，或通过 shims 重新导出。

```bash
# 检查 OpenAttributeGraphShims 是否导出 OAGGraphGetValue
rg "OAGGraphGetValue" Sources/OpenAttributeGraphShims/ || echo "not found in shims"
```

- [ ] **Step 3: 验证编译**

```bash
swift build 2>&1 | xcsift
```

Expected: BUILD SUCCEEDED。如果 `OAGGraphGetValue` 不可见，需要在 ViewDebug.swift 中添加：
```swift
@_silgen_name("OAGGraphGetValue")
private func _graphGetValue<Value>(_ attribute: AnyAttribute, options: OAGValueOptions = [], type: Value.Type = Value.self) -> OAGValue
```

- [ ] **Step 4: Commit**

```bash
git add Sources/OpenSwiftUICore/View/ViewDebug.swift
git commit -m "Implement appendDebugData for ViewDebug tree traversal"
```

---

## Task 4: 实现 CoreGlue.updateData

**Depends on:** Task 1（需要 `OAGTreeValue` 类型）。可与 Task 2/3 并行开发。

**Files:**
- Modify: `Sources/OpenSwiftUICore/Util/CoreGlue.swift:100-102`
- Modify: `Sources/OpenSwiftUI/Util/OpenSwiftUIGlue.swift`

反编译 `SwiftUIGlue.updateData` (0x1B0A35B2C) 的逻辑：
1. 从 `OAGTreeValue` 获取 attribute (`AGTreeValueGetValue`)
2. 用 `AGGraphGetValue` 读取值（类型为 `DisplayList`）
3. 包装为 `Any`，存入 `data[.displayList]`

**注意**: 当前被注释掉的代码（`CoreGlue.swift:100`）使用的参数类型名是 `TreeValue`，而非 `OAGTreeValue`。需要确认 `OpenAttributeGraphShims` 模块是否导出了 `OAGTreeValue` 类型。如果 `OAGTreeValue` 是 `typedef uint32_t`，它可能以 `UInt32` 出现在 Swift 中，或者通过 module map 导出为 `OAGTreeValue`。

- [ ] **Step 1: 确认 OAGTreeValue 类型在 OpenSwiftUICore 中的可见性**

```bash
# 检查 OAGTreeValue 在 shims 中的导出情况
rg "OAGTreeValue|TreeValue" Sources/OpenSwiftUICore/ --glob '*.swift'
```

如果 `OAGTreeValue` 不可见，需要添加 typealias：
```swift
package typealias TreeValue = OAGTreeValue  // or UInt32
```

- [ ] **Step 2: 取消注释 CoreGlue.updateData 并定义基类方法**

在 `CoreGlue.swift:100-102` 中，将注释替换为实际代码：

```swift
open func updateData(_ data: inout _ViewDebug.Data, value: OAGTreeValue) {
    // Base class does nothing; subclass overrides to handle displayList
}
```

- [ ] **Step 3: 在 OpenSwiftUIGlue 中 override updateData**

在 `OpenSwiftUIGlue.swift` 中添加：

```swift
override func updateData(_ data: inout _ViewDebug.Data, value: OAGTreeValue) {
    let attribute = value.attribute
    guard attribute != .nil else { return }
    let oagValue = OAGGraphGetValue(attribute, type: DisplayList.self)
    let displayList = oagValue.value.assumingMemoryBound(to: DisplayList.self).pointee
    data.data[.displayList] = displayList
}
```

- [ ] **Step 4: 验证编译**

```bash
swift build 2>&1 | xcsift
```

- [ ] **Step 5: Commit**

```bash
git add Sources/OpenSwiftUICore/Util/CoreGlue.swift Sources/OpenSwiftUI/Util/OpenSwiftUIGlue.swift
git commit -m "Implement CoreGlue.updateData for displayList debug data"
```

---

## Task 5: 确认 Xcode Debug Hierarchy 触发机制

**Depends on:** Task 3 + Task 4

**Files:** 可能需要修改 `NSHostingView.swift` / `UIHostingView.swift` 中的 `makeViewDebugData()`

### 已知信息
1. Xcode 通过 ObjC selector `makeViewDebugData` 调用（已在 `XcodeViewDebugDataProvider` 协议中定义）
2. `NSHostingView`/`_UIHostingView` 已实现此方法
3. `_ViewDebug.properties` 必须非空才会调用 `Subgraph.setShouldRecordTree()`
4. Tree recording 只在 `instantiateOutputs()` 期间（graph 构建时）发生

### 需要验证的问题

- [ ] **Step 1: 确认 Xcode 是通过 selector 名还是 protocol conformance 发现 debug data provider**

OpenSwiftUI 的 protocol ObjC 名是 `_TtP12OpenSwiftUI26XcodeViewDebugDataProvider_`（模块名不同于 SwiftUI 的 `_TtP7SwiftUI26XcodeViewDebugDataProvider_`）。如果 Xcode 通过 protocol conformance 检查，则找不到。如果通过 selector name `makeViewDebugData`，则能找到。

验证方式：
- 在 NSHostingView 上用 `responds(to: Selector("makeViewDebugData"))` 检查
- 或直接在 Xcode 中 capture view hierarchy 测试
- 或反编译 Xcode 的 view debugging 插件

- [ ] **Step 2: 确认 `_ViewDebug.properties` 的激活方式**

当前代码从 `OPENSWIFTUI_VIEW_DEBUG` 环境变量读取。如果不设置此变量，properties 为空，tree 不会被 recorded。

**方案 A**（推荐）：在 `makeViewDebugData()` 中，如果 properties 为空，临时设置为 `.all`，强制完整 re-instantiation 并 record tree。

**关键细节**: 仅设置 `properties` 和 `setShouldRecordTree()` 不够——tree recording 发生在 `makeDebuggableView` 调用期间（即 graph instantiation 过程中的 `beginTreeElement`/`endTreeElement`）。必须触发完整的 view tree re-instantiation，不仅仅是 `updateOutputs()`。

需要验证：
- `ViewGraph` 是否有 `invalidateAll()` 或类似方法强制 re-instantiation
- 或者是否可以通过 invalidate rootView 来触发整个 tree 的重建

```swift
package func makeViewDebugData() -> Data? {
    Update.ensure {
        if _ViewDebug.properties.isEmpty {
            _ViewDebug.properties = .all
            Subgraph.setShouldRecordTree()
            // Need to force complete re-instantiation here
            // Exact API TBD after investigation
        }
        _ViewDebug.serializedData(viewGraph.viewDebugData())
    }
}
```

**方案 B**：始终启用 tree recording（性能影响较大，不推荐）。

**方案 C**：依赖用户设置环境变量 `OPENSWIFTUI_VIEW_DEBUG=4294967295`（0xFFFFFFFF = .all）。

- [ ] **Step 3: 记录决策并实现选定方案**

根据验证结果选择最合适的方案并实现。

- [ ] **Step 4: Commit**

---

## Task 6: 端到端测试

**Depends on:** Task 5

**Files:**
- Modify: `Tests/OpenSwiftUICoreTests/View/Debug/ViewDebugTests.swift`（添加集成测试）
- 使用 Example app 进行 Xcode Debug View Hierarchy 实际测试

- [ ] **Step 1: 添加 makeDebugData 非空验证测试**

在已有的 `ViewDebugTests.swift` 中添加一个测试，验证 `makeDebugData` 在 tree recording 开启时返回非空数组且包含 `.type` 属性。这不需要 Xcode——纯单元测试。

- [ ] **Step 2: 设置环境变量并运行 Example app**

在 Xcode scheme 中设置环境变量：
```
OPENSWIFTUI_VIEW_DEBUG = 4294967295
```

- [ ] **Step 3: 在 Xcode 中执行 Debug → Capture View Hierarchy**

验证能否看到 OpenSwiftUI 的视图层级树。

- [ ] **Step 4: 验证 JSON 数据格式**

在 `makeViewDebugData()` 中加断点或 log，检查返回的 JSON 数据是否包含正确的 type、position、size 等属性。

- [ ] **Step 5: 清理调试代码并 Commit**

---

## 风险与注意事项

1. **`OAGSubgraphGetTreeRoot` 的 `const void *` 桥接**: C 函数参数是 `const void *`，不是 `OAGSubgraphRef`。Swift 编译器可能无法自动将 `Subgraph`（CF-bridged 类型）桥接为 `UnsafeRawPointer`。Task 1 Step 2 提供了 fallback 方案。

2. **`OAGGraphGetValue` 在 OpenSwiftUICore 中的可见性**: 该函数通过 `@_silgen_name` 定义在 `OpenAttributeGraph` 模块中。OpenSwiftUICore 导入的是 `OpenAttributeGraphShims`，可能看不到这个泛型函数。Task 3 Step 2/3 提供了 fallback（在 ViewDebug.swift 中添加本地 `@_silgen_name` 声明）。

3. **`OAGTreeValue` / `OAGTreeElement` 类型在 OpenSwiftUICore 中的可见性**: 这些是 `typedef uint32_t` 类型，定义在 `OAGSubgraph.h` 中。需要确认 `OpenAttributeGraphShims` 模块是否导出它们。如果不导出，需要在 shims 中添加 re-export 或使用 `UInt32`。

4. **`.value` 属性的动态类型装箱（Phase 2）**: 需要用 value witness table 的 `initializeWithCopy` 将运行时类型的值装箱为 `Any`。当前 `Metadata` 类型没有 `copyToAny` 方法。实现选项：
   - 在 OpenAttributeGraph 的 `Metadata` 类型上添加 `func box(from pointer: UnsafeRawPointer) -> Any`
   - 或使用 `unsafeBitCast` + existential container 手动构造
   - 或通过 `@_silgen_name` 调用 Swift runtime 的 `swift_allocBox` + VWT

5. **Tree recording 时机**: tree 在 graph instantiation 期间被 recorded。Xcode capture 时 graph 可能已经稳定。方案 A 需要验证能否强制 re-instantiation。

6. **Xcode selector 发现**: 如果 Xcode 是通过 ObjC protocol conformance 而非 selector name 发现的，可能需要用 `@objc(makeViewDebugData)` 注解或在运行时动态添加 protocol conformance。

7. **DisplayList 类型完整性**: `CoreGlue.updateData` 中读取 `DisplayList` 类型。需确认 OpenSwiftUI 中 `DisplayList` 的定义是否足够完整以支持 `OAGGraphGetValue` 读取和后续 JSON 序列化。如果 `DisplayList` 不完整，Task 4 的 `updateData` 可以暂时 no-op。
