#!/bin/bash

set -euo pipefail

result_bundle="${1:?Missing xcresult bundle path}"
test_identifier="${2:?Missing test identifier}"
mode="${3:-verify}"

case "$mode" in
    verify|record) ;;
    *) echo "Unknown test result mode: $mode" >&2; exit 64 ;;
esac

xcrun xcresulttool get test-results summary --path "$result_bundle" --compact |
    ruby -rjson -e '
      summary = JSON.parse(STDIN.read)
      executed = summary.fetch("totalTestCount") - summary.fetch("skippedTests")
      if executed <= 0
        abort("::error::No UI tests ran for #{ARGV.fetch(0)}. Check the identifier, including (), and whether the test is disabled.")
      end
      puts "Executed #{executed} UI test(s) for #{ARGV.fetch(0)}."
      if ARGV.fetch(1) == "record" || summary.fetch("failedTests", 0) > 0
        # The summary contains only the first failure for each test case.
        test_json = IO.popen([
          "xcrun", "xcresulttool", "get", "test-results", "tests",
          "--path", ARGV.fetch(2), "--compact"
        ], &:read)
        abort("::error::Unable to read all test failures.") unless $?.success?

        def failure_messages(node)
          return [node.fetch("name", "")] if node["nodeType"] == "Failure Message"
          messages = node.fetch("children", []).flat_map { |child| failure_messages(child) }
          if messages.empty? && node["result"] == "Failed" && ["Test Case", "Arguments"].include?(node["nodeType"])
            return ["Missing failure details for #{node.fetch("name", "test case")}."]
          end
          messages
        end

        failures = JSON.parse(test_json).fetch("testNodes").flat_map { |node| failure_messages(node) }
        if ARGV.fetch(1) == "verify"
          failures.each do |failure|
            message = failure.gsub("%", "%25").gsub("\r", "%0D").gsub("\n", "%0A")
            warn "::error::#{message}"
          end
          if failures.any? { |failure| failure.include?("No reference was found on disk.") }
            warn "::error::Snapshot references are missing. Run the snapshot workflow with update_reference=true to record SwiftUI references for this platform and OS version."
          end
          abort("::error::Tests failed for #{ARGV.fetch(0)}.")
        end
        if failures.empty?
          abort("::error::The failed recording run has no snapshot recording issues.")
        end
        unexpected = failures.reject do |failure|
          failure.match?(/\A(?:[^\n]+:\d+: )?(?:Issue recorded: )?Record mode is on\. Automatically recorded snapshot:/)
        end
        unless unexpected.empty?
          abort("::error::Unexpected failure during snapshot recording: #{unexpected.first}")
        end
        puts "Accepted #{failures.length} snapshot recording issue(s) for #{ARGV.fetch(0)}."
      end
    ' "$test_identifier" "$mode" "$result_bundle"
