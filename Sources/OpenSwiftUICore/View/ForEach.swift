//
//  ForEach.swift
//  OpenSwiftUI
//
//  Audited for iOS 15.5
//  Status: WIP

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
@available(OpenSwiftUI_v1_0, *)
public struct ForEach<Data, ID, Content> where Data: RandomAccessCollection, ID: Hashable {
    /// The collection of underlying identified data that OpenSwiftUI uses to create
    /// views dynamically.
    public var data: Data

    /// A function to create content on demand using the underlying data.
    public var content: (Data.Element) -> Content
}

@available(*, unavailable)
extension ForEach: Sendable {}

extension ForEach: View, PrimitiveView where Content: View {
    nonisolated public static func _makeView(view: _GraphValue<Self>, inputs: _ViewInputs) -> _ViewOutputs {
        openSwiftUIUnimplementedFailure()
    }

    nonisolated public static func _makeViewList(view: _GraphValue<ForEach<Data, ID, Content>>, inputs: _ViewListInputs) -> _ViewListOutputs {
        openSwiftUIUnimplementedFailure()
    }
}
