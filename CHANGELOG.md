# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.0.0] - 2025-08-04

### Added

- **🎯 Decorator-Based Generation Control**: Major new feature for flexible handler generation
- **`@domainGinHandlerGen` decorator**: Mark namespaces or operations for handler generation
- **`@domainGinHandlerName("CustomName")` decorator**: Specify custom handler struct names
- **Multi-level generation control**: Operation-level decorators take precedence over namespace-level
- **Improved namespace collection**: Support for multiple namespaces in single file
- **Generation precedence system**: Operation-level > Namespace-level > Comment-based (backward compatible)

### Features

- **Operation-level generation**: Use `@domainGinHandlerGen` on specific operations to generate only those handlers
- **Namespace-level generation**: Use `@domainGinHandlerGen` on namespace to generate all operations within it
- **Custom handler names**: Replace default `Handler` with custom names like `UserHandler`, `AuthHandler` using `@domainGinHandlerName`
- **Selective generation**: More granular control over which handlers are generated
- **Backward compatibility**: Existing comment-based generation (`//!Generate`) still works
- **Priority system**: Operation decorators override namespace decorators for maximum flexibility

### Examples

**Namespace-level generation:**

```typespec
@domainGinHandlerGen
@domainGinHandlerName("UserHandler")
@route("/users")
namespace UserAPI {
    @post op CreateUser(...): ...;  // Generated with UserHandler
    @get op ListUsers(...): ...;    // Generated with UserHandler
}
```

**Operation-level generation:**

```typespec
@route("/auth")
namespace AuthAPI {
    @post
    @domainGinHandlerGen
    @domainGinHandlerName("AuthHandler")
    op Login(...): ...;         // Generated with AuthHandler

    @post
    op Register(...): ...;      // NOT generated (no decorator)
}
```

### Breaking Changes

- None - Fully backward compatible with v1.x

### Technical Changes

- Updated data structure to collect multiple namespaces per file
- Enhanced decorator detection and processing logic
- Improved handler name resolution with priority system
- Added comprehensive decorator validation and error handling

## [1.0.0] - 2025-08-03

### Added

- Initial release of TypeSpec Go Gin Emitter
- Generate Go structs from TypeSpec models with Gin framework compatibility
- Generate HTTP handlers specifically designed for `github.com/gin-gonic/gin`
- Support for nullable types using `github.com/guregu/null/v6`
- Inline request struct generation (no separate struct declarations)
- Configurable generation trigger comments
- Authentication comment generation from `@useAuth` decorators
- Validation tags from TypeSpec decorators (`@maxLength`, `@minLength`, etc.)
- Path and query parameter detection with commented variables
- Support for nested anonymous structs in request bodies
- Incremental generation with comment separators for models
- Selective handler regeneration based on generation comments
- Configurable output directories
- Commented request variables for safety and flexibility
- Clean handler generation without binding code clutter
- Custom TODO messages with developer attribution

### Features

- **Domain Models**: Generate from `/models/` directory to configured output
- **Gin HTTP Handlers**: Generate from `/routes/` directory with full `github.com/gin-gonic/gin` compatibility
- **Type Mapping**: Comprehensive TypeSpec to Go type conversion
- **Validation**: Automatic validation tag generation for `go-playground/validator/v10`
- **Authentication**: Support for Bearer, Basic, and API Key auth comments
- **Multipart**: Ready for multipart/form-data support
- **Configuration**: Fully configurable via `tspconfig.yaml`
- **Safety**: Commented request variables to prevent conflicts
- **Clean Output**: No binding code clutter in generated handlers

### Configuration Options

- `emitter-output-dir`: Domain models output directory
- `handler-output-dir`: HTTP handlers output directory
- `generate-comment`: Configurable generation trigger comment

### Supported TypeSpec Features

- Models with optional fields
- Operations with path, query, and body parameters
- Authentication decorators (`@useAuth`)
- Validation decorators (`@maxLength`, `@minLength`, `@minItems`)
- Nested models and arrays
- Union types for nullable fields
- HTTP method decorators (`@get`, `@post`, `@put`, etc.)
- Route decorators (`@route`)

### Generated Go Features

- Gin-compatible HTTP handlers with `*gin.Context` parameters
- Inline struct definitions for request bodies (following Gin best practices)
- Null-safe types using `github.com/guregu/null/v6`
- Validation tags for `github.com/go-playground/validator/v10`
- PascalCase field names with JSON tags
- Commented parameter variables for safe implementation
- Commented request variables to prevent conflicts
- Authentication requirement comments
- Custom TODO placeholders with developer attribution

### Design Philosophy

- **Gin-First**: Designed specifically for `github.com/gin-gonic/gin` framework
- **Safety-First**: Variables are commented to prevent unintended conflicts
- **Clean Output**: No binding code clutter in generated handlers
- **Flexibility**: Generated code serves as a template that developers can uncomment and modify
- **Best Practices**: Follows Go and Gin framework conventions
