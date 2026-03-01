//
//  SFSymbolsShims.swift
//  OpenSwiftUICore
//
//  Status: WIP

// MARK: - SFSymbols Framework Access
//
// Currently uses dlopen/dlsym for dynamic symbol resolution at
// runtime. This avoids a hard link dependency on the private SFSymbols
// framework.
//
// TODO: Migrate to add SFSymbols in DarwinPrivateFrameworks package and link it with a new
// OPENSWIFTUI_LINK_SFSYMBOLS build flag (following the CoreUI pattern).
// When that migration happens:
//   1. Add `import SFSymbols` under `#if OPENSWIFTUI_LINK_SFSYMBOLS`.
//   2. Replace the dlopen-based implementations with direct calls.
//   3. Call sites using `SFSymbols.symbol_order` etc. remain unchanged
//      because Swift resolves `SFSymbols.x` identically whether `SFSymbols`
//      is a local enum or a qualified module name.

#if canImport(Darwin)
import Foundation

/// Shim for the private SFSymbols framework.
///
/// Property names intentionally use snake_case to match the framework's
/// original API surface, ensuring a seamless migration to direct linking
/// (Option C) with no source-breaking changes at call sites.
package enum SFSymbols {
    // MARK: - Module-level Properties

    /// All system symbol names in their canonical order.
    package static var symbol_order: [String] {
        _lookup("$s9SFSymbols12symbol_orderSaySSGvg", as: Getter_ArrayString.self)?() ?? []
    }

    /// Private system symbol names in their canonical order.
    package static var private_symbol_order: [String] {
        _lookup("$s9SFSymbols20private_symbol_orderSaySSGvg", as: Getter_ArrayString.self)?() ?? []
    }

    /// Mapping of alias names to their canonical symbol names.
    package static var name_aliases: [String: String] {
        _lookup("$s9SFSymbols12name_aliasesSDyS2SGvg", as: Getter_DictStringString.self)?() ?? [:]
    }

    /// Mapping of private alias names to their canonical symbol names.
    package static var private_name_aliases: [String: String] {
        _lookup("$s9SFSymbols20private_name_aliasesSDyS2SGvg", as: Getter_DictStringString.self)?() ?? [:]
    }

    /// Mapping from nofill symbol names to their fill variants.
    package static var nofill_to_fill: [String: String] {
        _lookup("$s9SFSymbols14nofill_to_fillSDyS2SGvg", as: Getter_DictStringString.self)?() ?? [:]
    }

    /// Mapping from private nofill symbol names to their fill variants.
    package static var private_nofill_to_fill: [String: String] {
        _lookup("$s9SFSymbols22private_nofill_to_fillSDyS2SGvg", as: Getter_DictStringString.self)?() ?? [:]
    }

    // MARK: - Private

    private typealias Getter_ArrayString = @convention(thin) () -> [String]
    private typealias Getter_DictStringString = @convention(thin) () -> [String: String]

    private static let handle: UnsafeMutableRawPointer? = {
        dlopen("/System/Library/PrivateFrameworks/SFSymbols.framework/SFSymbols", RTLD_LAZY)
    }()

    private static func _lookup<T>(_ name: String, as type: T.Type) -> T? {
        guard let handle, let sym = dlsym(handle, name) else { return nil }
        return unsafeBitCast(sym, to: type)
    }
}
#endif
