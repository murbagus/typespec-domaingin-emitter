import "@typespec/http";
import "@murbagus/typespec-domaingin-emitter";

using Http;

namespace MyAPI;

// Test case 3: Namespace dengan fallback ke comment-based generation
//!Generate
@route("/products")
@tag("Products")
namespace ProductAPI {
    model CreateProductRequest {
        @maxLength(100)
        name: string;

        price: float64;
        description?: string;
    }

    @useAuth(BearerAuth)
    @post
    op CreateProduct(@body request: CreateProductRequest): {
        @statusCode statusCode: 201;
        @body product: Product;
    };

    @get
    op ListProducts(): {
        @statusCode statusCode: 200;
        @body products: Product[];
    };
}

model Product {
    id: int32;
    name: string;
    price: float64;
    description?: string;
}
