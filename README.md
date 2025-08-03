# TypeSpec Go Gin Emitter

![npm version](https://img.shields.io/npm/v/typespec-domaingin-emitter.svg)
![license](https://img.shields.io/npm/l/typespec-domaingin-emitter.svg)
![downloads](https://img.shields.io/npm/dt/typespec-domaingin-emitter.svg)

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

🎯 **Smart Generation Control**

- Configurable generation trigger comments
- Selective file regeneration
- Incremental updates without losing existing code
- Support for multipart/form-data requests

## Installation

```bash
npm install typespec-go-emitter
```

## Quick Start

1. **Install dependencies**:

```bash
npm install @typespec/compiler @typespec/http typespec-go-emitter
```

2. **Configure tspconfig.yaml**:

```yaml
emit:
  - "typespec-go-emitter"
options:
  "typespec-go-emitter":
    emitter-output-dir: "./models"
    handler-output-dir: "./handlers"
    generate-comment: "//!Generate"
```

3. **Mark TypeSpec files for generation**:

```typespec
// routes/users.tsp
import "@typespec/http";

using Http;

namespace MyAPI;

//!Generate
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
}
```

4. **Compile**:

```bash
npx tsp compile .
```

## Generated Output

### Domain Models

From `models/user.tsp`:

```go
package domain

// User represents the user data structure
type User struct {
    ID       int32       `json:"id"`
    Name     string      `json:"name"`
    Email    null.String `json:"email"`
    IsActive bool        `json:"is_active"`
}
```

### HTTP Handlers

From `routes/users.tsp`:

```go
package http

// CreateUser Creates a new user
// Authentication: Required Bearer Token authentication
// Response: Expected response type based on operation definition
func (h *Handler) CreateUser(c *gin.Context) {
    // var request struct {
    //     Name     string      `json:"name" binding:"required,max=100"`
    //     Username string      `json:"username" binding:"required,min=3,max=50"`
    //     Email    null.String `json:"email"`
    // }

    // TODO: Implement your handler logic for CreateUser here 🚀 (by Muhammad Refy)
    c.JSON(200, gin.H{"message": "Not implemented"})
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
  - "typespec-go-emitter"
options:
  "typespec-go-emitter":
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
