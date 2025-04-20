//
//  ViewSizeCache.swift
//  OpenSwiftUICore
//
//  Audited for iOS 18.0
//  Status: Complete

package import Foundation

/// A cache for storing and retrieving view sizes based on proposed size values.
///
/// `ViewSizeCache` provides an efficient way to cache calculated sizes for views,
/// avoiding redundant size calculations when the same proposed size is requested multiple times.
package struct ViewSizeCache {
    private var cache: Cache3<ProposedViewSize, CGSize>

    /// Creates a new view size cache.
    ///
    /// - Parameter cache: An optional pre-configured cache. If not provided, a new cache will be created.
    package init(cache: Cache3<ProposedViewSize, CGSize> = .init()) {
        self.cache = cache
    }

    /// Retrieves a cached size for the given proposed size, computing it if not already cached.
    ///
    /// This method returns a cached value if available. If the value isn't cached,
    /// it calls the provided closure to compute the value, caches it, and then returns it.
    ///
    /// - Parameters:
    ///   - k: The proposed size to use as a key for the cache lookup.
    ///   - makeValue: A closure that computes the size when no cached value is available.
    /// - Returns: The cached or newly computed size.
    @inline(__always)
    package mutating func get(_ k: _ProposedSize, makeValue: () -> CGSize) -> CGSize {
        cache.get(ProposedViewSize(k), makeValue: makeValue)
    }
}
