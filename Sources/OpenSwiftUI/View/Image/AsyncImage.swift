//
//  AsyncImage.swift
//  OpenSwiftUI
//
//  Audited for iOS 18.0
//  Status: Complete
//  ID: A80DD7B873FCFB98C142212B419D71F4 (SwiftUI)

public import Foundation
@_spi(Private)
public import OpenSwiftUICore
#if canImport(CoreGraphics)
import CoreGraphics
#endif
#if canImport(ImageIO)
import ImageIO
#endif

/// A view that asynchronously loads and displays an image.
///
/// This view uses the shared
/// [URLSession](https://developer.apple.com/documentation/Foundation/URLSession)
/// instance to load an image from the specified URL, and then display it.
/// For example, you can display an icon that's stored on a server:
///
///     AsyncImage(url: URL(string: "https://example.com/icon.png"))
///         .frame(width: 200, height: 200)
///
/// Until the image loads, the view displays a standard placeholder that
/// fills the available space. After the load completes successfully, the view
/// updates to display the image. In the example above, the icon is smaller
/// than the frame, and so appears smaller than the placeholder.
///
/// ![A diagram that shows a grey box on the left, the OpenSwiftUI icon on the
/// right, and an arrow pointing from the first to the second. The icon
/// is about half the size of the grey box.](AsyncImage-1)
///
/// You can specify a custom placeholder using
/// ``init(url:scale:content:placeholder:)``. With this initializer, you can
/// also use the `content` parameter to manipulate the loaded image.
/// For example, you can add a modifier to make the loaded image resizable:
///
///     AsyncImage(url: URL(string: "https://example.com/icon.png")) { image in
///         image.resizable()
///     } placeholder: {
///         ProgressView()
///     }
///     .frame(width: 50, height: 50)
///
/// For this example, OpenSwiftUI shows a ``ProgressView`` first, and then the
/// image scaled to fit in the specified frame:
///
/// ![A diagram that shows a progress view on the left, the OpenSwiftUI icon on the
/// right, and an arrow pointing from the first to the second.](AsyncImage-2)
///
/// > Important: You can't apply image-specific modifiers, like
/// ``Image/resizable(capInsets:resizingMode:)``, directly to an `AsyncImage`.
/// Instead, apply them to the ``Image`` instance that your `content`
/// closure gets when defining the view's appearance.
///
/// To gain more control over the loading process, use the
/// ``init(url:scale:transaction:content:)`` initializer, which takes a
/// `content` closure that receives an ``AsyncImagePhase`` to indicate
/// the state of the loading operation. Return a view that's appropriate
/// for the current phase:
///
///     AsyncImage(url: URL(string: "https://example.com/icon.png")) { phase in
///         if let image = phase.image {
///             image // Displays the loaded image.
///         } else if phase.error != nil {
///             Color.red // Indicates an error.
///         } else {
///             Color.blue // Acts as a placeholder.
///         }
///     }
///
public struct AsyncImage<Content>: View where Content : View {
    /// The URL of the image to load.
    ///
    /// When this property changes, the view automatically starts loading the new image
    /// and updates the display when the load completes. Set to `nil` to display the
    /// default placeholder.
    var url: URL?
    
    /// The scale to apply to the loaded image.
    ///
    /// This value determines how the view interprets the image data. For example,
    /// a value of `2` treats the image as having double the resolution of the display.
    /// The default is `1`.
    var scale: CGFloat
    
    /// The transaction to use when updating the UI.
    ///
    /// This transaction controls how the view animates when the image loads or
    /// when a loading error occurs. The default transaction uses default animation
    /// timing and does not disable animations.
    var transaction: Transaction
    
    /// A closure that transforms the loading phase into a view.
    ///
    /// This closure receives the current phase of the loading operation and returns
    /// a view to display for that phase. The view returned by this closure becomes
    /// the body of the AsyncImage.
    var content: (AsyncImagePhase) -> Content
    
    /// The state that tracks the image loading process.
    ///
    /// This state property stores information about the current loading operation, including:
    /// - The current phase (empty, success, or failure)
    /// - The task that's performing the download operation
    /// - The URL being downloaded
    ///
    /// When this state changes, the view automatically updates to reflect the new loading status.
    @State private var loadingState = LoadingState(phase: .empty)
    
