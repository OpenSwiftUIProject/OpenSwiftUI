//
//  RuntimeIssueHandlingTrait.swift
//  OpenSwiftUICoreTests

import Foundation
import Testing

func containsRuntimeIssue(_ message: String) -> ContainsRuntimeIssueTrait {
    ContainsRuntimeIssueTrait(message: message)
}

struct ContainsRuntimeIssueTrait: TestTrait, TestScoping {
    typealias TestScopeProvider = ContainsRuntimeIssueTrait

    var message: String

    func provideScope(
        for test: Test,
        testCase: Test.Case?,
        performing function: @Sendable () async throws -> Void
    ) async throws {
        let state = RuntimeIssueState()
        let issueHandler = IssueHandlingTrait.compactMapIssues { issue in
            if issue.isRuntimeIssue(message) {
                state.recordMatch()
                return nil
            } else {
                return issue
            }
        }
        try await issueHandler.provideScope(for: test, testCase: testCase, performing: function)
        if !state.hasMatch {
            Issue.record(
                #"Expected runtime issue was not recorded: "\#(message)""#,
                sourceLocation: test.sourceLocation
            )
        }
    }
}

private final class RuntimeIssueState: @unchecked Sendable {
    private let lock = NSLock()
    private var _hasMatch = false

    var hasMatch: Bool {
        lock.withLock { _hasMatch }
    }

    func recordMatch() {
        lock.withLock {
            _hasMatch = true
        }
    }
}

private extension Issue {
    func isRuntimeIssue(_ message: String) -> Bool {
        comments.contains { comment in
            comment.rawValue.hasPrefix(#"[Runtime Issue] message: \#(message) args:"#)
        }
    }
}
