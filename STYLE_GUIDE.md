# RegexDojo Swift Style Guide

RegexDojo follows conventional Swift naming and API-design practices with a readability-focused K&R/1TBS brace style.

## Indentation and braces

- Use **4 spaces** for each indentation level. Do not use tabs for indentation.
- Keep an opening brace on the same line as its declaration, control-flow statement, or closure signature.
- Start executable block contents on the following line and indent them one level.
- Keep the closing brace on its own line.
- Do not use inline executable bodies such as `if condition { return false }`.
- For standard Swift trailing closures, the closure parameters may remain with the opening brace (`map { value in`), while the closure body begins on the next indented line.

Preferred:

```swift
func validate(_ value: String) -> Bool {
    if value.isEmpty {
        return false
    }

    return true
}

let names = values.map { value in
    value.name
}
```

Avoid:

```swift
func validate(_ value: String) -> Bool
{
    if value.isEmpty { return false }
    return true
}
```

For multiline conditions, keep the opening brace with the final condition:

```swift
if let data = storedData,
    let state = try? decoder.decode(State.self, from: data) {
    apply(state)
}
```

## Documentation

Use Swift DocC-compatible `///` comments for declarations whose contract, side effects, persistence behavior, algorithm, platform requirements, or non-obvious intent would benefit from explanation.

- Start with a concise summary sentence.
- Use `- Parameter:`, `- Parameters:`, `- Returns:`, and `- Throws:` when they add useful contract information.
- Document important invariants and conflict-resolution rules close to the implementation.
- Prefer descriptive names over comments for trivial variables and obvious view layout code.
- Use ordinary `//` comments for local implementation notes that are not part of an API contract.
- Keep documentation above declaration attributes such as `@MainActor` so DocC associates it with the declaration.

## Source headers

Swift source files should retain the RegexDojo header with:

- a one-line description of the file's responsibility;
- author: **Tyler Hostager**;
- creation date;
- copyright notice.
