# OpenSwiftUI Copilot Instructions

This file contains coding guidelines and conventions for AI assistants working on the OpenSwiftUI project.

## Quick Reference

### Key Principles
- Use `swift-testing` framework with `#expect` macro (not XCTest)
- Use `package` access level for cross-module APIs
- Follow SwiftUI API compatibility patterns
- Trim trailing whitespaces automatically
- Use 4-space indentation consistently

## Testing Guidelines

### Testing Framework

- Use the `swift-testing` framework with the `#expect` macro for all test assertions
- Import testing framework with: `import Testing`
- Do NOT use XCTest framework unless specifically required for compatibility

### Test Structure

```swift
import Testing

struct DemoTests {
    @Test
    func functionality() {
        let value = SomeType()
        
        #expect(value.property == expectedValue)
        #expect(value.method() == expectedResult)
    }

    @Test
    func errorConditions() {
        #expect(throws: SomeError.self) {
            try riskyOperation()
        }
    }
}
```

### Test Conventions

- **Do NOT write any comments in test case body** - keep test code clean and self-explanatory
- Use descriptive test function names that clearly indicate what is being tested
- Group related tests using `// MARK: -` sections
- Use `#expect` for all assertions instead of XCTest assertions
- Prefer multiple focused tests over one large test
- Do not add test prefix to test function names (e.g., `testFunctionality` should be `functionality`)
- Use `@Test` attribute for test functions

## Code Organization

### File Structure
- Use `// MARK: -` to separate different topics and sections within files
- Organize code logically with clear separation of concerns
- Place imports at the top, followed by type definitions, then implementations

### Example MARK Usage
```swift
// MARK: - A

...

// MARK: - B

...

// MARK: - C

...
```

## Swift Coding Style

### Access Control Hierarchy

1. `public` - External API surface
2. `package` - Cross-module internal APIs
3. `internal` - Module-internal APIs (default)
4. `private` - Implementation details

### Naming Conventions

- Follow Swift API Design Guidelines
- Use descriptive names that clearly indicate purpose
- Prefer full words over abbreviations
- Use camelCase for variables, functions, and properties
- Use PascalCase for types, protocols, and cases
- Prefix internal types with `_` when they mirror SwiftUI internals

### Code Formatting Rules

- **Automatically trim trailing whitespaces including whitespace-only lines**
- Use consistent indentation (4 spaces, not tabs)
- Place opening braces on the same line as the declaration
- Use proper spacing around operators and after commas
- Align code vertically when it improves readability
- Maximum line length: 120 characters (soft limit)

### Type Definitions

```swift
struct SomeType {
    let property: String

    private let internalProperty: Int
    
    func method() -> String {
        // Implementation
    }
}
```

## Architecture Patterns

### SwiftUI Compatibility
- Maintain API compatibility with SwiftUI when implementing equivalent functionality
- Use similar naming conventions and parameter patterns as SwiftUI
- Implement protocols and extensions that mirror SwiftUI's design

### Module Organization
- Keep related functionality in appropriate modules
- Use clear module boundaries
- Avoid circular dependencies between modules

### Error Handling
- Use Swift's error handling mechanisms (`throws`, `Result`, etc.)
- Provide meaningful error messages
- Handle errors gracefully at appropriate levels

## Documentation

### Code Comments
- Write clear, concise comments for complex logic
- Use documentation comments (`///`) for APIs documentation
- Avoid obvious comments that don't add value
- Keep comments up-to-date with code changes

### API Documentation
```swift
/// A brief description of what this function does.
/// 
/// - Parameter value: Description of the parameter
/// - Returns: Description of the return value
/// - Throws: Description of potential errors
func someFunction(value: String) throws -> Int {
    // Implementation
}
```

## Performance Considerations

- Prefer value types (structs) over reference types (classes) when appropriate
- Use lazy initialization for expensive computations
- Consider memory management and avoid retain cycles
- Optimize for common use cases while maintaining flexibility

## Dependencies and Imports

- Minimize external dependencies
- Use conditional compilation for platform-specific code
- Import only what is needed (avoid importing entire modules when specific types suffice)
- Organize imports alphabetically within groups (system frameworks first, then project modules)

## Version Control

- Make atomic commits with clear, descriptive messages
- Keep changes focused and reviewable
- Follow the project's branching strategy
- Ensure all tests pass before committing

## Platform Compatibility

- Support multiple Apple platforms (iOS, macOS, watchOS, tvOS, visionOS)
- Use availability annotations when using platform-specific APIs
- Test on supported platform versions
- Use feature detection rather than version checking when possible

---

## Troubleshooting

### Common Issues
- **Build errors**: Check `package` vs `internal` access levels
- **Test failures**: Ensure using `#expect` not XCTest assertions
- **SwiftUI compatibility**: Verify API signatures match exactly

Remember: This project aims to provide a compatible alternative to SwiftUI, so maintain consistency with SwiftUI's patterns and conventions while following these OpenSwiftUI-specific guidelines.