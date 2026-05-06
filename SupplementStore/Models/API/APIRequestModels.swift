import Foundation

struct LoginRequest: Encodable {
    let email: String
    let password: String
}

struct RegisterRequest: Encodable {
    let name: String
    let email: String
    let password: String
    let phone: String
}

struct CreateOrderRequest: Encodable {
    let shippingAddress: String
    let paymentMethod: String
}

struct AddToCartRequest: Encodable {
    let productId: Int
    let quantity: Int
}

struct CreateReviewRequest: Encodable {
    let rating: Int
    let comment: String
}

struct CreateBookingRequest: Encodable {
    let date: String
    let time: String
    let notes: String?
}
