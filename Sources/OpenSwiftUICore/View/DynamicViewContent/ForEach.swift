//
//  ForEach.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: WIP
//  ID: 1A3DD35AB7F6976908CD7AF959F34D1F (SwiftUICore)

package import OpenAttributeGraphShims

// MARK: - ForEach

/// A structure that computes views on demand from an underlying collection of
/// identified data.
///
/// Use `ForEach` to provide views based on a
/// [RandomAccessCollection](https://developer.apple.com/documentation/swift/randomaccesscollection)
/// of some data type. Either the collection's elements must conform to
/// [Identifiable](https://developer.apple.com/documentation/swift/identifiable) or you
/// need to provide an `id` parameter to the `ForEach` initializer.
///
/// The following example creates a `NamedFont` type that conforms to
/// [Identifiable](https://developer.apple.com/documentation/swift/identifiable), and an
/// array of this type called `namedFonts`. A `ForEach` instance iterates
/// over the array, producing new ``Text`` instances that display examples
/// of each OpenSwiftUI ``Font`` style provided in the array.
///
///     private struct NamedFont: Identifiable {
///         let name: String
///         let font: Font
///         var id: String { name }
///     }
///
///     private let namedFonts: [NamedFont] = [
///         NamedFont(name: "Large Title", font: .largeTitle),
///         NamedFont(name: "Title", font: .title),
///         NamedFont(name: "Headline", font: .headline),
///         NamedFont(name: "Body", font: .body),
///         NamedFont(name: "Caption", font: .caption)
///     ]
///
///     var body: some View {
///         ForEach(namedFonts) { namedFont in
///             Text(namedFont.name)
///                 .font(namedFont.font)
///         }
///     }
///
/// ![A vertically arranged stack of labels showing various standard fonts,
/// such as Large Title and Headline.](OpenSwiftUI-ForEach-fonts.png)
///
/// Some containers like ``List`` or ``LazyVStack`` will query the elements
/// within a for each lazily. To obtain maximal performance, ensure that
/// the view created from each element in the collection represents a
/// constant number of views.
///
/// For example, the following view uses an if statement which means each
/// element of the collection can represent either 1 or 0 views, a
/// non-constant number.
///
///     ForEach(namedFonts) { namedFont in
///         if namedFont.name.count != 2 {
///             Text(namedFont.name)
///         }
///     }
///
/// You can make the above view represent a constant number of views by
/// wrapping the condition in a ``VStack``, an ``HStack``, or a ``ZStack``.
///
///     ForEach(namedFonts) { namedFont in
///         VStack {
///             if namedFont.name.count != 2 {
///                 Text(namedFont.name)
///             }
///         }
///     }
///
/// When enabling the following launch argument, OpenSwiftUI will log when
/// it encounters a view that produces a non-constant number of views
/// in these containers:
///
///     -LogForEachSlowPath YES
///
@available(OpenSwiftUI_v1_0, *)
public struct ForEach<Data, ID, Content> where Data: RandomAccessCollection, ID: Hashable {

    /// The collection of underlying identified data that OpenSwiftUI uses to create
    /// views dynamically.
    public var data: Data

    /// A function to create content on demand using the underlying data.
    public var content: (Data.Element) -> Content

    package enum IDGenerator {
        case keyPath(KeyPath<Data.Element, ID>)
        case offset

        package var isConstant: Bool {
            switch self {
            case .keyPath: false
            case .offset: true
            }
        }

        package func makeID(data: Data, index: Data.Index, offset: Int) -> ID {
            switch self {
            case let .keyPath(keyPath): data[index][keyPath: keyPath]
            case .offset: unsafeBitCast(offset, to: ID.self)
            }
        }
    }

    package var idGenerator: IDGenerator

    package var reuseID: KeyPath<Data.Element, Int>?

    var obsoleteContentID: Int

    package init(
        _ data: Data,
        idGenerator: IDGenerator,
        content: @escaping (Data.Element) -> Content
    ) {
        self.data = data
        self.idGenerator = idGenerator
        self.content = content
        self.obsoleteContentID = isLinkedOnOrAfter(.v6) ? .zero : UniqueID().value
    }

    package init<T>(
        _ other: ForEach<Data, ID, T>,
        transform: @escaping (T) -> Content
    ) {
        self.data = other.data
        self.idGenerator = switch other.idGenerator {
        case let .keyPath(keyPath): .keyPath(keyPath)
        case .offset: .offset
        }
        self.content = { element in
            transform(other.content(element))
        }
        self.obsoleteContentID = other.obsoleteContentID
    }
}

@available(*, unavailable)
extension ForEach: Sendable {}

// MARK: - ForEach + View [WIP]

@available(OpenSwiftUI_v1_0, *)
extension ForEach: View, PrimitiveView where Content: View {
    public typealias Body = Never

    nonisolated public static func _makeView(
        view: _GraphValue<ForEach<Data, ID, Content>>,
        inputs: _ViewInputs
    ) -> _ViewOutputs {
        _openSwiftUIUnimplementedFailure()
    }

    nonisolated public static func _makeViewList(
        view: _GraphValue<ForEach<Data, ID, Content>>,
        inputs: _ViewListInputs
    ) -> _ViewListOutputs {
        _openSwiftUIUnimplementedFailure()
    }
}

// MARK: - ForEachEvictionInput