    /// Loads and displays an image from the specified URL.
    ///
    /// Until the image loads, OpenSwiftUI displays a default placeholder. When
    /// the load operation completes successfully, OpenSwiftUI updates the
    /// view to show the loaded image. If the operation fails, OpenSwiftUI
    /// continues to display the placeholder. The following example loads
    /// and displays an icon from an example server:
    ///
    ///     AsyncImage(url: URL(string: "https://example.com/icon.png"))
    ///
    /// If you want to customize the placeholder or apply image-specific
    /// modifiers --- like ``Image/resizable(capInsets:resizingMode:)`` ---
    /// to the loaded image, use the ``init(url:scale:content:placeholder:)``
    /// initializer instead.
    ///
    /// - Parameters:
    ///   - url: The URL of the image to display.
    ///   - scale: The scale to use for the image. The default is `1`. Set a
    ///     different value when loading images designed for higher resolution
    ///     displays. For example, set a value of `2` for an image that you
    ///     would name with the `@2x` suffix if stored in a file on disk.
    public init(url: URL?, scale: CGFloat = 1) where Content == Image {
        self.url = url
        self.scale = scale
        self.transaction = Transaction()
        self.content = { phase in
            phase.image ?? .redacted
        }
    }

    /// Loads and displays a modifiable image from the specified URL using
    /// a custom placeholder until the image loads.
    ///
    /// Until the image loads, OpenSwiftUI displays the placeholder view that
    /// you specify. When the load operation completes successfully, OpenSwiftUI
    /// updates the view to show content that you specify, which you
    /// create using the loaded image. For example, you can show a green
    /// placeholder, followed by a tiled version of the loaded image:
    ///
    ///     AsyncImage(url: URL(string: "https://example.com/icon.png")) { image in
    ///         image.resizable(resizingMode: .tile)
    ///     } placeholder: {
    ///         Color.green
    ///     }
    ///
    /// If the load operation fails, OpenSwiftUI continues to display the
    /// placeholder. To be able to display a different view on a load error,
    /// use the ``init(url:scale:transaction:content:)`` initializer instead.
    ///
    /// - Parameters:
    ///   - url: The URL of the image to display.
    ///   - scale: The scale to use for the image. The default is `1`. Set a
    ///     different value when loading images designed for higher resolution
    ///     displays. For example, set a value of `2` for an image that you
    ///     would name with the `@2x` suffix if stored in a file on disk.
    ///   - content: A closure that takes the loaded image as an input, and
    ///     returns the view to show. You can return the image directly, or
    ///     modify it as needed before returning it.
    ///   - placeholder: A closure that returns the view to show until the
    ///     load operation completes successfully.
    @_alwaysEmitIntoClient
    public init<I, P>(
        url: URL?,
        scale: CGFloat = 1,
        @ViewBuilder content: @escaping (Image) -> I,
        @ViewBuilder placeholder: @escaping () -> P
    ) where Content == _ConditionalContent<I, P>, I: View, P: View {
        self.init(url: url, scale: scale) { phase in
            if let i = phase.image {
                content(i)
            } else {
                placeholder()
            }
        }
    }

    /// Loads and displays a modifiable image from the specified URL in phases.
    ///
    /// If you set the asynchronous image's URL to `nil`, or after you set the
    /// URL to a value but before the load operation completes, the phase is
    /// ``AsyncImagePhase/empty``. After the operation completes, the phase
    /// becomes either ``AsyncImagePhase/failure(_:)`` or
    /// ``AsyncImagePhase/success(_:)``. In the first case, the phase's
    /// ``AsyncImagePhase/error`` value indicates the reason for failure.
    /// In the second case, the phase's ``AsyncImagePhase/image`` property
    /// contains the loaded image. Use the phase to drive the output of the
    /// `content` closure, which defines the view's appearance:
    ///
    ///     AsyncImage(url: URL(string: "https://example.com/icon.png")) { phase in
    ///         if let image = phase.image {
    ///             image // Displays the loaded image.
    ///         } else if phase.error != nil {
    ///             Color.red // Indicates an error.
    ///         } else {
    ///             Color.blue // Acts as a placeholder.
    ///         }
    ///     }
    ///
    /// To add transitions when you change the URL, apply an identifier to the
    /// ``AsyncImage``.
    ///
    /// - Parameters:
    ///   - url: The URL of the image to display.
    ///   - scale: The scale to use for the image. The default is `1`. Set a
    ///     different value when loading images designed for higher resolution
    ///     displays. For example, set a value of `2` for an image that you
    ///     would name with the `@2x` suffix if stored in a file on disk.
    ///   - transaction: The transaction to use when the phase changes.
    ///   - content: A closure that takes the load phase as an input, and
    ///     returns the view to display for the specified phase.
    public init(
        url: URL?,
        scale: CGFloat = 1,
        transaction: Transaction = Transaction(),
        @ViewBuilder content: @escaping (AsyncImagePhase) -> Content
    ) {
        self.url = url
        self.scale = scale
        self.transaction = transaction
        self.content = content
    }

