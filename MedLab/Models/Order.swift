//
//  Order.swift
//  MedLab
//
//  Created by Khanh Nguyen Quoc on 23/4/25.
//

import Foundation

enum OrderStatus: String, Codable, CaseIterable, Identifiable {
    case pending = "Pending"
    case processing = "Processing"
    case shipped = "Shipped"
    case delivered = "Delivered"
    case cancelled = "Cancelled"
    case refunded = "Refunded"

    var id: String { self.rawValue }
}

struct OrderItem: Codable, Identifiable {
    var id: String { productId }

    let productId: String
    let productNameSnapshot: String
    let quantity: Int
    let priceAtPurchase: Double
    let imageUrlSnapshot: String?

    var subtotal: Double {
        Double(quantity) * priceAtPurchase
    }

     enum CodingKeys: String, CodingKey {
         case productId = "product_id"
         case productNameSnapshot = "product_name"
         case quantity
         case priceAtPurchase = "price"
         case imageUrlSnapshot = "image_url"
     }
}

// Represents a single completed Order
struct Order: Codable, Identifiable {
    let id: String
    let orderNumber: String
    let userId: String
    let orderDate: Date
    let items: [OrderItem]
    let totalAmount: Double
    let shippingCost: Double
    let taxAmount: Double
    let status: OrderStatus
    let shippingAddress: ShippingAddress
    let paymentMethodDetails: String?
    let trackingNumber: String?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case orderNumber
        case userId
        case orderDate
        case items
        case totalAmount
        case shippingCost
        case taxAmount
        case status
        case shippingAddress
        case paymentMethodDetails
        case trackingNumber
    }
}

struct ShippingAddress: Codable {
    let recipientName: String?
    let street: String
    let city: String
    let state: String
    let postalCode: String
    let country: String
    let phoneNumber: String?
}


// MARK: - Dummy Data for Previews/Testing

extension Order {
    static var sampleOrders: [Order] {
        let address1 = ShippingAddress(recipientName: "John Doe", street: "1 Apple Park Way", city: "Cupertino", state: "CA", postalCode: "95014", country: "USA", phoneNumber: "555-1234")
        let address2 = ShippingAddress(recipientName: "Jane Smith", street: "456 Market St", city: "San Francisco", state: "CA", postalCode: "94105", country: "USA", phoneNumber: "555-5678")

        let dateFormatter = ISO8601DateFormatter() // Standard format often used in APIs
        dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        return [
            Order(
                id: "order_662b12a3b4c5d6e7f8a9b0c1", // Example ID
                orderNumber: "ORD-1001",
                userId: "user_abc123",
                orderDate: dateFormatter.date(from: "2024-04-25T10:30:00.123Z") ?? Date(),
                items: [
                    OrderItem(productId: dummyProducts[0].id, productNameSnapshot: dummyProducts[0].name, quantity: 1, priceAtPurchase: 10.99, imageUrlSnapshot: dummyProducts[0].imageUrl),
                    OrderItem(productId: dummyProducts[2].id, productNameSnapshot: dummyProducts[2].name, quantity: 2, priceAtPurchase: 3.49, imageUrlSnapshot: dummyProducts[2].imageUrl)
                ],
                totalAmount: 24.97, // 10.99 + (2 * 3.49) + 5.00 + 2.00 (Example values)
                shippingCost: 5.00,
                taxAmount: 2.00,
                status: .delivered,
                shippingAddress: address1,
                paymentMethodDetails: "Visa ending in 1234",
                trackingNumber: "1Z999AA10123456784"
            ),
            Order(
                id: "order_662b13b4c5d6e7f8a9b0c2d3",
                orderNumber: "ORD-1002",
                userId: "user_xyz789",
                orderDate: dateFormatter.date(from: "2024-04-26T15:00:00.000Z") ?? Date(),
                items: [
                    OrderItem(productId: dummyProducts[4].id, productNameSnapshot: dummyProducts[4].name, quantity: 1, priceAtPurchase: 11.99, imageUrlSnapshot: dummyProducts[4].imageUrl)
                ],
                totalAmount: 17.98, // 11.99 + 5.00 + 0.99 (Example values)
                shippingCost: 5.00,
                taxAmount: 0.99,
                status: .shipped,
                shippingAddress: address2,
                paymentMethodDetails: "Mastercard ending in 5678",
                trackingNumber: "9405511899561234567890"
            ),
             Order(
                id: "order_662b14c5d6e7f8a9b0c3e4f5",
                orderNumber: "ORD-1003",
                userId: "user_abc123", // Same user as first order
                orderDate: dateFormatter.date(from: "2024-04-27T09:15:45.500Z") ?? Date(),
                items: [
                    OrderItem(productId: dummyProducts[1].id, productNameSnapshot: dummyProducts[1].name, quantity: 1, priceAtPurchase: 8.49, imageUrlSnapshot: dummyProducts[1].imageUrl),
                    OrderItem(productId: dummyProducts[3].id, productNameSnapshot: dummyProducts[3].name, quantity: 1, priceAtPurchase: 5.99, imageUrlSnapshot: dummyProducts[3].imageUrl)
                ],
                totalAmount: 20.63, // 8.49 + 5.99 + 5.00 + 1.15 (Example values)
                shippingCost: 5.00,
                taxAmount: 1.15,
                status: .processing,
                shippingAddress: address1, // Could be same or different address
                paymentMethodDetails: "Visa ending in 1234",
                trackingNumber: nil // Not shipped yet
            )
        ]
    }
}