package struct ForEachEvictionInput: GraphInput {
    package typealias Value = WeakAttribute<Bool>

    package static let defaultValue: WeakAttribute<Bool> = .init()

    package static let evictByDefault: Bool = isLinkedOnOrAfter(.v6)
}

// MARK: - ForEach + id

@available(OpenSwiftUI_v1_0, *)
extension ForEach where ID == Data.Element.ID, Content: View, Data.Element: Identifiable {

    /// Creates an instance that uniquely identifies and creates views across
    /// updates based on the identity of the underlying data.
    ///
    /// It's important that the `id` of a data element doesn't change unless you
    /// replace the data element with a new data element that has a new
    /// identity. If the `id` of a data element changes, the content view
    /// generated from that data element loses any current state and animations.
    ///
    /// - Parameters:
    ///   - data: The identified data that the ``ForEach`` instance uses to
    ///     create views dynamically.
    ///   - content: The view builder that creates views dynamically.
    public init(_ data: Data, @ViewBuilder content: @escaping (Data.Element) -> Content) {
        self.init(data, idGenerator: .keyPath(\.id), content: content)
    }
}

@available(OpenSwiftUI_v1_0, *)
extension ForEach where Content: View {

    /// Creates an instance that uniquely identifies and creates views across
    /// updates based on the provided key path to the underlying data's
    /// identifier.
    ///
    /// It's important that the `id` of a data element doesn't change, unless
    /// SwiftUI considers the data element to have been replaced with a new data
    /// element that has a new identity. If the `id` of a data element changes,
    /// then the content view generated from that data element will lose any
    /// current state and animations.
    ///
    /// - Parameters:
    ///   - data: The data that the ``ForEach`` instance uses to create views
    ///     dynamically.
    ///   - id: The key path to the provided data's identifier.
    ///   - content: The view builder that creates views dynamically.
    public init(
        _ data: Data,
        id: KeyPath<Data.Element, ID>,
        @ViewBuilder content: @escaping (Data.Element) -> Content
    ) {
        self.init(
            data,
            idGenerator: .keyPath(id),
            content: content
        )
    }
}

// MARK: - ForEach + binding

@available(OpenSwiftUI_v1_0, *)
extension ForEach where Content: View {

    /// Creates an instance that uniquely identifies and creates views across
    /// updates based on the identity of the underlying data.
    ///
    /// It's important that the `id` of a data element doesn't change unless you
    /// replace the data element with a new data element that has a new
    /// identity. If the `id` of a data element changes, the content view
    /// generated from that data element loses any current state and animations.
    ///
    /// - Parameters:
    ///   - data: The identified data that the ``ForEach`` instance uses to
    ///     create views dynamically.
    ///   - content: The view builder that creates views dynamically.
    @_disfavoredOverload
    @_alwaysEmitIntoClient
    public init<C>(
        _ data: Binding<C>,
        @ViewBuilder content: @escaping (Binding<C.Element>) -> Content
    ) where Data == LazyMapSequence<C.Indices, (C.Index, ID)>,
    ID == C.Element.ID,
    C: MutableCollection,
    C: RandomAccessCollection,
    C.Element: Identifiable,
    C.Index: Hashable {
        self.init(data, id: \.id, content: content)
    }

    /// Creates an instance that uniquely identifies and creates views across
    /// updates based on the identity of the underlying data.
    ///
    /// It's important that the `id` of a data element doesn't change unless you
    /// replace the data element with a new data element that has a new
    /// identity. If the `id` of a data element changes, the content view
    /// generated from that data element loses any current state and animations.
    ///
    /// - Parameters:
    ///   - data: The identified data that the ``ForEach`` instance uses to
    ///     create views dynamically.
    ///   - id: The key path to the provided data's identifier.
    ///   - content: The view builder that creates views dynamically.
    @_disfavoredOverload
    @_alwaysEmitIntoClient
    public init<C>(
        _ data: Binding<C>,
        id: KeyPath<C.Element, ID>,
        @ViewBuilder content: @escaping (Binding<C.Element>) -> Content
    ) where Data == LazyMapSequence<C.Indices, (C.Index, ID)>,
    C: MutableCollection,
    C: RandomAccessCollection,
    C.Index: Hashable {
        let elementIDs = data.wrappedValue.indices.lazy.map { index in
            (index, data.wrappedValue[index][keyPath: id])
        }
        self.init(elementIDs, id: \.1) { (index, _) in
            let elementBinding = Binding {
                data.wrappedValue[index]
            } set: {
                data.wrappedValue[index] = $0
            }
            content(elementBinding)
        }
    }
}

// MARK: - ForEach + range

@available(OpenSwiftUI_v1_0, *)
extension ForEach where Data == Range<Int>, ID == Int, Content: View {

    /// Creates an instance that computes views on demand over a given constant
    /// range.
    ///
    /// The instance only reads the initial value of the provided `data` and
    /// doesn't need to identify views across updates. To compute views on
    /// demand over a dynamic range, use ``ForEach/init(_:id:content:)``.
    ///
    /// - Parameters:
    ///   - data: A constant range.
    ///   - content: The view builder that creates views dynamically.
    @_semantics("swiftui.requires_constant_range")
    public init(_ data: Range<Int>, @ViewBuilder content: @escaping (Int) -> Content) {
        self.init(data, idGenerator: .offset, content: content)
    }
}
