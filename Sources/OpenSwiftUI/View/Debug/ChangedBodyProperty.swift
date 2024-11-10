//
//  ChangedBodyProperty.swift
//  OpenSwiftUI
//
//  Audited for iOS 15.5
//  Status: Complete

// MARK: - printChanges

extension View {
    /// When called within an invocation of `body` of a view of this
    /// type, prints the names of the changed dynamic properties that
    /// caused the result of `body` to need to be refreshed. As well as
    /// the physical property names, "@self" is used to mark that the
    /// view value itself has changed, and "@identity" to mark that the
    /// identity of the view has changed (i.e. that the persistent data
    /// associated with the view has been recycled for a new instance
    /// of the same type).
    public static func _printChanges() {
        printChangedBodyProperties(of: Self.self)
    }
}

extension ViewModifier {
    /// When called within an invocation of `body()` of a view modifier
    /// of this type, prints the names of the changed dynamic
    /// properties that caused the result of `body()` to need to be
    /// refreshed. As well as the physical property names, "@self" is
    /// used to mark that the modifier value itself has changed, and
    /// "@identity" to mark that the identity of the modifier has
    /// changed (i.e. that the persistent data associated with the
    /// modifier has been recycled for a new instance of the same
    /// type).
    public static func _printChanges() {
        printChangedBodyProperties(of: Self.self)
    }
}

// MARK: - logChanges

extension View {
    /// When called within an invocation of `body` of a view of this type, logs
    /// the names of the changed dynamic properties that caused the result of
    /// `body` to need to be refreshed.
    ///
    ///     var body: some View {
    ///         let _ = Self._logChanges()
    ///         ... view content ...
    ///     }
    ///
    /// As well as the physical property names, "@self" is used to mark that the
    /// view value itself has changed, and "@identity" to mark that the identity
    /// of the view has changed (i.e. that the persistent data associated with
    /// the view has been recycled for a new instance of the same type).
    ///
    /// The information is logged at the info level to the "org.OpenSwiftUIProject.OpenSwiftUI"
    /// subsystem with the category "Changed Body Properties".
    public static func _logChanges() {
        logChangedBodyProperties(of: Self.self)
    }
}

extension ViewModifier {
    /// When called within an invocation of `body` of a view modifier of this
    /// type, logs the names of the changed dynamic properties that caused the
    /// result of `body` to need to be refreshed.
    ///
    ///     func body(content: Self.Content): Self.Body {
    ///         let _ = Self._logChanges()
    ///         ... view modifier content ...
    ///     }
    ///
    /// As well as the physical property names, "@self" is used to mark that the
    /// modifier value itself has changed, and "@identity" to mark that the
    /// identity of the modifier has changed (i.e. that the persistent data
    /// associated with the modifier has been recycled for a new instance of the
    /// same type).
    ///
    /// The information is logged at the info level to the "org.OpenSwiftUIProject.OpenSwiftUI"
    /// subsystem with the category "Changed Body Properties".
    public static func _logChanges() {
        logChangedBodyProperties(of: Self.self)
    }
}
