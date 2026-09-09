//
//  CourseCatalog.swift
//  RegexDojo
//
//  Bundled 25-lesson curriculum and course-data decoder.
//
//  Created by Tyler Hostager on 2026-09-09.
//  Copyright © 2026 Tyler Hostager. All rights reserved.
//

import Foundation

/// Owns and decodes the bundled RegexDojo curriculum.
///
/// Course content is embedded as JSON so lesson data stays declarative while the
/// runtime model remains strongly typed. A decode failure is treated as a bundled
/// data defect and triggers an assertion in debug builds.
enum CourseCatalog {
    /// All bundled lessons in display order.
    static let lessons: [RegexLesson] = {
        let data = Data(courseJSON.utf8)
        do {
            return try JSONDecoder().decode([RegexLesson].self, from: data)
        } catch {
            assertionFailure("Failed to decode bundled course: \(error)")
            return []
        }
    }()

    /// Total number of exercises across every bundled lesson.
    static var totalExerciseCount: Int {
        lessons.reduce(0) { partialResult, lesson in
            partialResult + lesson.exercises.count
        }
    }

    private static let courseJSON = #"""
[
  {
    "id": "L01",
    "number": 1,
    "title": "Literal Matches",
    "subtitle": "Start by finding exact text inside larger strings.",
    "overview": "A regular expression can be as simple as ordinary text. Literal characters match themselves, and regex engines search for that text inside the input unless you explicitly anchor the pattern.",
    "concepts": [
      "Literal characters",
      "Search-style matching",
      "Case sensitivity"
    ],
    "exercises": [
      {
        "id": "L01E01",
        "title": "Find “cat”",
        "prompt": "Match the literal text cat anywhere in the input.",
        "solution": "cat",
        "requiredMatches": [
          "the cat naps",
          "catapult? no: cat is here",
          "copycat",
          "cat"
        ],
        "mustNotMatch": [
          "dog",
          "CAT",
          "c a t"
        ],
        "hint": "Type the text exactly as it appears.",
        "explanation": "Literal characters need no special syntax.",
        "matchMode": "contains"
      },
      {
        "id": "L01E02",
        "title": "Find an error tag",
        "prompt": "Match the literal text ERROR.",
        "solution": "ERROR",
        "requiredMatches": [
          "ERROR: disk full",
          "[ERROR] timeout",
          "last ERROR seen",
          "ERROR"
        ],
        "mustNotMatch": [
          "Error: disk full",
          "warning",
          "error"
        ],
        "hint": "Regex is case-sensitive unless you enable a flag.",
        "explanation": "Uppercase and lowercase are different by default.",
        "matchMode": "contains"
      },
      {
        "id": "L01E03",
        "title": "Find 2026",
        "prompt": "Match the literal sequence 2026.",
        "solution": "2026",
        "requiredMatches": [
          "Build 2026.09",
          "© 2026",
          "2026 roadmap",
          "release-2026-beta"
        ],
        "mustNotMatch": [
          "2025",
          "20 26",
          "226"
        ],
        "hint": "Digits can be literal characters too.",
        "explanation": "A sequence of digits is matched exactly unless quantifiers or classes are introduced.",
        "matchMode": "contains"
      },
      {
        "id": "L01E04",
        "title": "Find Swift",
        "prompt": "Match the literal word fragment Swift.",
        "solution": "Swift",
        "requiredMatches": [
          "SwiftUI",
          "Learning Swift",
          "Swift 6",
          "Swift"
        ],
        "mustNotMatch": [
          "swift",
          "SWIFT",
          "Kotlin"
        ],
        "hint": "No special operators are needed yet.",
        "explanation": "This is a direct literal search.",
        "matchMode": "contains"
      },
      {
        "id": "L01E05",
        "title": "Find TODO",
        "prompt": "Locate TODO inside source-like text.",
        "solution": "TODO",
        "requiredMatches": [
          "// TODO: refactor",
          "# TODO fix",
          "TODO()",
          "prefixTODOsuffix"
        ],
        "mustNotMatch": [
          "todo",
          "FIXME",
          "TO-DO"
        ],
        "hint": "Remember: search mode can find the pattern inside a larger string.",
        "explanation": "Search-style matching is useful for logs and source scanning.",
        "matchMode": "contains"
      }
    ],
    "advancedNote": null
  },
  {
    "id": "L02",
    "number": 2,
    "title": "Wildcards & Escaping",
    "subtitle": "Use dot as “any character,” then escape metacharacters.",
    "overview": "The dot metacharacter matches almost any single character. A backslash turns many special characters back into literals, such as \\. for a real period.",
    "concepts": [
      ". wildcard",
      "Escaping with \\",
      "Literal punctuation"
    ],
    "exercises": [
      {
        "id": "L02E01",
        "title": "c?t pattern",
        "prompt": "Match c, any one character, then t.",
        "solution": "c.t",
        "requiredMatches": [
          "cat",
          "cot",
          "c9t",
          "c-t"
        ],
        "mustNotMatch": [
          "ct",
          "coat",
          "cut!"
        ],
        "hint": "The middle character can be represented by a dot.",
        "explanation": "A dot consumes exactly one character here.",
        "matchMode": "full"
      },
      {
        "id": "L02E02",
        "title": "Literal file extension",
        "prompt": "Match names ending in a literal .txt.",
        "solution": ".+\\.txt",
        "requiredMatches": [
          "notes.txt",
          "a.txt",
          "report.final.txt",
          "123.txt"
        ],
        "mustNotMatch": [
          "notesxt",
          "txt",
          "notes.txt.bak"
        ],
        "hint": "Escape the period so it is not treated as a wildcard.",
        "explanation": "\\. means a literal dot; .+ before it requires at least one preceding character.",
        "matchMode": "full"
      },
      {
        "id": "L02E03",
        "title": "Three-character code",
        "prompt": "Match exactly A, any one character, then Z.",
        "solution": "A.Z",
        "requiredMatches": [
          "ABZ",
          "A0Z",
          "A-Z",
          "A Z"
        ],
        "mustNotMatch": [
          "AZ",
          "A12Z",
          "aBZ"
        ],
        "hint": "Use one wildcard between the literals.",
        "explanation": "The dot represents one arbitrary character.",
        "matchMode": "full"
      },
      {
        "id": "L02E04",
        "title": "Literal question mark",
        "prompt": "Find the literal text ready?.",
        "solution": "ready\\?",
        "requiredMatches": [
          "ready?",
          "Are you ready?",
          "ready? yes",
          "not ready?"
        ],
        "mustNotMatch": [
          "ready!",
          "ready",
          "Ready?"
        ],
        "hint": "Question mark is a regex operator, so escape it.",
        "explanation": "\\? matches an actual question-mark character.",
        "matchMode": "contains"
      },
      {
        "id": "L02E05",
        "title": "Literal brackets",
        "prompt": "Find the literal token [OK].",
        "solution": "\\[OK\\]",
        "requiredMatches": [
          "[OK]",
          "status [OK]",
          "[OK] done",
          "x[OK]y"
        ],
        "mustNotMatch": [
          "OK",
          "[NO]",
          "(OK)"
        ],
        "hint": "Square brackets are special in regex.",
        "explanation": "Escaping both brackets makes them literal characters.",
        "matchMode": "contains"
      }
    ],
    "advancedNote": null
  },
  {
    "id": "L03",
    "number": 3,
    "title": "Character Classes",
    "subtitle": "Choose one character from a set or range.",
    "overview": "Square brackets define a character class. [abc] matches one of a, b, or c; ranges like [0-9] and [A-F] make compact sets.",
    "concepts": [
      "Character classes",
      "Ranges",
      "Combining ranges"
    ],
    "exercises": [
      {
        "id": "L03E01",
        "title": "Hex digit",
        "prompt": "Match exactly one uppercase hexadecimal digit.",
        "solution": "[0-9A-F]",
        "requiredMatches": [
          "0",
          "9",
          "A",
          "F"
        ],
        "mustNotMatch": [
          "G",
          "a",
          "10"
        ],
        "hint": "Build the pattern from the lesson concepts.",
        "explanation": "This solution applies the current lesson concept directly.",
        "matchMode": "full"
      },
      {
        "id": "L03E02",
        "title": "Simple vowel",
        "prompt": "Match exactly one lowercase vowel.",
        "solution": "[aeiou]",
        "requiredMatches": [
          "a",
          "e",
          "i",
          "u"
        ],
        "mustNotMatch": [
          "b",
          "A",
          "ae"
        ],
        "hint": "Build the pattern from the lesson concepts.",
        "explanation": "This solution applies the current lesson concept directly.",
        "matchMode": "full"
      },
      {
        "id": "L03E03",
        "title": "Letter then digit",
        "prompt": "Match one uppercase letter followed by one digit.",
        "solution": "[A-Z][0-9]",
        "requiredMatches": [
          "A1",
          "Z9",
          "Q0",
          "M7"
        ],
        "mustNotMatch": [
          "a1",
          "AA",
          "123"
        ],
        "hint": "Build the pattern from the lesson concepts.",
        "explanation": "This solution applies the current lesson concept directly.",
        "matchMode": "full"
      },
      {
        "id": "L03E04",
        "title": "RGB channel initial",
        "prompt": "Match exactly R, G, or B.",
        "solution": "[RGB]",
        "requiredMatches": [
          "R",
          "G",
          "B",
          "R"
        ],
        "mustNotMatch": [
          "C",
          "r",
          "RG"
        ],
        "hint": "Build the pattern from the lesson concepts.",
        "explanation": "This solution applies the current lesson concept directly.",
        "matchMode": "full"
      },
      {
        "id": "L03E05",
        "title": "Lowercase identifier start",
        "prompt": "Match exactly one lowercase ASCII letter or underscore.",
        "solution": "[a-z_]",
        "requiredMatches": [
          "a",
          "z",
          "m",
          "_"
        ],
        "mustNotMatch": [
          "A",
          "7",
          "__"
        ],
        "hint": "Build the pattern from the lesson concepts.",
        "explanation": "This solution applies the current lesson concept directly.",
        "matchMode": "full"
      }
    ],
    "advancedNote": null
  },
  {
    "id": "L04",
    "number": 4,
    "title": "Negated Classes",
    "subtitle": "Match characters that are not in a set.",
    "overview": "A caret immediately after [ negates the class. For example, [^0-9] matches one character that is not an ASCII digit.",
    "concepts": [
      "Negated classes",
      "Excluding ranges",
      "Combining positive and negative rules"
    ],
    "exercises": [
      {
        "id": "L04E01",
        "title": "Not a digit",
        "prompt": "Match exactly one character that is not an ASCII digit.",
        "solution": "[^0-9]",
        "requiredMatches": [
          "a",
          "-",
          " ",
          "_"
        ],
        "mustNotMatch": [
          "0",
          "7",
          "9"
        ],
        "hint": "Build the pattern from the lesson concepts.",
        "explanation": "This solution applies the current lesson concept directly.",
        "matchMode": "full"
      },
      {
        "id": "L04E02",
        "title": "Not a vowel",
        "prompt": "Match exactly one lowercase consonant.",
        "solution": "[^aeiou0-9A-Z\\W_]",
        "requiredMatches": [
          "b",
          "c",
          "x",
          "z"
        ],
        "mustNotMatch": [
          "a",
          "e",
          "7",
          "A"
        ],
        "hint": "Build the pattern from the lesson concepts.",
        "explanation": "This solution applies the current lesson concept directly.",
        "matchMode": "full"
      },
      {
        "id": "L04E03",
        "title": "Two non-digits",
        "prompt": "Match exactly two characters, neither of which is a digit.",
        "solution": "[^0-9][^0-9]",
        "requiredMatches": [
          "ab",
          "--",
          "_x",
          "  "
        ],
        "mustNotMatch": [
          "a1",
          "2b",
          "99"
        ],
        "hint": "Build the pattern from the lesson concepts.",
        "explanation": "This solution applies the current lesson concept directly.",
        "matchMode": "full"
      },
      {
        "id": "L04E04",
        "title": "Filename-safe chunk",
        "prompt": "Match one or more characters excluding slash and colon.",
        "solution": "[^/:]+",
        "requiredMatches": [
          "notes.txt",
          "folder name",
          "abc_123",
          "x-y"
        ],
        "mustNotMatch": [
          "a/b",
          "C:tmp",
          "/"
        ],
        "hint": "Build the pattern from the lesson concepts.",
        "explanation": "This solution applies the current lesson concept directly.",
        "matchMode": "full"
      },
      {
        "id": "L04E05",
        "title": "Non-whitespace token",
        "prompt": "Match one or more characters that are not whitespace.",
        "solution": "[^\\s]+",
        "requiredMatches": [
          "hello",
          "a_b",
          "123",
          "x-y"
        ],
        "mustNotMatch": [
          "hello world",
          " ",
          "a\tb"
        ],
        "hint": "Build the pattern from the lesson concepts.",
        "explanation": "This solution applies the current lesson concept directly.",
        "matchMode": "full"
      }
    ],
    "advancedNote": null
  },
  {
    "id": "L05",
    "number": 5,
    "title": "Shorthand Classes",
    "subtitle": "Use compact classes for digits, words, and whitespace.",
    "overview": "Common shorthands include \\d for digits, \\w for word characters, and \\s for whitespace. Their uppercase forms negate the class.",
    "concepts": [
      "\\d / \\D",
      "\\w / \\W",
      "\\s / \\S"
    ],
    "exercises": [
      {
        "id": "L05E01",
        "title": "Four digits",
        "prompt": "Match exactly four digits.",
        "solution": "\\d\\d\\d\\d",
        "requiredMatches": [
          "2026",
          "0000",
          "4815",
          "9999"
        ],
        "mustNotMatch": [
          "123",
          "12a4",
          "12345"
        ],
        "hint": "Build the pattern from the lesson concepts.",
        "explanation": "This solution applies the current lesson concept directly.",
        "matchMode": "full"
      },
      {
        "id": "L05E02",
        "title": "Word token",
        "prompt": "Match one or more word characters.",
        "solution": "\\w+",
        "requiredMatches": [
          "hello",
          "user_42",
          "ABC",
          "123"
        ],
        "mustNotMatch": [
          "hello-world",
          "two words",
          "!"
        ],
        "hint": "Build the pattern from the lesson concepts.",
        "explanation": "This solution applies the current lesson concept directly.",
        "matchMode": "full"
      },
      {
        "id": "L05E03",
        "title": "Whitespace only",
        "prompt": "Match one or more whitespace characters.",
        "solution": "\\s+",
        "requiredMatches": [
          " ",
          "   ",
          "\t",
          "\n"
        ],
        "mustNotMatch": [
          "a",
          "_",
          " x"
        ],
        "hint": "Build the pattern from the lesson concepts.",
        "explanation": "This solution applies the current lesson concept directly.",
        "matchMode": "full"
      },
      {
        "id": "L05E04",
        "title": "Digit + word",
        "prompt": "Match a digit followed by two word characters.",
        "solution": "\\d\\w\\w",
        "requiredMatches": [
          "1ab",
          "9_Z",
          "0x7",
          "5AA"
        ],
        "mustNotMatch": [
          "ab1",
          "1-a",
          "12"
        ],
        "hint": "Build the pattern from the lesson concepts.",
        "explanation": "This solution applies the current lesson concept directly.",
        "matchMode": "full"
      },
      {
        "id": "L05E05",
        "title": "No whitespace",
        "prompt": "Match a string made entirely of non-whitespace characters.",
        "solution": "\\S+",
        "requiredMatches": [
          "abc",
          "a-b",
          "123",
          "!@#"
        ],
        "mustNotMatch": [
          "a b",
          " ",
          "x\ty"
        ],
        "hint": "Build the pattern from the lesson concepts.",
        "explanation": "This solution applies the current lesson concept directly.",
        "matchMode": "full"
      }
    ],
    "advancedNote": null
  },
  {
    "id": "L06",
    "number": 6,
    "title": "Basic Quantifiers",
    "subtitle": "Repeat tokens with *, +, and ?.",
    "overview": "* means zero-or-more, + means one-or-more, and ? means zero-or-one of the preceding token or group.",
    "concepts": [
      "* zero-or-more",
      "+ one-or-more",
      "? optional"
    ],
    "exercises": [
      {
        "id": "L06E01",
        "title": "One or more digits",
        "prompt": "Match a nonempty run of digits.",
        "solution": "\\d+",
        "requiredMatches": [
          "1",
          "42",
          "2026",
          "000123"
        ],
        "mustNotMatch": [
          "",
          "12a",
          "a12"
        ],
        "hint": "Build the pattern from the lesson concepts.",
        "explanation": "This solution applies the current lesson concept directly.",
        "matchMode": "full"
      },
      {
        "id": "L06E02",
        "title": "Zero or more a’s",
        "prompt": "Match strings containing only zero or more a characters.",
        "solution": "a*",
        "requiredMatches": [
          "",
          "a",
          "aa",
          "aaaa"
        ],
        "mustNotMatch": [
          "b",
          "ab",
          "aaa!"
        ],
        "hint": "Build the pattern from the lesson concepts.",
        "explanation": "This solution applies the current lesson concept directly.",
        "matchMode": "full"
      },
      {
        "id": "L06E03",
        "title": "Optional u",
        "prompt": "Match both color and colour.",
        "solution": "colou?r",
        "requiredMatches": [
          "color",
          "colour",
          "color",
          "colour"
        ],
        "mustNotMatch": [
          "colouur",
          "collor",
          "Color"
        ],
        "hint": "Build the pattern from the lesson concepts.",
        "explanation": "This solution applies the current lesson concept directly.",
        "matchMode": "full"
      },
      {
        "id": "L06E04",
        "title": "Signed integer",
        "prompt": "Match an optional minus sign followed by digits.",
        "solution": "-?\\d+",
        "requiredMatches": [
          "42",
          "-7",
          "0",
          "-2026"
        ],
        "mustNotMatch": [
          "+4",
          "--3",
          "4.2"
        ],
        "hint": "Build the pattern from the lesson concepts.",
        "explanation": "This solution applies the current lesson concept directly.",
        "matchMode": "full"
      },
      {
        "id": "L06E05",
        "title": "Simple identifier",
        "prompt": "Match one letter followed by zero or more word characters.",
        "solution": "[A-Za-z]\\w*",
        "requiredMatches": [
          "a",
          "hello",
          "A1",
          "z_name"
        ],
        "mustNotMatch": [
          "_x",
          "9abc",
          "a-b"
        ],
        "hint": "Build the pattern from the lesson concepts.",
        "explanation": "This solution applies the current lesson concept directly.",
        "matchMode": "full"
      }
    ],
    "advancedNote": null
  },
  {
    "id": "L07",
    "number": 7,
    "title": "Counted Quantifiers",
    "subtitle": "Specify exact and bounded repetition.",
    "overview": "Curly-brace quantifiers let you say exactly how many repetitions are allowed: {3}, {2,4}, or {3,}.",
    "concepts": [
      "{n}",
      "{n,m}",
      "{n,}"
    ],
    "exercises": [
      {
        "id": "L07E01",
        "title": "US ZIP core",
        "prompt": "Match exactly five digits.",
        "solution": "\\d{5}",
        "requiredMatches": [
          "78701",
          "10001",
          "90210",
          "60601"
        ],
        "mustNotMatch": [
          "1234",
          "123456",
          "ABCDE"
        ],
        "hint": "Build the pattern from the lesson concepts.",
        "explanation": "This solution applies the current lesson concept directly.",
        "matchMode": "full"
      },
      {
        "id": "L07E02",
        "title": "2–4 lowercase letters",
        "prompt": "Match between two and four lowercase ASCII letters.",
        "solution": "[a-z]{2,4}",
        "requiredMatches": [
          "ab",
          "xyz",
          "test",
          "go"
        ],
        "mustNotMatch": [
          "a",
          "abcde",
          "AB"
        ],
        "hint": "Build the pattern from the lesson concepts.",
        "explanation": "This solution applies the current lesson concept directly.",
        "matchMode": "full"
      },
      {
        "id": "L07E03",
        "title": "At least three digits",
        "prompt": "Match three or more digits.",
        "solution": "\\d{3,}",
        "requiredMatches": [
          "123",
          "2026",
          "0000",
          "999999"
        ],
        "mustNotMatch": [
          "12",
          "1a3",
          ""
        ],
        "hint": "Build the pattern from the lesson concepts.",
        "explanation": "This solution applies the current lesson concept directly.",
        "matchMode": "full"
      },
      {
        "id": "L07E04",
        "title": "Hex byte",
        "prompt": "Match exactly two hexadecimal digits, case-insensitive via explicit classes.",
        "solution": "[0-9A-Fa-f]{2}",
        "requiredMatches": [
          "00",
          "AF",
          "c3",
          "9b"
        ],
        "mustNotMatch": [
          "F",
          "GG",
          "123"
        ],
        "hint": "Build the pattern from the lesson concepts.",
        "explanation": "This solution applies the current lesson concept directly.",
        "matchMode": "full"
      },
      {
        "id": "L07E05",
        "title": "Username length",
        "prompt": "Match 4–12 word characters.",
        "solution": "\\w{4,12}",
        "requiredMatches": [
          "user",
          "dev_2026",
          "abcd",
          "abcdefghijkl"
        ],
        "mustNotMatch": [
          "abc",
          "abcdefghijklm",
          "a-bc"
        ],
        "hint": "Build the pattern from the lesson concepts.",
        "explanation": "This solution applies the current lesson concept directly.",
        "matchMode": "full"
      }
    ],
    "advancedNote": null
  },
  {
    "id": "L08",
    "number": 8,
    "title": "Anchors",
    "subtitle": "Control where a match may begin or end.",
    "overview": "^ anchors the beginning and $ anchors the end. Anchors are crucial when you need to validate an entire line rather than merely find a substring.",
    "concepts": [
      "^ start",
      "$ end",
      "Validation patterns"
    ],
    "exercises": [
      {
        "id": "L08E01",
        "title": "Starts with INFO",
        "prompt": "Match strings that begin with INFO.",
        "solution": "^INFO",
        "requiredMatches": [
          "INFO ready",
          "INFO",
          "INFO: ok",
          "INFO123"
        ],
        "mustNotMatch": [
          "xINFO",
          " info",
          "WARN INFO"
        ],
        "hint": "The caret anchors the beginning.",
        "explanation": "^ forces INFO to appear at the start.",
        "matchMode": "contains"
      },
      {
        "id": "L08E02",
        "title": "Ends with .swift",
        "prompt": "Match strings ending in .swift.",
        "solution": "\\.swift$",
        "requiredMatches": [
          "App.swift",
          "main.swift",
          "My View.swift",
          "x.swift"
        ],
        "mustNotMatch": [
          "swift.txt",
          "x.swift.bak",
          "SWIFT"
        ],
        "hint": "Escape the dot and anchor the end.",
        "explanation": "The dollar sign requires the suffix to be at the end.",
        "matchMode": "contains"
      },
      {
        "id": "L08E03",
        "title": "Exact yes",
        "prompt": "Match only the complete string yes.",
        "solution": "^yes$",
        "requiredMatches": [
          "yes",
          "yes",
          "yes",
          "yes"
        ],
        "mustNotMatch": [
          " yes",
          "yes!",
          "yesterday"
        ],
        "hint": "Build the pattern from the lesson concepts.",
        "explanation": "This solution applies the current lesson concept directly.",
        "matchMode": "full"
      },
      {
        "id": "L08E04",
        "title": "Whole integer",
        "prompt": "Validate an optional minus sign and one or more digits.",
        "solution": "^-?\\d+$",
        "requiredMatches": [
          "0",
          "42",
          "-7",
          "-2026"
        ],
        "mustNotMatch": [
          "4.2",
          "x42",
          "42x"
        ],
        "hint": "Build the pattern from the lesson concepts.",
        "explanation": "This solution applies the current lesson concept directly.",
        "matchMode": "full"
      },
      {
        "id": "L08E05",
        "title": "Whole slug",
        "prompt": "Validate a lowercase slug made of letters, digits, and hyphens.",
        "solution": "^[a-z0-9]+(?:-[a-z0-9]+)*$",
        "requiredMatches": [
          "hello",
          "regex-lab",
          "v2-beta",
          "a1-b2-c3"
        ],
        "mustNotMatch": [
          "Hello",
          "-bad",
          "bad-",
          "two words"
        ],
        "hint": "Build the pattern from the lesson concepts.",
        "explanation": "This solution applies the current lesson concept directly.",
        "matchMode": "full"
      }
    ],
    "advancedNote": null
  },
  {
    "id": "L09",
    "number": 9,
    "title": "Alternation",
    "subtitle": "Choose between alternative patterns.",
    "overview": "The pipe operator | means “or.” Grouping often keeps alternation scoped to the part of a pattern you intend.",
    "concepts": [
      "| alternation",
      "Grouping alternatives",
      "Shared prefixes/suffixes"
    ],
    "exercises": [
      {
        "id": "L09E01",
        "title": "Yes or no",
        "prompt": "Match exactly yes or no.",
        "solution": "(?:yes|no)",
        "requiredMatches": [
          "yes",
          "no",
          "yes",
          "no"
        ],
        "mustNotMatch": [
          "maybe",
          "Yes",
          "y"
        ],
        "hint": "Build the pattern from the lesson concepts.",
        "explanation": "This solution applies the current lesson concept directly.",
        "matchMode": "full"
      },
      {
        "id": "L09E02",
        "title": "Image extension",
        "prompt": "Match png, jpg, jpeg, or gif.",
        "solution": "(?:png|jpe?g|gif)",
        "requiredMatches": [
          "png",
          "jpg",
          "jpeg",
          "gif"
        ],
        "mustNotMatch": [
          "bmp",
          "JPG",
          "jpegx"
        ],
        "hint": "Build the pattern from the lesson concepts.",
        "explanation": "This solution applies the current lesson concept directly.",
        "matchMode": "full"
      },
      {
        "id": "L09E03",
        "title": "HTTP method",
        "prompt": "Match GET, POST, PUT, or DELETE.",
        "solution": "(?:GET|POST|PUT|DELETE)",
        "requiredMatches": [
          "GET",
          "POST",
          "PUT",
          "DELETE"
        ],
        "mustNotMatch": [
          "PATCH",
          "get",
          "POSTS"
        ],
        "hint": "Build the pattern from the lesson concepts.",
        "explanation": "This solution applies the current lesson concept directly.",
        "matchMode": "full"
      },
      {
        "id": "L09E04",
        "title": "Cat or dog suffix",
        "prompt": "Match cat or dog followed by a digit.",
        "solution": "(?:cat|dog)\\d",
        "requiredMatches": [
          "cat1",
          "dog9",
          "cat0",
          "dog4"
        ],
        "mustNotMatch": [
          "bird1",
          "cat",
          "dog99"
        ],
        "hint": "Build the pattern from the lesson concepts.",
        "explanation": "This solution applies the current lesson concept directly.",
        "matchMode": "full"
      },
      {
        "id": "L09E05",
        "title": "Protocol",
        "prompt": "Match http or https followed by ://.",
        "solution": "https?://",
        "requiredMatches": [
          "http://",
          "https://",
          "http://",
          "https://"
        ],
        "mustNotMatch": [
          "ftp://",
          "http:/",
          "HTTPS://"
        ],
        "hint": "Build the pattern from the lesson concepts.",
        "explanation": "This solution applies the current lesson concept directly.",
        "matchMode": "full"
      }
    ],
    "advancedNote": null
  },
  {
    "id": "L10",
    "number": 10,
    "title": "Capturing Groups",
    "subtitle": "Group pieces and capture what matched.",
    "overview": "Parentheses group subpatterns and also create captures. Grouping lets a quantifier or alternation operate on multiple characters as one unit.",
    "concepts": [
      "(...) captures",
      "Grouped repetition",
      "Grouped alternation"
    ],
    "exercises": [
      {
        "id": "L10E01",
        "title": "Repeated “ha”",
        "prompt": "Match one or more repetitions of ha.",
        "solution": "(ha)+",
        "requiredMatches": [
          "ha",
          "haha",
          "hahaha",
          "hahahaha"
        ],
        "mustNotMatch": [
          "h",
          "haa",
          "ha!"
        ],
        "hint": "Build the pattern from the lesson concepts.",
        "explanation": "This solution applies the current lesson concept directly.",
        "matchMode": "full"
      },
      {
        "id": "L10E02",
        "title": "Date skeleton",
        "prompt": "Match YYYY-MM-DD using captures for each numeric part.",
        "solution": "(\\d{4})-(\\d{2})-(\\d{2})",
        "requiredMatches": [
          "2026-09-09",
          "2000-01-01",
          "1999-12-31",
          "2030-06-15"
        ],
        "mustNotMatch": [
          "26-09-09",
          "2026/09/09",
          "2026-9-9"
        ],
        "hint": "Build the pattern from the lesson concepts.",
        "explanation": "This solution applies the current lesson concept directly.",
        "matchMode": "full"
      },
      {
        "id": "L10E03",
        "title": "Area-code style",
        "prompt": "Match three digits, hyphen, then four digits; capture each side.",
        "solution": "(\\d{3})-(\\d{4})",
        "requiredMatches": [
          "555-1212",
          "512-5555",
          "000-0000",
          "999-1234"
        ],
        "mustNotMatch": [
          "55-1212",
          "5551212",
          "555-121"
        ],
        "hint": "Build the pattern from the lesson concepts.",
        "explanation": "This solution applies the current lesson concept directly.",
        "matchMode": "full"
      },
      {
        "id": "L10E04",
        "title": "Grouped suffix",
        "prompt": "Match dev followed by one of -ios, -web, or -api.",
        "solution": "dev-(ios|web|api)",
        "requiredMatches": [
          "dev-ios",
          "dev-web",
          "dev-api",
          "dev-ios"
        ],
        "mustNotMatch": [
          "dev-mac",
          "ios",
          "dev--api"
        ],
        "hint": "Build the pattern from the lesson concepts.",
        "explanation": "This solution applies the current lesson concept directly.",
        "matchMode": "full"
      },
      {
        "id": "L10E05",
        "title": "Pair repetition",
        "prompt": "Match exactly three repetitions of ab or cd.",
        "solution": "((?:ab|cd)){3}",
        "requiredMatches": [
          "ababab",
          "abcdab",
          "cdcdcd",
          "cdabcd"
        ],
        "mustNotMatch": [
          "ab",
          "abcd",
          "abababcd"
        ],
        "hint": "Build the pattern from the lesson concepts.",
        "explanation": "This solution applies the current lesson concept directly.",
        "matchMode": "full"
      }
    ],
    "advancedNote": null
  },
  {
    "id": "L11",
    "number": 11,
    "title": "Non-Capturing Groups",
    "subtitle": "Group without creating an unnecessary capture.",
    "overview": "(?:...) groups a subpattern without capturing it. This is useful when structure matters but the captured text does not.",
    "concepts": [
      "(?:...)",
      "Structural grouping",
      "Cleaner capture numbering"
    ],
    "exercises": [
      {
        "id": "L11E01",
        "title": "Repeated pair",
        "prompt": "Match one or more ab pairs using a non-capturing group.",
        "solution": "(?:ab)+",
        "requiredMatches": [
          "ab",
          "abab",
          "ababab",
          "abababab"
        ],
        "mustNotMatch": [
          "a",
          "aba",
          "abx"
        ],
        "hint": "Build the pattern from the lesson concepts.",
        "explanation": "This solution applies the current lesson concept directly.",
        "matchMode": "full"
      },
      {
        "id": "L11E02",
        "title": "Protocol choice",
        "prompt": "Match http:// or https:// without capturing the protocol choice.",
        "solution": "(?:http|https)://",
        "requiredMatches": [
          "http://",
          "https://",
          "http://",
          "https://"
        ],
        "mustNotMatch": [
          "ftp://",
          "http:/",
          "https:"
        ],
        "hint": "Build the pattern from the lesson concepts.",
        "explanation": "This solution applies the current lesson concept directly.",
        "matchMode": "full"
      },
      {
        "id": "L11E03",
        "title": "Optional country code",
        "prompt": "Match an optional +1- prefix before 10 digits.",
        "solution": "(?:\\+1-)?\\d{10}",
        "requiredMatches": [
          "5125551212",
          "+1-5125551212",
          "2125550000",
          "+1-9998887777"
        ],
        "mustNotMatch": [
          "1-5125551212",
          "+1-123",
          "512-555-1212"
        ],
        "hint": "Build the pattern from the lesson concepts.",
        "explanation": "This solution applies the current lesson concept directly.",
        "matchMode": "full"
      },
      {
        "id": "L11E04",
        "title": "File extension set",
        "prompt": "Match a filename stem and one of .js, .ts, or .swift.",
        "solution": ".+\\.(?:js|ts|swift)",
        "requiredMatches": [
          "app.js",
          "main.ts",
          "View.swift",
          "a.b.js"
        ],
        "mustNotMatch": [
          "app.jsx",
          "swift",
          "file.py"
        ],
        "hint": "Build the pattern from the lesson concepts.",
        "explanation": "This solution applies the current lesson concept directly.",
        "matchMode": "full"
      },
      {
        "id": "L11E05",
        "title": "Three alternatives repeated",
        "prompt": "Match two tokens chosen from red, green, blue separated by a comma.",
        "solution": "(?:red|green|blue),(?:red|green|blue)",
        "requiredMatches": [
          "red,blue",
          "green,red",
          "blue,blue",
          "green,green"
        ],
        "mustNotMatch": [
          "red",
          "red,yellow",
          "red, blue"
        ],
        "hint": "Build the pattern from the lesson concepts.",
        "explanation": "This solution applies the current lesson concept directly.",
        "matchMode": "full"
      }
    ],
    "advancedNote": null
  },
  {
    "id": "L12",
    "number": 12,
    "title": "Backreferences",
    "subtitle": "Require later text to repeat an earlier capture.",
    "overview": "A backreference such as \\1 matches the exact text captured by group 1. This enables duplicate-word detection and paired delimiters.",
    "concepts": [
      "\\1 numeric backreference",
      "Repeated text",
      "Capture-dependent matching"
    ],
    "exercises": [
      {
        "id": "L12E01",
        "title": "Double word",
        "prompt": "Match the same lowercase word twice with a space between.",
        "solution": "([a-z]+) \\1",
        "requiredMatches": [
          "go go",
          "test test",
          "regex regex",
          "a a"
        ],
        "mustNotMatch": [
          "go stop",
          "Test Test",
          "go  go"
        ],
        "hint": "Build the pattern from the lesson concepts.",
        "explanation": "This solution applies the current lesson concept directly.",
        "matchMode": "full"
      },
      {
        "id": "L12E02",
        "title": "Repeated two digits",
        "prompt": "Match a two-digit sequence repeated immediately.",
        "solution": "(\\d{2})\\1",
        "requiredMatches": [
          "1212",
          "9999",
          "3434",
          "0000"
        ],
        "mustNotMatch": [
          "1234",
          "1213",
          "123"
        ],
        "hint": "Build the pattern from the lesson concepts.",
        "explanation": "This solution applies the current lesson concept directly.",
        "matchMode": "full"
      },
      {
        "id": "L12E03",
        "title": "Matching quote type",
        "prompt": "Match a simple quoted word using the same quote character on both ends.",
        "solution": "([\"'])\\w+\\1",
        "requiredMatches": [
          "\"hello\"",
          "'world'",
          "\"x\"",
          "'abc123'"
        ],
        "mustNotMatch": [
          "\"hello'",
          "hello",
          "\"two words\""
        ],
        "hint": "Build the pattern from the lesson concepts.",
        "explanation": "This solution applies the current lesson concept directly.",
        "matchMode": "full"
      },
      {
        "id": "L12E04",
        "title": "Mirrored first letter",
        "prompt": "Match a lowercase letter, digits, then the same letter.",
        "solution": "([a-z])\\d+\\1",
        "requiredMatches": [
          "a1a",
          "x42x",
          "z999z",
          "b0b"
        ],
        "mustNotMatch": [
          "a1b",
          "A1A",
          "aa"
        ],
        "hint": "Build the pattern from the lesson concepts.",
        "explanation": "This solution applies the current lesson concept directly.",
        "matchMode": "full"
      },
      {
        "id": "L12E05",
        "title": "Repeated token with dash",
        "prompt": "Match a word token, dash, and the identical token.",
        "solution": "(\\w+)-\\1",
        "requiredMatches": [
          "abc-abc",
          "x-x",
          "user_1-user_1",
          "42-42"
        ],
        "mustNotMatch": [
          "abc-def",
          "x-y",
          "a-a-a"
        ],
        "hint": "Build the pattern from the lesson concepts.",
        "explanation": "This solution applies the current lesson concept directly.",
        "matchMode": "full"
      }
    ],
    "advancedNote": null
  },
  {
    "id": "L13",
    "number": 13,
    "title": "Word Boundaries",
    "subtitle": "Match whole words without consuming boundary characters.",
    "overview": "\\b asserts a transition between word and non-word characters. It is ideal for finding a word without matching it inside a larger identifier.",
    "concepts": [
      "\\b",
      "Whole-word search",
      "Boundary assertions"
    ],
    "exercises": [
      {
        "id": "L13E01",
        "title": "Whole word cat",
        "prompt": "Find cat as a whole word.",
        "solution": "\\bcat\\b",
        "requiredMatches": [
          "cat",
          "the cat sleeps",
          "cat!",
          "(cat)"
        ],
        "mustNotMatch": [
          "copycat",
          "catapult",
          "bobcat"
        ],
        "hint": "Use boundaries on both sides.",
        "explanation": "\\b prevents matching inside a larger word.",
        "matchMode": "contains"
      },
      {
        "id": "L13E02",
        "title": "Whole number 42",
        "prompt": "Find 42 as a standalone numeric token.",
        "solution": "\\b42\\b",
        "requiredMatches": [
          "42",
          "value 42",
          "(42)",
          "42!"
        ],
        "mustNotMatch": [
          "142",
          "420",
          "x42y"
        ],
        "hint": "Digits count as word characters.",
        "explanation": "Boundaries isolate the numeric token.",
        "matchMode": "contains"
      },
      {
        "id": "L13E03",
        "title": "Whole TODO",
        "prompt": "Find TODO as its own word.",
        "solution": "\\bTODO\\b",
        "requiredMatches": [
          "TODO",
          "// TODO fix",
          "[TODO]",
          "TODO:"
        ],
        "mustNotMatch": [
          "TODOS",
          "myTODO",
          "todo"
        ],
        "hint": "Use word boundaries around the literal.",
        "explanation": "This ignores TODO when it is embedded in a larger word.",
        "matchMode": "contains"
      },
      {
        "id": "L13E04",
        "title": "Word beginning re",
        "prompt": "Find whole lowercase words that begin with re.",
        "solution": "\\bre[a-z]*\\b",
        "requiredMatches": [
          "regex",
          "redo",
          "re",
          "return"
        ],
        "mustNotMatch": [
          "pretest",
          "Regex",
          "xre"
        ],
        "hint": "Anchor the beginning of the word with \\b.",
        "explanation": "The trailing boundary closes the word.",
        "matchMode": "contains"
      },
      {
        "id": "L13E05",
        "title": "Three-letter word",
        "prompt": "Find a standalone three-letter lowercase word.",
        "solution": "\\b[a-z]{3}\\b",
        "requiredMatches": [
          "the",
          "a cat sat",
          "run!",
          "(dev)"
        ],
        "mustNotMatch": [
          "four",
          "ab",
          "xabcx"
        ],
        "hint": "Use boundaries around a counted class.",
        "explanation": "Boundaries keep the three letters from being part of a longer word.",
        "matchMode": "contains"
      }
    ],
    "advancedNote": null
  },
  {
    "id": "L14",
    "number": 14,
    "title": "Optional Structure",
    "subtitle": "Build patterns with optional groups and pieces.",
    "overview": "The ? quantifier can make a whole group optional. This is useful for inputs with optional prefixes, suffixes, separators, or formatting.",
    "concepts": [
      "Optional groups",
      "Optional separators",
      "Flexible forms"
    ],
    "exercises": [
      {
        "id": "L14E01",
        "title": "Optional www",
        "prompt": "Match example.com with an optional www. prefix.",
        "solution": "(?:www\\.)?example\\.com",
        "requiredMatches": [
          "example.com",
          "www.example.com",
          "example.com",
          "www.example.com"
        ],
        "mustNotMatch": [
          "ww.example.com",
          "wwwexample.com",
          "example.org"
        ],
        "hint": "Build the pattern from the lesson concepts.",
        "explanation": "This solution applies the current lesson concept directly.",
        "matchMode": "full"
      },
      {
        "id": "L14E02",
        "title": "Optional sign",
        "prompt": "Match integers with optional + or -.",
        "solution": "[+-]?\\d+",
        "requiredMatches": [
          "42",
          "-7",
          "+9",
          "0"
        ],
        "mustNotMatch": [
          "++1",
          "--1",
          "4.2"
        ],
        "hint": "Build the pattern from the lesson concepts.",
        "explanation": "This solution applies the current lesson concept directly.",
        "matchMode": "full"
      },
      {
        "id": "L14E03",
        "title": "Optional plural",
        "prompt": "Match file or files.",
        "solution": "files?",
        "requiredMatches": [
          "file",
          "files",
          "file",
          "files"
        ],
        "mustNotMatch": [
          "filess",
          "File",
          "filer"
        ],
        "hint": "Build the pattern from the lesson concepts.",
        "explanation": "This solution applies the current lesson concept directly.",
        "matchMode": "full"
      },
      {
        "id": "L14E04",
        "title": "Optional separator",
        "prompt": "Match 123456 or 123-456.",
        "solution": "123-?456",
        "requiredMatches": [
          "123456",
          "123-456",
          "123456",
          "123-456"
        ],
        "mustNotMatch": [
          "123--456",
          "123 456",
          "12345"
        ],
        "hint": "Build the pattern from the lesson concepts.",
        "explanation": "This solution applies the current lesson concept directly.",
        "matchMode": "full"
      },
      {
        "id": "L14E05",
        "title": "Optional middle initial",
        "prompt": "Match “First Last” or “First M Last” with capitalized ASCII names.",
        "solution": "[A-Z][a-z]+(?: [A-Z])? [A-Z][a-z]+",
        "requiredMatches": [
          "Ada Lovelace",
          "John Q Public",
          "Grace Hopper",
          "Alan M Turing"
        ],
        "mustNotMatch": [
          "ada Lovelace",
          "John QQ Public",
          "John  Public"
        ],
        "hint": "Build the pattern from the lesson concepts.",
        "explanation": "This solution applies the current lesson concept directly.",
        "matchMode": "full"
      }
    ],
    "advancedNote": null
  },
  {
    "id": "L15",
    "number": 15,
    "title": "Greedy vs Lazy",
    "subtitle": "Control how much repeated patterns consume.",
    "overview": "Quantifiers are greedy by default. Adding ? makes many quantifiers lazy, causing them to consume as little as needed for the surrounding pattern to succeed.",
    "concepts": [
      "Greedy .*",
      "Lazy .*?",
      "Delimiters and minimal matches"
    ],
    "exercises": [
      {
        "id": "L15E01",
        "title": "First HTML-like tag",
        "prompt": "Find the shortest <...> token at the start of the text.",
        "solution": "<.*?>",
        "requiredMatches": [
          "<b>bold</b>",
          "<a><b>",
          "<tag attr=\"x\">text",
          "<>"
        ],
        "mustNotMatch": [
          "no tag",
          "<unclosed"
        ],
        "hint": "Use a lazy star between angle brackets.",
        "explanation": ".*? stops at the earliest closing >.",
        "matchMode": "contains"
      },
      {
        "id": "L15E02",
        "title": "First quoted chunk",
        "prompt": "Find the shortest double-quoted chunk.",
        "solution": "\".*?\"",
        "requiredMatches": [
          "say \"hi\" now",
          "\"a\" \"b\"",
          "x \"test\" y",
          "\"\""
        ],
        "mustNotMatch": [
          "no quotes",
          "\"open"
        ],
        "hint": "A lazy quantifier avoids spanning multiple quoted chunks.",
        "explanation": "The lazy star prefers the nearest closing quote.",
        "matchMode": "contains"
      },
      {
        "id": "L15E03",
        "title": "Bracket payload",
        "prompt": "Match a single bracketed payload without crossing the first ].",
        "solution": "\\[.*?\\]",
        "requiredMatches": [
          "[a]",
          "[abc] tail",
          "x [one] [two]",
          "[]"
        ],
        "mustNotMatch": [
          "[open",
          "none"
        ],
        "hint": "Use lazy repetition between escaped brackets.",
        "explanation": "This finds the first complete bracketed segment.",
        "matchMode": "contains"
      },
      {
        "id": "L15E04",
        "title": "Greedy full line",
        "prompt": "Match a whole line beginning START and ending END, allowing anything between.",
        "solution": "START.*END",
        "requiredMatches": [
          "STARTEND",
          "START x END",
          "START one END two END",
          "START 123 END"
        ],
        "mustNotMatch": [
          "x START END",
          "START only"
        ],
        "hint": "For a full-string validation, greedy repetition is fine.",
        "explanation": "Anchoring by full-match mode keeps the match bounded by the input.",
        "matchMode": "full"
      },
      {
        "id": "L15E05",
        "title": "Shortest braces",
        "prompt": "Find the shortest {...} segment.",
        "solution": "\\{.*?\\}",
        "requiredMatches": [
          "{x}",
          "a {one} b",
          "{a}{b}",
          "{}"
        ],
        "mustNotMatch": [
          "{open",
          "none"
        ],
        "hint": "Escape braces and use lazy repetition.",
        "explanation": "Lazy repetition prevents consuming through later closing braces.",
        "matchMode": "contains"
      }
    ],
    "advancedNote": null
  },
  {
    "id": "L16",
    "number": 16,
    "title": "Positive Lookaheads",
    "subtitle": "Require future text without consuming it.",
    "overview": "(?=...) asserts that a pattern must follow the current position. Multiple lookaheads can combine independent requirements.",
    "concepts": [
      "(?=...)",
      "Multiple requirements",
      "Password-style validation"
    ],
    "exercises": [
      {
        "id": "L16E01",
        "title": "Contains a digit",
        "prompt": "Match an alphanumeric word that contains at least one digit.",
        "solution": "(?=.*\\d)[A-Za-z0-9]+",
        "requiredMatches": [
          "abc1",
          "9xyz",
          "a1b2",
          "123"
        ],
        "mustNotMatch": [
          "abc",
          "a-b",
          ""
        ],
        "hint": "Use a lookahead from the start of the match.",
        "explanation": "The lookahead requires a digit somewhere while the consuming class validates the whole string.",
        "matchMode": "full"
      },
      {
        "id": "L16E02",
        "title": "Starts with letters, contains underscore",
        "prompt": "Match word characters that begin with a letter and contain an underscore.",
        "solution": "(?=.*_)[A-Za-z]\\w*",
        "requiredMatches": [
          "a_b",
          "User_1",
          "x_",
          "abc_def_2"
        ],
        "mustNotMatch": [
          "abc",
          "_abc",
          "a-b"
        ],
        "hint": "Build the pattern from the lesson concepts.",
        "explanation": "This solution applies the current lesson concept directly.",
        "matchMode": "full"
      },
      {
        "id": "L16E03",
        "title": "At least one uppercase",
        "prompt": "Match letters only, requiring at least one uppercase letter.",
        "solution": "(?=.*[A-Z])[A-Za-z]+",
        "requiredMatches": [
          "Regex",
          "ABC",
          "aB",
          "Test"
        ],
        "mustNotMatch": [
          "regex",
          "123",
          "A1"
        ],
        "hint": "Build the pattern from the lesson concepts.",
        "explanation": "This solution applies the current lesson concept directly.",
        "matchMode": "full"
      },
      {
        "id": "L16E04",
        "title": "Contains cat somewhere",
        "prompt": "Validate lowercase letters only and require cat as a substring.",
        "solution": "(?=.*cat)[a-z]+",
        "requiredMatches": [
          "cat",
          "copycat",
          "catapult",
          "scattercat"
        ],
        "mustNotMatch": [
          "dog",
          "Cat",
          "cat-1"
        ],
        "hint": "Build the pattern from the lesson concepts.",
        "explanation": "This solution applies the current lesson concept directly.",
        "matchMode": "full"
      },
      {
        "id": "L16E05",
        "title": "Two independent requirements",
        "prompt": "Match 6–12 word characters containing both a digit and an underscore.",
        "solution": "(?=.*\\d)(?=.*_)\\w{6,12}",
        "requiredMatches": [
          "user_1",
          "a_b2cd",
          "dev_2026",
          "x1_yz9"
        ],
        "mustNotMatch": [
          "abcdef",
          "user_",
          "123456",
          "a-1_b"
        ],
        "hint": "Build the pattern from the lesson concepts.",
        "explanation": "This solution applies the current lesson concept directly.",
        "matchMode": "full"
      }
    ],
    "advancedNote": null
  },
  {
    "id": "L17",
    "number": 17,
    "title": "Negative Lookaheads",
    "subtitle": "Reject forbidden forms before consuming the rest.",
    "overview": "(?!...) asserts that some pattern must not follow. It is useful for excluding prefixes, reserved words, repeated structures, or unwanted characters.",
    "concepts": [
      "(?!...)",
      "Reserved-word rejection",
      "Constraint composition"
    ],
    "exercises": [
      {
        "id": "L17E01",
        "title": "Not admin",
        "prompt": "Match lowercase words except exactly admin.",
        "solution": "(?!admin$)[a-z]+",
        "requiredMatches": [
          "user",
          "administrator",
          "guest",
          "root"
        ],
        "mustNotMatch": [
          "admin",
          "User",
          "user1"
        ],
        "hint": "Build the pattern from the lesson concepts.",
        "explanation": "This solution applies the current lesson concept directly.",
        "matchMode": "full"
      },
      {
        "id": "L17E02",
        "title": "No leading zero",
        "prompt": "Match a positive integer without a leading zero, except zero itself.",
        "solution": "(?:0|[1-9]\\d*)",
        "requiredMatches": [
          "0",
          "7",
          "42",
          "2026"
        ],
        "mustNotMatch": [
          "00",
          "012",
          "-1"
        ],
        "hint": "Build the pattern from the lesson concepts.",
        "explanation": "This solution applies the current lesson concept directly.",
        "matchMode": "full"
      },
      {
        "id": "L17E03",
        "title": "No double underscore",
        "prompt": "Match word characters but reject any string containing __.",
        "solution": "(?!.*__)\\w+",
        "requiredMatches": [
          "abc",
          "a_b",
          "user_1",
          "_x_"
        ],
        "mustNotMatch": [
          "a__b",
          "__",
          "x___y"
        ],
        "hint": "Build the pattern from the lesson concepts.",
        "explanation": "This solution applies the current lesson concept directly.",
        "matchMode": "full"
      },
      {
        "id": "L17E04",
        "title": "Not .tmp",
        "prompt": "Match a filename-like token that does not end in .tmp.",
        "solution": "(?!.*\\.tmp$)[A-Za-z0-9_.-]+",
        "requiredMatches": [
          "file.txt",
          "archive.tar",
          "tmpfile",
          "a.tmpx"
        ],
        "mustNotMatch": [
          "file.tmp",
          "x.tmp",
          "bad name"
        ],
        "hint": "Build the pattern from the lesson concepts.",
        "explanation": "This solution applies the current lesson concept directly.",
        "matchMode": "full"
      },
      {
        "id": "L17E05",
        "title": "No digits",
        "prompt": "Match word characters while rejecting any digit.",
        "solution": "(?!.*\\d)\\w+",
        "requiredMatches": [
          "abc",
          "hello_world",
          "ABC",
          "_name"
        ],
        "mustNotMatch": [
          "abc1",
          "42",
          "x_9"
        ],
        "hint": "Build the pattern from the lesson concepts.",
        "explanation": "This solution applies the current lesson concept directly.",
        "matchMode": "full"
      }
    ],
    "advancedNote": null
  },
  {
    "id": "L18",
    "number": 18,
    "title": "Lookbehinds",
    "subtitle": "Assert fixed-width text immediately before a match.",
    "overview": "(?<=...) and (?<!...) inspect text behind the current position without consuming it. ICU requires lookbehind alternatives to have bounded length, so these exercises use fixed-width conditions.",
    "concepts": [
      "(?<=...)",
      "(?<!...)",
      "Fixed-width lookbehind"
    ],
    "exercises": [
      {
        "id": "L18E01",
        "title": "Dollar amount digits",
        "prompt": "Find digits immediately preceded by $.",
        "solution": "(?<=\\$)\\d+",
        "requiredMatches": [
          "$42",
          "$7 total",
          "cost $2026",
          "$0005"
        ],
        "mustNotMatch": [
          "42",
          "USD 5",
          "€9"
        ],
        "hint": "Use a positive lookbehind for the dollar sign.",
        "explanation": "The $ is required but is not part of the matched text.",
        "matchMode": "contains"
      },
      {
        "id": "L18E02",
        "title": "After ID:",
        "prompt": "Find digits immediately after the literal prefix ID:.",
        "solution": "(?<=ID:)\\d+",
        "requiredMatches": [
          "ID:42",
          "x ID:7",
          "ID:2026 end",
          "ID:0"
        ],
        "mustNotMatch": [
          "ID: 42",
          "id:7",
          "42"
        ],
        "hint": "The lookbehind is the fixed text ID:.",
        "explanation": "Only the digits are consumed.",
        "matchMode": "contains"
      },
      {
        "id": "L18E03",
        "title": "Not preceded by @",
        "prompt": "Find the word user only when it is not immediately preceded by @.",
        "solution": "(?<!@)\\buser\\b",
        "requiredMatches": [
          "user",
          "the user",
          "(user)",
          "x user"
        ],
        "mustNotMatch": [
          "@user",
          "x @user",
          "myuser"
        ],
        "hint": "Use a one-character negative lookbehind plus word boundaries.",
        "explanation": "The assertion rejects social-handle style @user.",
        "matchMode": "contains"
      },
      {
        "id": "L18E04",
        "title": "After hex prefix",
        "prompt": "Find exactly two hex digits immediately after 0x.",
        "solution": "(?<=0x)[0-9A-Fa-f]{2}(?![0-9A-Fa-f])",
        "requiredMatches": [
          "0xAF",
          "value 0x00",
          "0xc3",
          "0x9B!"
        ],
        "mustNotMatch": [
          "AF",
          "0xG1",
          "0xABC"
        ],
        "hint": "Look behind for the fixed two-character prefix.",
        "explanation": "The match itself is only the two hex digits.",
        "matchMode": "contains"
      },
      {
        "id": "L18E05",
        "title": "Not after minus",
        "prompt": "Find standalone digits not immediately preceded by a minus sign.",
        "solution": "(?<!-)\\b\\d+\\b",
        "requiredMatches": [
          "42",
          "x 7",
          "(2026)",
          "+9"
        ],
        "mustNotMatch": [
          "-42",
          "x -7",
          "-0"
        ],
        "hint": "Reject a minus immediately before the numeric token.",
        "explanation": "This is a simple negative lookbehind.",
        "matchMode": "contains"
      }
    ],
    "advancedNote": null
  },
  {
    "id": "L19",
    "number": 19,
    "title": "Atomic Groups",
    "subtitle": "Prevent backtracking inside a chosen group.",
    "overview": "(?>...) is an atomic group. Once it matches, the engine will not revisit internal choices. Atomic groups can improve performance and change which alternatives are viable.",
    "concepts": [
      "(?>...)",
      "Backtracking control",
      "Alternative ordering"
    ],
    "exercises": [
      {
        "id": "L19E01",
        "title": "Atomic prefix",
        "prompt": "Match ab followed by c using an atomic group.",
        "solution": "(?>ab)c",
        "requiredMatches": [
          "abc",
          "abc",
          "abc",
          "abc"
        ],
        "mustNotMatch": [
          "ab",
          "abbc",
          "xbc"
        ],
        "hint": "Build the pattern from the lesson concepts.",
        "explanation": "This solution applies the current lesson concept directly.",
        "matchMode": "full"
      },
      {
        "id": "L19E02",
        "title": "Atomic alternation success",
        "prompt": "Match foo or fo followed by X, with the longer choice first.",
        "solution": "(?>foo|fo)X",
        "requiredMatches": [
          "fooX",
          "foX",
          "fooX",
          "foX"
        ],
        "mustNotMatch": [
          "foooX",
          "fX",
          "fooY"
        ],
        "hint": "Build the pattern from the lesson concepts.",
        "explanation": "This solution applies the current lesson concept directly.",
        "matchMode": "full"
      },
      {
        "id": "L19E03",
        "title": "Atomic digit chunk",
        "prompt": "Match 2–4 digits atomically, followed by Z.",
        "solution": "(?>\\d{2,4})Z",
        "requiredMatches": [
          "12Z",
          "123Z",
          "1234Z",
          "99Z"
        ],
        "mustNotMatch": [
          "1Z",
          "12345Z",
          "12A"
        ],
        "hint": "Build the pattern from the lesson concepts.",
        "explanation": "This solution applies the current lesson concept directly.",
        "matchMode": "full"
      },
      {
        "id": "L19E04",
        "title": "Atomic word prefix",
        "prompt": "Match one or more lowercase letters atomically, then a colon.",
        "solution": "(?>[a-z]+):",
        "requiredMatches": [
          "key:",
          "a:",
          "hello:",
          "regex:"
        ],
        "mustNotMatch": [
          "Key:",
          "key",
          "key::"
        ],
        "hint": "Build the pattern from the lesson concepts.",
        "explanation": "This solution applies the current lesson concept directly.",
        "matchMode": "full"
      },
      {
        "id": "L19E05",
        "title": "Atomic grouped token",
        "prompt": "Match one or more atomic ab/cd pairs followed by !.",
        "solution": "(?>(?:ab|cd)+)!",
        "requiredMatches": [
          "ab!",
          "cd!",
          "abcd!",
          "cdababcd!"
        ],
        "mustNotMatch": [
          "a!",
          "ab?",
          "abc!"
        ],
        "hint": "Build the pattern from the lesson concepts.",
        "explanation": "This solution applies the current lesson concept directly.",
        "matchMode": "full"
      }
    ],
    "advancedNote": null
  },
  {
    "id": "L20",
    "number": 20,
    "title": "Possessive Quantifiers",
    "subtitle": "Repeat without giving characters back to the engine.",
    "overview": "Possessive quantifiers such as *+, ++, and {m,n}+ refuse to backtrack. They can prevent expensive retry behavior when you know the repeated token should never shrink.",
    "concepts": [
      "*+",
      "++",
      "{m,n}+",
      "Backtracking prevention"
    ],
    "exercises": [
      {
        "id": "L20E01",
        "title": "Possessive letters",
        "prompt": "Match lowercase letters possessively.",
        "solution": "[a-z]++",
        "requiredMatches": [
          "a",
          "abc",
          "regex",
          "swift"
        ],
        "mustNotMatch": [
          "ABC",
          "a1",
          ""
        ],
        "hint": "Build the pattern from the lesson concepts.",
        "explanation": "This solution applies the current lesson concept directly.",
        "matchMode": "full"
      },
      {
        "id": "L20E02",
        "title": "Possessive digits",
        "prompt": "Match one or more digits possessively.",
        "solution": "\\d++",
        "requiredMatches": [
          "1",
          "42",
          "2026",
          "000"
        ],
        "mustNotMatch": [
          "1a",
          "a1",
          ""
        ],
        "hint": "Build the pattern from the lesson concepts.",
        "explanation": "This solution applies the current lesson concept directly.",
        "matchMode": "full"
      },
      {
        "id": "L20E03",
        "title": "Possessive bounded",
        "prompt": "Match exactly 2–4 word characters possessively.",
        "solution": "\\w{2,4}+",
        "requiredMatches": [
          "ab",
          "abc",
          "a_1",
          "Z9"
        ],
        "mustNotMatch": [
          "a",
          "abcde",
          "a-b"
        ],
        "hint": "Build the pattern from the lesson concepts.",
        "explanation": "This solution applies the current lesson concept directly.",
        "matchMode": "full"
      },
      {
        "id": "L20E04",
        "title": "Possessive whitespace",
        "prompt": "Match one or more whitespace characters possessively.",
        "solution": "\\s++",
        "requiredMatches": [
          " ",
          "   ",
          "\t",
          "\n"
        ],
        "mustNotMatch": [
          "x",
          " x",
          ""
        ],
        "hint": "Build the pattern from the lesson concepts.",
        "explanation": "This solution applies the current lesson concept directly.",
        "matchMode": "full"
      },
      {
        "id": "L20E05",
        "title": "Safe token then comma",
        "prompt": "Match a non-comma token possessively followed by a comma.",
        "solution": "[^,]++,",
        "requiredMatches": [
          "a,",
          "hello,",
          "123,",
          "x y,"
        ],
        "mustNotMatch": [
          ",",
          "a",
          "a,b"
        ],
        "hint": "Build the pattern from the lesson concepts.",
        "explanation": "This solution applies the current lesson concept directly.",
        "matchMode": "full"
      }
    ],
    "advancedNote": null
  },
  {
    "id": "L21",
    "number": 21,
    "title": "Inline Flags",
    "subtitle": "Change matching behavior from inside the pattern.",
    "overview": "Inline flags such as (?i), (?m), and (?s) can enable case-insensitive, multiline, or dotall behavior. Scoped flag groups can limit the effect to one section.",
    "concepts": [
      "(?i) case-insensitive",
      "Scoped flags",
      "Flag composition"
    ],
    "exercises": [
      {
        "id": "L21E01",
        "title": "Case-insensitive yes",
        "prompt": "Match yes regardless of capitalization.",
        "solution": "(?i)yes",
        "requiredMatches": [
          "yes",
          "YES",
          "Yes",
          "yEs"
        ],
        "mustNotMatch": [
          "no",
          "yes!",
          "y"
        ],
        "hint": "Build the pattern from the lesson concepts.",
        "explanation": "This solution applies the current lesson concept directly.",
        "matchMode": "full"
      },
      {
        "id": "L21E02",
        "title": "Case-insensitive extension",
        "prompt": "Match .jpg regardless of case.",
        "solution": "(?i)\\.jpg",
        "requiredMatches": [
          ".jpg",
          ".JPG",
          ".Jpg",
          ".jPg"
        ],
        "mustNotMatch": [
          "jpg",
          ".jpeg",
          ".png"
        ],
        "hint": "Build the pattern from the lesson concepts.",
        "explanation": "This solution applies the current lesson concept directly.",
        "matchMode": "full"
      },
      {
        "id": "L21E03",
        "title": "Scoped case-insensitive prefix",
        "prompt": "Match API case-insensitively, then a case-sensitive -v1 suffix.",
        "solution": "(?i:api)-v1",
        "requiredMatches": [
          "api-v1",
          "API-v1",
          "Api-v1",
          "aPi-v1"
        ],
        "mustNotMatch": [
          "API-V1",
          "api-v2",
          "xapi-v1"
        ],
        "hint": "Build the pattern from the lesson concepts.",
        "explanation": "This solution applies the current lesson concept directly.",
        "matchMode": "full"
      },
      {
        "id": "L21E04",
        "title": "Case-insensitive word set",
        "prompt": "Match red, green, or blue regardless of case.",
        "solution": "(?i)(?:red|green|blue)",
        "requiredMatches": [
          "RED",
          "green",
          "Blue",
          "rEd"
        ],
        "mustNotMatch": [
          "yellow",
          "blue1",
          " blue"
        ],
        "hint": "Build the pattern from the lesson concepts.",
        "explanation": "This solution applies the current lesson concept directly.",
        "matchMode": "full"
      },
      {
        "id": "L21E05",
        "title": "Flag with anchors",
        "prompt": "Validate ok, any capitalization, and nothing else.",
        "solution": "(?i)^ok$",
        "requiredMatches": [
          "ok",
          "OK",
          "Ok",
          "oK"
        ],
        "mustNotMatch": [
          "okay",
          " ok",
          "ok!"
        ],
        "hint": "Build the pattern from the lesson concepts.",
        "explanation": "This solution applies the current lesson concept directly.",
        "matchMode": "full"
      }
    ],
    "advancedNote": null
  },
  {
    "id": "L22",
    "number": 22,
    "title": "Unicode Properties",
    "subtitle": "Match categories of Unicode characters.",
    "overview": "Unicode property escapes such as \\p{L} and \\p{N} let patterns work beyond ASCII. This is important for international text and emoji-aware applications.",
    "concepts": [
      "\\p{L}",
      "\\p{N}",
      "Unicode-aware matching"
    ],
    "exercises": [
      {
        "id": "L22E01",
        "title": "Unicode letters",
        "prompt": "Match one or more Unicode letters.",
        "solution": "\\p{L}+",
        "requiredMatches": [
          "hello",
          "café",
          "日本語",
          "Привет"
        ],
        "mustNotMatch": [
          "123",
          "hello1",
          "!"
        ],
        "hint": "Build the pattern from the lesson concepts.",
        "explanation": "This solution applies the current lesson concept directly.",
        "matchMode": "full"
      },
      {
        "id": "L22E02",
        "title": "Unicode numbers",
        "prompt": "Match one or more Unicode numeric characters.",
        "solution": "\\p{N}+",
        "requiredMatches": [
          "123",
          "٤٢",
          "１２３",
          "७"
        ],
        "mustNotMatch": [
          "abc",
          "1a",
          "!"
        ],
        "hint": "Build the pattern from the lesson concepts.",
        "explanation": "This solution applies the current lesson concept directly.",
        "matchMode": "full"
      },
      {
        "id": "L22E03",
        "title": "Letter then number",
        "prompt": "Match Unicode letters followed by Unicode numbers.",
        "solution": "\\p{L}+\\p{N}+",
        "requiredMatches": [
          "abc123",
          "é42",
          "日本1",
          "Ж9"
        ],
        "mustNotMatch": [
          "123abc",
          "abc",
          "a-1"
        ],
        "hint": "Build the pattern from the lesson concepts.",
        "explanation": "This solution applies the current lesson concept directly.",
        "matchMode": "full"
      },
      {
        "id": "L22E04",
        "title": "Uppercase Unicode",
        "prompt": "Match one or more Unicode uppercase letters.",
        "solution": "\\p{Lu}+",
        "requiredMatches": [
          "ABC",
          "É",
          "Ж",
          "ÖZ"
        ],
        "mustNotMatch": [
          "abc",
          "Äb",
          "123"
        ],
        "hint": "Build the pattern from the lesson concepts.",
        "explanation": "This solution applies the current lesson concept directly.",
        "matchMode": "full"
      },
      {
        "id": "L22E05",
        "title": "Non-letter run",
        "prompt": "Match one or more characters that are not Unicode letters.",
        "solution": "\\P{L}+",
        "requiredMatches": [
          "123",
          "!?",
          "—",
          "42_"
        ],
        "mustNotMatch": [
          "abc",
          "1a",
          "é"
        ],
        "hint": "Build the pattern from the lesson concepts.",
        "explanation": "This solution applies the current lesson concept directly.",
        "matchMode": "full"
      }
    ],
    "advancedNote": null
  },
  {
    "id": "L23",
    "number": 23,
    "title": "Multiline & Dotall",
    "subtitle": "Use flags to change how anchors and dot treat line breaks.",
    "overview": "Multiline mode changes ^ and $ to work per line. Dotall mode allows . to match line separators. Inline flags make these behaviors testable directly in a pattern.",
    "concepts": [
      "(?m)",
      "(?s)",
      "Line-oriented matching"
    ],
    "exercises": [
      {
        "id": "L23E01",
        "title": "Find ERROR line",
        "prompt": "Find a whole line beginning ERROR inside multiline text.",
        "solution": "(?m)^ERROR.*$",
        "requiredMatches": [
          "INFO ok\nERROR failed\nDONE",
          "ERROR one\nINFO two",
          "x\nERROR 42",
          "ERROR"
        ],
        "mustNotMatch": [
          "INFO\nWARN",
          "xERROR y"
        ],
        "hint": "Enable multiline so ^ and $ apply to each line.",
        "explanation": "(?m) makes anchors line-aware.",
        "matchMode": "contains"
      },
      {
        "id": "L23E02",
        "title": "Dot across newline",
        "prompt": "Match BEGIN through END even when text spans lines.",
        "solution": "(?s)BEGIN.*END",
        "requiredMatches": [
          "BEGIN\nEND",
          "BEGIN a\nb END",
          "BEGINEND",
          "BEGIN\n1\n2\nEND"
        ],
        "mustNotMatch": [
          "BEGIN only",
          "x BEGIN END y"
        ],
        "hint": "Dotall lets . consume line separators.",
        "explanation": "(?s) changes dot behavior.",
        "matchMode": "full"
      },
      {
        "id": "L23E03",
        "title": "Multiline TODO",
        "prompt": "Find a line that consists exactly of TODO.",
        "solution": "(?m)^TODO$",
        "requiredMatches": [
          "x\nTODO\ny",
          "TODO\nx",
          "x\nTODO",
          "TODO"
        ],
        "mustNotMatch": [
          "xTODO",
          "TODO!",
          "todo"
        ],
        "hint": "Use multiline anchors around the literal.",
        "explanation": "The match can occur on any line.",
        "matchMode": "contains"
      },
      {
        "id": "L23E04",
        "title": "Dotall minimal block",
        "prompt": "Find the shortest <script>...</script> block across lines.",
        "solution": "(?s)<script>.*?</script>",
        "requiredMatches": [
          "<script>\nx\n</script>",
          "a<script>1</script>b",
          "<script></script>",
          "<script>a\n</script><script>b</script>"
        ],
        "mustNotMatch": [
          "<script>open",
          "none"
        ],
        "hint": "Combine dotall and lazy repetition.",
        "explanation": "The dot can cross lines and *? stops at the nearest closing tag.",
        "matchMode": "contains"
      },
      {
        "id": "L23E05",
        "title": "Multiline numbered line",
        "prompt": "Find any line containing only three digits.",
        "solution": "(?m)^\\d{3}$",
        "requiredMatches": [
          "a\n123\nb",
          "999\ntext",
          "x\n000",
          "123"
        ],
        "mustNotMatch": [
          "12",
          "x123",
          "1234"
        ],
        "hint": "Multiline anchors isolate each line.",
        "explanation": "The pattern can match a three-digit line inside a larger string.",
        "matchMode": "contains"
      }
    ],
    "advancedNote": null
  },
  {
    "id": "L24",
    "number": 24,
    "title": "Performance & Backtracking",
    "subtitle": "Write patterns that stay predictable on hostile input.",
    "overview": "Nested ambiguous quantifiers can cause catastrophic backtracking. Prefer specific character classes, atomic groups, possessive quantifiers, and clear delimiters when possible.",
    "concepts": [
      "Catastrophic backtracking",
      "Specific delimiters",
      "Atomic/possessive rewrites",
      "Performance thinking"
    ],
    "exercises": [
      {
        "id": "L24E01",
        "title": "Delimited field",
        "prompt": "Match a non-comma field followed by a comma without using .* .",
        "solution": "[^,]+,",
        "requiredMatches": [
          "abc,",
          "123,",
          "hello world,",
          "x-y,"
        ],
        "mustNotMatch": [
          ",",
          "abc",
          "a,b,"
        ],
        "hint": "Use a class that cannot cross the delimiter.",
        "explanation": "A delimiter-excluding class is more precise than a wildcard.",
        "matchMode": "full"
      },
      {
        "id": "L24E02",
        "title": "Safe quoted string",
        "prompt": "Match a simple double-quoted string with no embedded quotes.",
        "solution": "\"[^\"]*\"",
        "requiredMatches": [
          "\"hello\"",
          "\"\"",
          "\"a b\"",
          "\"123\""
        ],
        "mustNotMatch": [
          "\"open",
          "\"a\"b\"",
          "plain"
        ],
        "hint": "Exclude the delimiter inside the repeated class.",
        "explanation": "This avoids the ambiguity of a greedy wildcard.",
        "matchMode": "full"
      },
      {
        "id": "L24E03",
        "title": "Atomic CSV token",
        "prompt": "Match a non-comma token atomically followed by comma.",
        "solution": "(?>[^,]+),",
        "requiredMatches": [
          "a,",
          "hello,",
          "123,",
          "x y,"
        ],
        "mustNotMatch": [
          ",",
          "a",
          "a,b,"
        ],
        "hint": "Make the token atomic once chosen.",
        "explanation": "Atomic grouping prevents retrying shorter prefixes.",
        "matchMode": "full"
      },
      {
        "id": "L24E04",
        "title": "Possessive identifier",
        "prompt": "Match a word token possessively.",
        "solution": "\\w++",
        "requiredMatches": [
          "abc",
          "user_1",
          "123",
          "A_B"
        ],
        "mustNotMatch": [
          "a-b",
          "two words",
          ""
        ],
        "hint": "Build the pattern from the lesson concepts.",
        "explanation": "This solution applies the current lesson concept directly.",
        "matchMode": "full"
      },
      {
        "id": "L24E05",
        "title": "Linear a-run",
        "prompt": "Match one or more a characters followed by ! using a possessive run.",
        "solution": "a++!",
        "requiredMatches": [
          "a!",
          "aa!",
          "aaaa!",
          "aaaaaaaaaa!"
        ],
        "mustNotMatch": [
          "a",
          "aa?",
          "ba!"
        ],
        "hint": "Build the pattern from the lesson concepts.",
        "explanation": "This solution applies the current lesson concept directly.",
        "matchMode": "full"
      }
    ],
    "advancedNote": null
  },
  {
    "id": "L25",
    "number": 25,
    "title": "Nested Structures & Recursion",
    "subtitle": "Understand recursive regexes and portable bounded alternatives.",
    "overview": "PCRE2 and some other engines support subroutine recursion, which can match arbitrarily nested structures. Apple’s native ICU regex engine does not expose PCRE-style (?R) recursion, so this lesson teaches the idea and then has you build bounded-depth equivalents that run natively on iOS.",
    "concepts": [
      "Recursive subpatterns in PCRE",
      "Balanced delimiters",
      "Bounded-depth ICU alternatives",
      "Regex flavor portability"
    ],
    "exercises": [
      {
        "id": "L25E01",
        "title": "One-level parentheses",
        "prompt": "Match a parenthesized value containing no nested parentheses.",
        "solution": "\\([^()]*\\)",
        "requiredMatches": [
          "()",
          "(abc)",
          "(1 + 2)",
          "(a_b-7)"
        ],
        "mustNotMatch": [
          "abc",
          "(a(b)c)",
          "(open"
        ],
        "hint": "Build the pattern from the lesson concepts.",
        "explanation": "This solution applies the current lesson concept directly.",
        "matchMode": "full"
      },
      {
        "id": "L25E02",
        "title": "Up to two levels",
        "prompt": "Match balanced parentheses nested up to two levels deep.",
        "solution": "\\((?:[^()]|\\([^()]*\\))*\\)",
        "requiredMatches": [
          "(abc)",
          "((x))",
          "(a(b)c)",
          "(()())"
        ],
        "mustNotMatch": [
          "(a(b(c))d)",
          "(open",
          "a(b)c"
        ],
        "hint": "Build the pattern from the lesson concepts.",
        "explanation": "This solution applies the current lesson concept directly.",
        "matchMode": "full"
      },
      {
        "id": "L25E03",
        "title": "Square brackets up to two levels",
        "prompt": "Match balanced square brackets nested up to two levels.",
        "solution": "\\[(?:[^\\[\\]]|\\[[^\\[\\]]*\\])*\\]",
        "requiredMatches": [
          "[]",
          "[abc]",
          "[[x]]",
          "[a[b]c]"
        ],
        "mustNotMatch": [
          "[a[b[c]]d]",
          "[open",
          "a[b]c"
        ],
        "hint": "Build the pattern from the lesson concepts.",
        "explanation": "This solution applies the current lesson concept directly.",
        "matchMode": "full"
      },
      {
        "id": "L25E04",
        "title": "Mixed flat delimiters",
        "prompt": "Match a parenthesized value that may contain non-nested square-bracket chunks.",
        "solution": "\\((?:[^()\\[\\]]|\\[[^\\[\\]]*\\])*\\)",
        "requiredMatches": [
          "(abc)",
          "(a[b]c)",
          "([x])",
          "(a[]b)"
        ],
        "mustNotMatch": [
          "(a[b[c]]d)",
          "a[b]",
          "(open"
        ],
        "hint": "Build the pattern from the lesson concepts.",
        "explanation": "This solution applies the current lesson concept directly.",
        "matchMode": "full"
      },
      {
        "id": "L25E05",
        "title": "Three-level parentheses",
        "prompt": "Match balanced parentheses nested up to three levels deep.",
        "solution": "\\((?:[^()]|\\((?:[^()]|\\([^()]*\\))*\\))*\\)",
        "requiredMatches": [
          "(x)",
          "((x))",
          "(((x)))",
          "(a(b(c)d)e)"
        ],
        "mustNotMatch": [
          "((((x))))",
          "(a(b(c(d))))",
          "(open"
        ],
        "hint": "Build the pattern from the lesson concepts.",
        "explanation": "This solution applies the current lesson concept directly.",
        "matchMode": "full"
      }
    ],
    "advancedNote": "PCRE2 recursion reference: (?<paren>\\((?:[^()]|(?&paren))*\\)). In a PCRE2-backed build this can handle arbitrary nesting; the bundled iOS-native evaluator uses ICU-compatible bounded patterns for portability."
  }
]
"""#
}
