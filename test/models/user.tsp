import "@typespec/http";

model User {
    id: int32;
    name: string;
    email?: string;
    isActive: boolean;
}

model CreateUserRequest {
    @maxLength(100)
    name: string;

    @minLength(3)
    @maxLength(50)
    username: string;

    email?: string;
}