    @MainActor
    @preconcurrency
    public var body: some View {
        Inner(phase: loadingState.phase, content: content)
            .modifier(
                _AppearanceActionModifier(appear: {
                    didChangeURL(oldValue: url, newValue: url)
                }, disappear: {
                    onDisappear()
                })
            )
             .onChange(of: url, initial: false, didChangeURL)
    }
    
    // MARK: - AsyncImage.Inner
    
    /// Internal view that renders the content based on the current loading phase.
    ///
    /// This view adapts the content closure's output to display the appropriate
    /// view for the current phase of the loading operation.
    private struct Inner: View {
        /// The current phase of the loading operation.
        var phase: AsyncImagePhase
        
        /// A closure that transforms the loading phase into a view.
        var content: (AsyncImagePhase) -> Content
        
        var body: some View {
            _UnaryViewAdaptor(content(phase))
        }
    }
    
    /// Handles changes to the URL.
    ///
    /// This method is called when the URL changes or when the view appears.
    /// It starts a new loading operation if necessary.
    ///
    /// - Parameters:
    ///   - oldValue: The previous URL, if any.
    ///   - newValue: The new URL, if any.
    private func didChangeURL(oldValue: URL?, newValue: URL?) {
        let value = (newValue, loadingState.url)
        guard value.0 != value.1 else {
            return
        }
        guard let newURL = newValue else {
            resetLoadingState()
            return
        }
        let config = TaskConfig(loadingState: $loadingState, scale: scale, transaction: transaction)
        let task = Task.detached(priority: .userInitiated) {
            let result: TaskResult
            do {
                result = try await downloadURL(newURL)
            } catch {
                result = TaskResult(error: error)
            }
            updateTaskResult(result, config: config)
        }
        updateTask(task, url: newURL)
    }
    
    /// Handles the view disappearing.
    ///
    /// Cancels any in-progress loading operations to prevent memory leaks
    /// and unnecessary work when the view is no longer visible.
    private func onDisappear() {
        if let task = loadingState.task {
            task.cancel()
        }
        loadingState.task = nil
    }
    
    /// Resets the loading state.
    ///
    /// Called when the URL is set to nil or when a new URL is set.
    /// Cancels any in-progress loading operations and resets the state.
    private func resetLoadingState() {
        withTransaction(transaction) {
            if let task = loadingState.task {
                task.cancel()
            }
            // SwiftUI iOS 18.0 implementation:
            // loadingState.task = nil
            // loadingState.url = nil
            // loadingState.phase = .empty
            // OpenSwiftUI optimized implementation:
            loadingState = LoadingState(phase: .empty)
        }
    }

    /// Updates the task and loading state.
    ///
    /// Called when a new loading operation starts.
    /// Cancels any previous loading operation and updates the state.
    ///
    /// - Parameters:
    ///   - task: The new loading task.
    ///   - url: The URL being loaded.
    private func updateTask(_ task: Task<Void, Never>, url: URL) {
        loadingState.task?.cancel()
        // SwiftUI iOS 18.0 implementation:
        // loadingState.task = task
        // loadingState.url = url
        // OpenSwiftUI optimized implementation:
        loadingState = LoadingState(task: task, url: url, phase: loadingState.phase)
    }
}

@available(*, unavailable)
extension AsyncImage: Sendable {}

// MARK: - AsyncImagePhase

/// The current phase of the asynchronous image loading operation.
///
/// When you create an ``AsyncImage`` instance with the
/// ``AsyncImage/init(url:scale:transaction:content:)`` initializer, you define
/// the appearance of the view using a `content` closure. OpenSwiftUI calls the
/// closure with a phase value at different points during the load operation
/// to indicate the current state. Use the phase to decide what to draw.
/// For example, you can draw the loaded image if it exists, a view that
/// indicates an error, or a placeholder:
///
///     AsyncImage(url: URL(string: "https://example.com/icon.png")) { phase in
///         if let image = phase.image {
///             image // Displays the loaded image.
///         } else if phase.error != nil {
///             Color.red // Indicates an error.
///         } else {
///             Color.blue // Acts as a placeholder.
///         }
///     }
///
public enum AsyncImagePhase: Sendable {

    /// No image is loaded.
    case empty

    /// An image succesfully loaded.
    case success(Image)

    /// An image failed to load with an error.
    case failure(any Error)

    /// The loaded image, if any.
    ///
    /// If this value isn't `nil`, the image load operation has finished,
    /// and you can use the image to update the view. You can use the image
    /// directly, or you can modify it in some way. For example, you can add
    /// a ``Image/resizable(capInsets:resizingMode:)`` modifier to make the
    /// image resizable.
    public var image: Image? {
        guard case let .success(image) = self else {
            return nil
        }
        return image
    }

