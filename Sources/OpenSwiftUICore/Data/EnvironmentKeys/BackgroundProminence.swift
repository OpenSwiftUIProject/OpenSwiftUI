//
//  BackgroundProminence.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete

// MARK: - BackgroundProminence

/// The prominence of backgrounds underneath other views.
///
/// Background prominence should influence foreground styling to maintain
/// sufficient contrast against the background. For example, selected rows in
/// a `List` and `Table` can have increased prominence backgrounds with
/// accent color fills when focused; the foreground content above the background
/// should be adjusted to reflect that level of prominence.
///
/// This can be read and written for views with the
/// `EnvironmentValues.backgroundProminence` property.
@available(OpenSwiftUI_v5_0, *)
public struct BackgroundProminence: Hashable, Sendable {
    enum Guts {
        case standard
        case increased
    }

    var guts: Guts

    /// The standard prominence of a background
    ///
    /// This is the default level of prominence and doesn't require any
    /// adjustment to achieve satisfactory contrast with the background.
    public static let standard = BackgroundProminence(guts: .standard)

    /// A more prominent background that likely requires some changes to the
    /// views above it.
    ///
    /// This is the level of prominence for more highly saturated and full
    /// color backgrounds, such as focused/emphasized selected list rows.
    /// Typically foreground content should take on monochrome styling to
    /// have greater contrast against the background.
    public static let increased = BackgroundProminence(guts: .increased)

    struct Key: EnvironmentKey {
        static let defaultValue = BackgroundProminence.standard
    }
}

@available(OpenSwiftUI_v5_0, *)
extension EnvironmentValues {
    /// The prominence of the background underneath views associated with this
    /// environment.
    ///
    /// Foreground elements above an increased prominence background are
    /// typically adjusted to have higher contrast against a potentially vivid
    /// color, such as taking on a higher opacity monochrome appearance
    /// according to the `colorScheme`. System styles like `primary`,
    /// `secondary`, etc will automatically resolve to an appropriate style in
    /// this context. The property can be read and used for custom styled
    /// elements.
    ///
    /// In the example below, a custom star rating element is in a list row
    /// alongside some text. When the row is selected and has an increased
    /// prominence appearance, the text and star rating will update their
    /// appearance, the star rating replacing its use of yellow with the
    /// standard `secondary` style.
    ///
    ///     struct RecipeList: View {
    ///         var recipes: [Recipe]
    ///         @Binding var selectedRecipe: Recipe.ID?
    ///
    ///         var body: some View {
    ///             List(recipes, selection: $selectedRecipe) {
    ///                 RecipeListRow(recipe: $0)
    ///             }
    ///         }
    ///     }
    ///
    ///     struct RecipeListRow: View {
    ///         var recipe: Recipe
    ///         var body: some View {
    ///             VStack(alignment: .leading) {
    ///                 HStack(alignment: .firstTextBaseline) {
    ///                     Text(recipe.name)
    ///                     Spacer()
    ///                     StarRating(rating: recipe.rating)
    ///                 }
    ///                 Text(recipe.description)
    ///                     .foregroundStyle(.secondary)
    ///                     .lineLimit(2, reservesSpace: true)
    ///             }
    ///         }
    ///     }
    ///
    ///     private struct StarRating: View {
    ///         var rating: Int
    ///
    ///         @Environment(\.backgroundProminence)
    ///         private var backgroundProminence
    ///
    ///         var body: some View {
    ///             HStack(spacing: 1) {
    ///                 ForEach(0..<rating, id: \.self) { _ in
    ///                     Image(systemName: "star.fill")
    ///                 }
    ///             }
    ///             .foregroundStyle(backgroundProminence == .increased ?
    ///                 AnyShapeStyle(.secondary) : AnyShapeStyle(.yellow))
    ///             .imageScale(.small)
    ///         }
    ///     }
    ///
    /// Note that the use of `backgroundProminence` was used by a view that
    /// was nested in additional stack containers within the row. This ensured
    /// that the value correctly reflected the environment within the list row
    /// itself, as opposed to the environment of the list as a whole. One way
    /// to ensure correct resolution would be to prefer using this in a custom
    /// ShapeStyle instead, for example:
    ///
    ///     private struct StarRating: View {
    ///         var rating: Int
    ///
    ///         var body: some View {
    ///             HStack(spacing: 1) {
    ///                 ForEach(0..<rating, id: \.self) { _ in
    ///                     Image(systemName: "star.fill")
    ///                 }
    ///             }
    ///             .foregroundStyle(FillStyle())
    ///             .imageScale(.small)
    ///         }
    ///     }
    ///
    ///     extension StarRating {
    ///         struct FillStyle: ShapeStyle {
    ///             func resolve(in env: EnvironmentValues) -> some ShapeStyle {
    ///                 switch env.backgroundProminence {
    ///                 case .increased: return AnyShapeStyle(.secondary)
    ///                 default: return AnyShapeStyle(.yellow)
    ///                 }
    ///             }
    ///         }
    ///     }
    ///
    /// Views like `List` and `Table` as well as standard shape styles like
    /// `ShapeStyle.selection` will automatically update the background
    /// prominence of foreground views. For custom backgrounds, this environment
    /// property can be explicitly set on views above custom backgrounds.
    public var backgroundProminence: BackgroundProminence {
        get { self[BackgroundProminence.Key.self] }
        set { self[BackgroundProminence.Key.self] = newValue }
    }
}
