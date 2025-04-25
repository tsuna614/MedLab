//
//  Product.swift
//  MedLab
//
//  Created by Khanh Nguyen Quoc on 3/4/25.
//

import Foundation

struct Product: Identifiable, Codable, Equatable {
    let id: String
    let name: String
    let brand: String?
    let description: String?
    let imageUrl: String?
    let dosageForm: String? // e.g., Tablet, Syrup, Injection
    let strength: String? // e.g., "500mg"
    let category: String? // e.g., Antibiotic, Painkiller
    let ingredients: [String]?
    let price: Double
    let stock: Int
    let prescriptionRequired: Bool
    let manufacturer: String?
    let expiryDate: String? // Or use Date if your API supports it
    let instructions: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name
        case brand
        case description
        case imageUrl
        case dosageForm
        case strength
        case category
        case ingredients
        case price
        case stock
        case prescriptionRequired
        case manufacturer
        case expiryDate
        case instructions
    }
}

let dummyProducts: [Product] = [
    Product(
        id: UUID().uuidString,
        name: "Neutrogena Deep Clean Facial Cleanser",
        brand: "Neutrogena",
        description: "A dermatologist-recommended facial cleanser that removes dirt, oil, and makeup without over-drying.",
        imageUrl: "https://product.hstatic.net/200000868185/product/tn2840__40__1802cd6c94354dc59d64bf02427f61d8_db35425509da4722956b0dc4493088b1_master.jpg",
        dosageForm: "Liquid",
        strength: nil,
        category: "Beauty Care",
        ingredients: ["Water", "Salicylic Acid", "Glycerin"],
        price: 10.99,
        stock: 75,
        prescriptionRequired: false,
        manufacturer: "Johnson & Johnson",
        expiryDate: "2025-07-01T00:00:00.000Z",
        instructions: "Apply to wet face, gently massage, and rinse off. Use twice daily."
    ),
    Product(
        id: UUID().uuidString,
        name: "ZzzQuil Nighttime Sleep Aid",
        brand: "ZzzQuil",
        description: "Non-habit-forming sleep aid to help you fall asleep easily and wake up refreshed.",
        imageUrl: "https://images.ctfassets.net/34zny1xcpyrz/gzBvg4PtxLr3QXqLB3XQI/ce37216482bb339eb3138e688c392888/PDP_desk_ZzzQ_Vanilla_Cherry_12oz_HERO_056.jpg",
        dosageForm: "Liquid",
        strength: "50mg",
        category: "Sleep Support",
        ingredients: ["Diphenhydramine HCI"],
        price: 8.49,
        stock: 60,
        prescriptionRequired: false,
        manufacturer: "Procter & Gamble",
        expiryDate: "2025-12-10T00:00:00.000Z",
        instructions: "Take 30 mL before bedtime. Do not exceed recommended dose."
    ),
    Product(
        id: UUID().uuidString,
        name: "Gatorade Protein Shake",
        brand: "Gatorade",
        description: "Protein-packed recovery shake designed to help rebuild muscles post-workout.",
        imageUrl: "https://www.medco-athletics.com/media/catalog/product/n/u/nutrition_shake_vanilla_1.png?width=700&height=700&canvas=700,700&optimize=low&bg-color=255,255,255&fit=bounds",
        dosageForm: "Liquid",
        strength: "30g Protein",
        category: "Endurance & Performance",
        ingredients: ["Milk Protein", "Vitamins", "Minerals"],
        price: 3.49,
        stock: 100,
        prescriptionRequired: false,
        manufacturer: "PepsiCo",
        expiryDate: "2026-01-20T00:00:00.000Z",
        instructions: "Shake well and drink after exercise or as needed for protein intake."
    ),
    Product(
        id: UUID().uuidString,
        name: "Vaseline Intensive Care Lotion",
        brand: "Vaseline",
        description: "Deeply moisturizes dry skin and keeps it hydrated for 24 hours.",
        imageUrl: "https://dep7ngay.vn/cdn/shop/files/7279713059025-41630738612433_700x700.jpg?v=1696135744",
        dosageForm: "Lotion",
        strength: nil,
        category: "Personal Care",
        ingredients: ["Petrolatum", "Glycerin", "Vitamin E"],
        price: 5.99,
        stock: 180,
        prescriptionRequired: false,
        manufacturer: "Unilever",
        expiryDate: "2025-10-30T00:00:00.000Z",
        instructions: "Apply generously to dry areas as needed."
    ),
    Product(
        id: UUID().uuidString,
        name: "Centrum Adult Multivitamin",
        brand: "Centrum",
        description: "Daily multivitamin supplement to support overall health and immunity.",
        imageUrl: "https://bizweb.dktcdn.net/100/052/185/products/anh-dai-dien-centrum-adults-vuong.jpg?v=1691915507693",
        dosageForm: "Tablet",
        strength: "One-a-day",
        category: "Dietary Supplements",
        ingredients: ["Vitamin A", "Vitamin C", "Zinc", "Iron"],
        price: 11.99,
        stock: 130,
        prescriptionRequired: false,
        manufacturer: "Pfizer",
        expiryDate: "2026-04-15T00:00:00.000Z",
        instructions: "Take one tablet daily with food."
    )
]
