(function () {
  "use strict";

  // Ace's bundled Swift mode still uses a pre-concurrency keyword table. Keep
  // its tokenizer for strings, comments, and operators, but augment the exact
  // identifier rule with keywords used by the Swift toolchain for this
  // playground. This remains lexical highlighting, not semantic analysis.
  ace.define(
    "ace/mode/swift6_highlight_rules",
    [
      "require",
      "exports",
      "module",
      "ace/lib/oop",
      "ace/mode/swift_highlight_rules",
    ],
    function (require, exports) {
      const oop = require("ace/lib/oop");
      const BaseHighlightRules = require("ace/mode/swift_highlight_rules")
        .SwiftHighlightRules;
      const identifierPattern = /[a-zA-Z_$][a-zA-Z_$\d\u0080-\ufffe]*/;
      const additionalKeywords = [
        "Any",
        "Protocol",
        "actor",
        "any",
        "associatedtype",
        "async",
        "await",
        "borrowing",
        "catch",
        "consume",
        "consuming",
        "copy",
        "distributed",
        "each",
        "indirect",
        "isolated",
        "macro",
        "nonisolated",
        "package",
        "precedencegroup",
        "repeat",
        "rethrows",
        "sending",
        "some",
        "throw",
        "throws",
        "try",
      ];
      const keywordLookup = Object.create(null);
      for (const keyword of additionalKeywords) {
        keywordLookup[keyword] = true;
      }

      const Swift6HighlightRules = function () {
        BaseHighlightRules.call(this);

        const identifierRules = this.$rules.start.filter((rule) => (
          rule.regex instanceof RegExp
          && rule.regex.source === identifierPattern.source
          && typeof rule.token === "function"
        ));
        if (identifierRules.length !== 1) {
          throw new Error("Unexpected Ace Swift identifier rule");
        }

        const identifierRule = identifierRules[0];
        const baseToken = identifierRule.token;
        if (
          baseToken("struct") !== "keyword"
          || baseToken("__openSwiftUISwift6Probe") !== "identifier"
        ) {
          throw new Error("Unexpected Ace Swift keyword mapper");
        }
        identifierRule.token = (value) => (
          keywordLookup[value] ? "keyword" : baseToken(value)
        );
        this.$keywordList.push(...additionalKeywords);
      };
      oop.inherits(Swift6HighlightRules, BaseHighlightRules);
      exports.Swift6HighlightRules = Swift6HighlightRules;
      exports.HighlightRules = Swift6HighlightRules;
    }
  );

  ace.define(
    "ace/mode/swift6",
    [
      "require",
      "exports",
      "module",
      "ace/lib/oop",
      "ace/mode/swift",
      "ace/mode/swift6_highlight_rules",
    ],
    function (require, exports) {
      const oop = require("ace/lib/oop");
      const BaseMode = require("ace/mode/swift").Mode;
      const Swift6HighlightRules = require("ace/mode/swift6_highlight_rules")
        .Swift6HighlightRules;
      const Mode = function () {
        BaseMode.call(this);
        this.HighlightRules = Swift6HighlightRules;
      };
      oop.inherits(Mode, BaseMode);
      Mode.prototype.$id = "ace/mode/swift6";
      exports.Mode = Mode;
    }
  );
})();
