import "@typespec/http";
import "@murbagus/typespec-domaingin-emitter";

using Http;

namespace MyAPI;

// Test case 1: Namespace dengan @domainGinHandlerGen dan @domainGinHandlerName
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

    @domainGinHandlerGen
    @get
    op ListUsers(): {
        @statusCode statusCode: 200;
        @body users: User[];
    };
}

// Test case 2: Namespace dengan default handler name tapi ada operation dengan decorator
@route("/auth")
@tag("Auth")
namespace AuthAPI {
    @post
    op Login(@body request: LoginRequest): {
        @statusCode statusCode: 200;
        @body token: string;
    };

    @post
    op Register(@body request: RegisterRequest): {
        @statusCode statusCode: 201;
        @body user: User;
    };
}

model User {
    id: int32;
    name: string;
    email?: string;
    isActive: boolean;
}

model LoginRequest {
    username: string;
    password: string;
}

model RegisterRequest {
    username: string;
    password: string;
    email: string;
}
