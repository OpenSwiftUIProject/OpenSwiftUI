//
//  OpenURLActionTests.swift
//  OpenSwiftUICoreTests

import Foundation
@testable import OpenSwiftUICore
import Testing

@MainActor
struct OpenURLActionTests {
    @Test
    func environmentKeyDefaults() {
        #expect(OpenURLActionKey.defaultValue == nil)
        #expect(OpenSensitiveURLActionKey.defaultValue == nil)

        var environment = emptyEnvironment()
        #expect(!environment.hasSystemOpenURLAction)

        environment.hasSystemOpenURLAction = true
        #expect(environment.hasSystemOpenURLAction)
    }

    #if !os(watchOS)
    @Test
    func systemHandlerDispatchesNonFileURLAndRejectsFileURL() throws {
        let webURL = try #require(URL(string: "https://example.com"))
        let fileURL = URL(fileURLWithPath: "/tmp/open-url-action-test")
        var receivedURLs: [URL] = []
        var acceptedValues: [Bool] = []

        let action = OpenURLAction(isDefault: true) { url, completion in
            receivedURLs.append(url)
            completion(true)
        }

        action(webURL) { acceptedValues.append($0) }
        action(fileURL) { acceptedValues.append($0) }

        #expect(action.isDefault)
        #expect(receivedURLs == [webURL])
        #expect(acceptedValues == [true, false])
    }

    @Test(arguments: [true, false])
    func customResultMapsToCompletion(handled: Bool) throws {
        let inputURL = try #require(URL(string: "https://example.com/input"))
        var receivedURL: URL?
        var accepted: Bool?

        let action = OpenURLAction { url in
            receivedURL = url
            return handled ? .handled : .discarded
        }

        action(inputURL) { accepted = $0 }

        #expect(receivedURL == inputURL)
        #expect(accepted == handled)
    }

    @Test(arguments: [false, true])
    func systemActionUsesFallback(usesOverrideURL: Bool) throws {
        let inputURL = try #require(URL(string: "https://example.com/input"))
        let overrideURL = try #require(URL(string: "https://example.com/override"))
        let expectedURL = usesOverrideURL ? overrideURL : inputURL
        var customHandlerURL: URL?
        var fallbackURL: URL?
        var accepted: Bool?

        let action = OpenURLAction(
            handler: .custom(
                { url in
                    customHandlerURL = url
                    return usesOverrideURL
                        ? .systemAction(overrideURL)
                        : .systemAction
                },
                fallback: { url, completion in
                    fallbackURL = url
                    completion(false)
                }
            )
        )

        action(inputURL) { accepted = $0 }

        #expect(customHandlerURL == inputURL)
        #expect(fallbackURL == expectedURL)
        #expect(accepted == false)
    }

    @Test
    func systemActionWithoutFallbackDoesNotComplete() throws {
        let inputURL = try #require(URL(string: "https://example.com"))
        var handlerCallCount = 0
        var accepted: Bool?
        let action = OpenURLAction(
            handler: .custom { _ in
                handlerCallCount += 1
                return .systemAction
            }
        )

        action(inputURL) { accepted = $0 }

        #expect(handlerCallCount == 1)
        #expect(accepted == nil)
    }

    @Test
    func invalidActionDiscardsURL() throws {
        let inputURL = try #require(URL(string: "https://example.com"))
        let action = OpenURLAction.invalidAction
        var accepted: Bool?

        guard case .custom(_, nil) = action.handler else {
            Issue.record("Expected invalidAction to use a custom handler without a fallback")
            return
        }

        action(inputURL) { accepted = $0 }

        #expect(!action.isDefault)
        #expect(accepted == false)
    }

    @Test
    func emptyEnvironmentUsesInvalidActions() throws {
        let inputURL = try #require(URL(string: "https://example.com"))
        let environment = emptyEnvironment()
        var openURLAccepted: Bool?
        var sensitiveURLAccepted: Bool?

        environment._openURL(inputURL) { openURLAccepted = $0 }
        environment._openSensitiveURL(inputURL) { sensitiveURLAccepted = $0 }

        #expect(openURLAccepted == false)
        #expect(sensitiveURLAccepted == false)
    }

    @Test
    func openURLPreservesExplicitSystemAction() throws {
        let inputURL = try #require(URL(string: "https://example.com"))
        var environment = emptyEnvironment()
        var receivedURL: URL?
        var accepted: Bool?

        environment._openURL = OpenURLAction { url, completion in
            receivedURL = url
            completion(true)
        }

        environment._openURL(inputURL) { accepted = $0 }

        #expect(receivedURL == inputURL)
        #expect(accepted == true)
    }

    @Test
    func openURLRebuildsCustomActionWithoutFallback() throws {
        let inputURL = try #require(URL(string: "https://example.com"))
        var environment = emptyEnvironment()
        var userHandlerCallCount = 0
        var originalFallbackCallCount = 0

        environment._openURL = OpenURLAction(
            handler: .custom(
                { _ in
                    userHandlerCallCount += 1
                    return .handled
                },
                fallback: { _, _ in
                    originalFallbackCallCount += 1
                }
            )
        )

        let resolvedAction = environment._openURL
        guard case let .custom(_, fallback) = resolvedAction.handler else {
            Issue.record("Expected a custom handler")
            return
        }
        var accepted: Bool?

        resolvedAction(inputURL) { accepted = $0 }

        #expect(fallback == nil)
        #expect(userHandlerCallCount == 1)
        #expect(originalFallbackCallCount == 0)
        #expect(accepted == true)
    }

    @Test
    func defaultActionIsIgnoredForOpenURLButPreservedForSensitiveURL() throws {
        let inputURL = try #require(URL(string: "https://example.com"))
        var environment = emptyEnvironment()
        var systemHandlerCallCount = 0
        let defaultAction = OpenURLAction(isDefault: true) { _, completion in
            systemHandlerCallCount += 1
            completion(true)
        }

        environment._openURL = defaultAction
        environment._openSensitiveURL = defaultAction

        var openURLAccepted: Bool?
        var sensitiveURLAccepted: Bool?
        environment._openURL(inputURL) { openURLAccepted = $0 }
        environment._openSensitiveURL(inputURL) { sensitiveURLAccepted = $0 }

        #expect(openURLAccepted == false)
        #expect(sensitiveURLAccepted == true)
        #expect(systemHandlerCallCount == 1)
    }
    #endif

    private func emptyEnvironment() -> EnvironmentValues {
        EnvironmentValues(PropertyList())
    }
}