    /// The error that occurred when attempting to load an image, if any.
    public var error: (any Error)? {
        guard case let .failure(error) = self else {
            return nil
        }
        return error
    }
}

// MARK: - LoadingState

/// Tracks the state of an asynchronous image loading operation.
///
/// This structure encapsulates the current state of an image load operation, including:
/// - The task responsible for downloading and processing the image
/// - The URL being downloaded
/// - The current phase of the loading operation
private struct LoadingState {
    /// The task that handles the asynchronous image loading.
    /// May be nil if no loading operation is in progress.
    var task: Task<Void, Never>?
    
    /// The URL being downloaded, if any.
    /// Used to prevent duplicate downloads of the same URL.
    var url: URL?
    
    /// The current phase of the loading operation.
    /// Indicates whether the operation is in progress, has succeeded, or has failed.
    var phase: AsyncImagePhase
}

// MARK: - LoadingError

/// Error thrown when an image fails to load.
///
/// This generic error is used when a more specific error isn't available
/// or when the image data couldn't be processed correctly.
private struct LoadingError: Error {}

// MARK: - TaskConfig

/// Configuration for an image loading task.
///
/// Contains the necessary context for updating the UI when an image load
/// operation completes, including:
/// - A binding to the loading state
/// - The scale to apply to the loaded image
/// - The transaction to use when updating the UI
private struct TaskConfig {
    /// Binding to the current loading state.
    /// Used to update the UI when the loading state changes.
    @Binding var loadingState: LoadingState
    
    /// The scale to apply to the loaded image.
    var scale: CGFloat
    
    /// The transaction to use when updating the UI.
    /// Controls animation when the image appears.
    var transaction: Transaction
}

// MARK: - TaskResult

/// Result of an image loading operation.
///
/// Contains the loaded image data or error information.
/// Used to pass the result of the loading operation back to the UI.
private struct TaskResult {
    /// The local URL where the downloaded image is temporarily stored.
    var localURL: URL?
    
    #if canImport(CoreGraphics)
    /// The loaded Core Graphics image.
    var cgImage: CGImage?
    #endif
    
    /// The orientation of the loaded image, if available.
    var orientation: Image.Orientation?
    
    /// The error that occurred during loading, if any.
    var error: Error?
}

/// Downloads an image from the specified URL.
///
/// - Parameter url: The URL of the image to download.
/// - Returns: A `TaskResult` containing the downloaded image or an error.
/// - Throws: An error if the download fails or the image can't be processed.
private func downloadURL(_ url: URL) async throws -> TaskResult {
    #if canImport(CoreGraphics) && canImport(ImageIO)
    let (localURL, _) = try await URLSession.shared.download(from: url, delegate: nil)
    guard let cgImageSource = CGImageSourceCreateWithURL(url as NSURL, nil),
          CGImageSourceGetCount(cgImageSource) >= 1 else {
        throw LoadingError()
    }
    return TaskResult(
        localURL: localURL,
        cgImage: CGImageSourceCreateImageAtIndex(cgImageSource, 0, nil),
        orientation: cgImageSource.orientation(at: 0)
    )
    #else
    _openSwiftUIUnimplementedFailure()
    #endif
}

#if canImport(ImageIO)
extension CGImageSource {
    /// Extracts the orientation information from an image at the specified index.
    ///
    /// - Parameter index: The index of the image in the image source.
    /// - Returns: The orientation of the image, or nil if not available.
    fileprivate func orientation(at index: Int) -> Image.Orientation? {
        guard let properties = CGImageSourceCopyPropertiesAtIndex(self, index, nil),
              let orientationResult = CFDictionaryGetValue(
                properties,
                Unmanaged.passUnretained(kCGImagePropertyOrientation).toOpaque()
              ),
              let orientation = unsafeBitCast(orientationResult, to: NSNumber.self) as? Int
        else {
            return nil
        }
        return Image.Orientation(exifValue: orientation)
    }
}
#endif

/// Updates the UI with the result of an image loading operation.
///
/// - Parameters:
///   - result: The result of the loading operation.
///   - config: Configuration for updating the UI.
private func updateTaskResult(_ result: TaskResult, config: TaskConfig) {
    #if canImport(CoreGraphics)
    if let cgImage = result.cgImage {
        withTransaction(config.transaction) {
            let image = Image(decorative: cgImage, scale: config.scale, orientation: result.orientation ?? .up)
            config.loadingState.phase = .success(image)
        }
    } else {
        withTransaction(config.transaction) {
            let error = result.error ?? LoadingError()
            config.loadingState.phase = .failure(error)
        }
    }
    #else
    _openSwiftUIUnimplementedFailure()
    #endif
}
