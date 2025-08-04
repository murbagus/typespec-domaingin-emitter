# TypeSpec Go Gin Emitter

![npm version](https://img.shields.io/npm/v/@murbagus/typespec-domaingin-emitter.svg)
![license](https://img.shields.io/npm/l/@murbagus/typespec-domaingin-emitter.svg)
![downloads](https://img.shields.io/npm/dt/@murbagus/typespec-domaingin-emitter.svg)

A TypeSpec emitter that generates Go structs and HTTP handlers specifically designed for **[github.com/gin-gonic/gin](https://github.com/gin-gonic/gin)** framework applications. This emitter produces handler code that follows Gin's conventions and patterns.

## Features

✨ **Domain Models Generation**

- Generate Go structs from TypeSpec models
- Automatic field name conversion to PascalCase
- JSON tags from TypeSpec field names
- Support for nullable types using `github.com/guregu/null/v6`
- Preserve existing code with comment separators

🔧 **Gin-Compatible Handler Generation**

- Generate HTTP handlers compatible with `github.com/gin-gonic/gin`
- Inline request struct definitions (matching Gin best practices)
- Automatic parameter detection (path, query, body)
- Authentication comment generation from `@useAuth` decorators
- Configurable validation tags from TypeSpec decorators
- **Commented request variables** for safety and flexibility
- Clean template-based generation without binding code clutter

🎯 **Smart Generation Control** (New in v2.0)

- **Decorator-based generation control** with `@domainGinHandlerGen`
- **Custom handler names** with `@domainGinHandlerName("CustomHandler")`
- **Namespace-level or operation-level generation**
- Backward compatible comment-based generation
- Selective file regeneration
- Incremental updates without losing existing code
- Support for multipart/form-data requests

## Installation

```bash
npm install @murbagus/typespec-domaingin-emitter
```

## Quick Start

1. **Install dependencies**:

```bash
npm install @typespec/compiler @typespec/http @murbagus/typespec-domaingin-emitter
```

2. **Configure tspconfig.yaml**:

```yaml
emit:
  - "@murbagus/typespec-domaingin-emitter"
options:
  "@murbagus/typespec-domaingin-emitter":
    emitter-output-dir: "{project-root}/domain"
    handler-output-dir: "{project-root}/handlers"
```

3. **Use decorators for generation control**:

```typespec
// routes/users.tsp
import "@typespec/http";
import "@murbagus/typespec-domaingin-emitter";

using Http;

// Generate all operations in this namespace with custom handler name
@domainGinHandlerGen
@domainGinHandlerName("UserHandler")
@route("/users")
@tag("Users")
namespace UserAPI {
    model CreateUserRequest {
        @maxLength(100)
        name: string;

        @minLength(3)
        @maxLength(50)
        username: string;

        email?: string;
    }

    @post
    op CreateUser(@body request: CreateUserRequest): {
        @statusCode statusCode: 201;
        @body user: User;
    };

    @get
    op ListUsers(): {
        @statusCode statusCode: 200;
        @body users: User[];
    };
}

// Only generate specific operations
@route("/auth")
namespace AuthAPI {
    @post
    @domainGinHandlerGen
    @domainGinHandlerName("AuthHandler")
    op Login(@body request: LoginRequest): {
        @statusCode statusCode: 200;
        @body token: string;
    };

    // This operation won't be generated (no decorator)
    @post
    op Register(@body request: RegisterRequest): {
        @statusCode statusCode: 201;
        @body user: User;
    };
}
```

4. **Compile**:

```bash
npx tsp compile .
```

## Generated Output

### Namespace-Level Generation

From the example above, `UserAPI` namespace will generate:

```go
package http

// CreateUser handles the createuser operation
// Response: Expected response type based on operation definition
func (h *UserHandler) CreateUser(c *gin.Context) {
    // var request struct {
    //     Name     string      `json:"name" binding:"required,max=100"`
    //     Username string      `json:"username" binding:"required,min=3,max=50"`
    //     Email    null.String `json:"email"`
    // }

    // TODO: Implement your handler logic for CreateUser here 🚀 (by Muhammad Refy)
    c.JSON(200, gin.H{"message": "Not implemented"})
}

// ListUsers handles the listusers operation
// Response: Expected response type based on operation definition
func (h *UserHandler) ListUsers(c *gin.Context) {
    // TODO: Implement your handler logic for ListUsers here 🚀 (by Muhammad Refy)
    c.JSON(200, gin.H{"message": "Not implemented"})
}
```

### Operation-Level Generation

Only the `Login` operation will be generated:

```go
package http

// Login handles the login operation
// Response: Expected response type based on operation definition
func (h *AuthHandler) Login(c *gin.Context) {
    // var request struct {
    //     Username string `json:"username" binding:"required"`
    //     Password string `json:"password" binding:"required"`
    // }

    // TODO: Implement your handler logic for Login here 🚀 (by Muhammad Refy)
    c.JSON(200, gin.H{"message": "Not implemented"})
}
```

## Decorator-Based Generation Control (v2.0)

The v2.0 introduces powerful decorator-based generation control that provides more flexibility than comment-based generation.

### Available Decorators

#### `@domainGinHandlerGen`

Marks a namespace or operation for handler generation.

**Namespace-level usage:**

```typespec
@domainGinHandlerGen
@route("/users")
namespace UserAPI {
    // All operations in this namespace will be generated
    @post op CreateUser(...): ...;
    @get op ListUsers(...): ...;
}
```

**Operation-level usage:**

```typespec
@route("/auth")
namespace AuthAPI {
    @domainGinHandlerGen
    @post op Login(...): ...;  // Only this operation will be generated

    @post op Register(...): ...; // This will NOT be generated
}
```

#### `@domainGinHandlerName("HandlerName")`

Specifies the custom handler struct name for generated functions.

**Examples:**

```typespec
// Generates: func (h *UserHandler) CreateUser(c *gin.Context)
@domainGinHandlerGen
@domainGinHandlerName("UserHandler")
namespace UserAPI {
    @post op CreateUser(...): ...;
}

// Generates: func (h *AuthHandler) Login(c *gin.Context)
@post
@domainGinHandlerGen
@domainGinHandlerName("AuthHandler")
op Login(...): ...;
```

### Generation Precedence

The emitter follows this priority order:

1. **Operation-level decorators** (highest priority)

   - If any operation has `@domainGinHandlerGen`, only those operations are generated
   - Namespace-level decorators are ignored when operation-level decorators exist

2. **Namespace-level decorators** (medium priority)

   - If namespace has `@domainGinHandlerGen` and no operations have decorators, all operations in namespace are generated

3. **Comment-based generation** (lowest priority - backward compatibility)
   - Falls back to `//!Generate` comment or configured `generate-comment` option

### Examples

#### Mixed Usage Example

```typespec
import "@typespec/http";
import "@murbagus/typespec-domaingin-emitter";

using Http;

// Namespace with decorator - generates ALL operations with UserHandler
@domainGinHandlerGen
@domainGinHandlerName("UserHandler")
@route("/users")
namespace UserAPI {
    @post op CreateUser(@body request: CreateUserRequest): User;
    @get op GetUser(@path id: int32): User;
    @put op UpdateUser(@path id: int32, @body request: UpdateUserRequest): User;
    @delete op DeleteUser(@path id: int32): void;
}

// Mixed namespace - only Login is generated because of operation-level decorator
@route("/auth")
namespace AuthAPI {
    @post
    @domainGinHandlerGen
    @domainGinHandlerName("AuthHandler")
    op Login(@body request: LoginRequest): LoginResponse;

    @post
    op Register(@body request: RegisterRequest): User; // NOT generated

    @post
    op ForgotPassword(@body request: ForgotPasswordRequest): void; // NOT generated
}

// Legacy comment-based generation (still supported)
//!Generate
@route("/products")
namespace ProductAPI {
    @post op CreateProduct(@body request: ProductRequest): Product;
    @get op ListProducts(): Product[];
}
```

#### Handler Name Priority

Handler names are resolved in this order:

1. **Operation-level** `@domainGinHandlerName` (highest priority)
2. **Namespace-level** `@domainGinHandlerName`
3. **Default** `Handler` (fallback)

```typespec
@domainGinHandlerName("UserService")  // Namespace-level name
@route("/users")
namespace UserAPI {
    @post
    @domainGinHandlerName("UserController")  // Operation-level name (takes precedence)
    op CreateUser(...): ...;  // Generated as: func (h *UserController) CreateUser(...)

    @get
    op GetUser(...): ...;     // Generated as: func (h *UserService) GetUser(...)
}
```

    c.JSON(200, gin.H{"message": "Not implemented"})

}

````

## Configuration Options

| Option               | Type   | Default                      | Description                                  |
| -------------------- | ------ | ---------------------------- | -------------------------------------------- |
| `emitter-output-dir` | string | `"../application/domain"`    | Output directory for domain models           |
| `handler-output-dir` | string | `"../drivers/delivery/http"` | Output directory for HTTP handlers           |
| `generate-comment`   | string | `"//!Generate"`              | Comment to mark files for handler generation |

### Example Configuration

```yaml
# tspconfig.yaml
emit:
  - "typespec-domaingin-emitter"
options:
  "typespec-domaingin-emitter":
    emitter-output-dir: "./internal/domain"
    handler-output-dir: "./internal/handlers"
    generate-comment: "// @generate"
````

## Type Mapping

| TypeSpec Type  | Optional | Go Type       |
| -------------- | -------- | ------------- |
| `string`       | No       | `string`      |
| `string?`      | Yes      | `null.String` |
| `int32`        | No       | `int32`       |
| `int32?`       | Yes      | `null.Int`    |
| `utcDateTime`  | No       | `time.Time`   |
| `utcDateTime?` | Yes      | `null.Time`   |
| `boolean`      | No       | `bool`        |
| `boolean?`     | Yes      | `null.Bool`   |
| `ModelName`    | No       | `ModelName`   |
| `ModelName?`   | Yes      | `*ModelName`  |

## Validation Tags

TypeSpec decorators are automatically converted to Go validation tags:

```typespec
model User {
    @maxLength(100)
    name: string;           // → `binding:"required,max=100"`

    @minLength(8)
    @maxLength(128)
    password: string;       // → `binding:"required,min=8,max=128"`

    @minItems(1)
    tags: string[];         // → `binding:"required,min=1,dive,required"`

    email?: string;         // → `binding:""` (optional, no required tag)
}
```

## Authentication Support

The emitter recognizes `@useAuth` decorators and generates appropriate comments:

```typespec
@useAuth(BearerAuth)
@get
op GetUser(@path id: int32): User;
```

Generates:

```go
// GetUser retrieves user information
// Authentication: Required Bearer Token authentication
// Path parameters:
// - id: path parameter
func (h *Handler) GetUser(c *gin.Context) {
    // id := c.Param("id") // int32
    // TODO: Implement GetUser handler logic
}
```

## Incremental Generation

### Models

Domain models are always regenerated, but existing code above the separator comment is preserved:

```go
package domain

import "time"

// Custom constants and functions
const UserStatusActive = 1

// --- Generated by typespec ---

// User represents the user data structure
type User struct {
    // ... generated fields
}
```

### Handlers

Only files marked with the generation comment are regenerated. New handlers are appended to existing files.

## Nested Structures

For complex request bodies with nested objects:

```typespec
model Address {
    street: string;
    city: string;
    zipCode?: string;
}

model CreateUserRequest {
    name: string;
    addresses: Address[];
}
```

Generates inline anonymous structs (commented for safety):

```go
// var request struct {
//     Name string `json:"name" binding:"required"`
//     Addresses []struct {
//         Street  string      `json:"street" binding:"required"`
//         City    string      `json:"city" binding:"required"`
//         ZipCode null.String `json:"zipCode"`
//     } `json:"addresses" binding:"required,dive,required"`
// }
```

## Safety-First Approach

All generated request variables are commented out by default to prevent:

- Conflicts with existing code
- Unintended variable shadowing
- Compilation errors in complex handlers

Simply uncomment and modify the generated code as needed:

```go
func (h *Handler) CreateUser(c *gin.Context) {
    // Generated template (uncomment and modify as needed)
    // var request struct {
    //     Name string `json:"name" binding:"required"`
    // }

    // Your custom implementation
    var req CreateUserRequest
    if err := c.ShouldBindJSON(&req); err != nil {
        // handle error
    }
    // ... rest of implementation
}
```

## Multipart Support

The emitter can detect multipart requests and generate appropriate form tags alongside JSON tags.

## Best Practices

1. **Organize TypeSpec files**: Keep models in `/models/` and routes in `/routes/`
2. **Use descriptive comments**: Add documentation to your TypeSpec definitions
3. **Mark selectively**: Only add generation comments to routes you want to regenerate
4. **Preserve custom code**: Keep your implementations above the separator in model files
5. **Uncomment safely**: Generated code is commented for safety - uncomment and modify as needed
6. **Follow Gin patterns**: Generated handlers follow `github.com/gin-gonic/gin` conventions
7. **Version control**: Commit both TypeSpec files and generated Go code

## Contributing

We welcome contributions! Please see our [Contributing Guide](CONTRIBUTING.md) for details.

## License

MIT License - see [LICENSE](LICENSE) file for details.

## Contributing

We welcome contributions! Please see our [Contributing Guide](CONTRIBUTING.md) for details.

## License

MIT License - see [LICENSE](LICENSE) file for details.

---

Made with ❤️ by Muhammad Refy for the Go and TypeSpec communities.
