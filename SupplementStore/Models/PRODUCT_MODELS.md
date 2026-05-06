# Product Data Models

This document describes the product data structures converted from React Store components.

## Overview

Two main product structures are used in the React app:
1. **StoreProduct** - Simple structure for Store listing page
2. **Product** - Full structure for ProductDetails page

## StoreProduct

### React Source
From `Store.jsx`:
```javascript
const products = [
    { id: 1, img: img1, name: "Whey Sport", price: 49.99, oldPrice: 69.99 },
    // ...
];
```

### Swift Structure
```swift
struct StoreProduct: Identifiable, Codable {
    let id: Int
    let img: String      // Image asset name
    let name: String
    let price: Double
    let oldPrice: Double?
    
    var onSale: Bool { get }  // Computed: oldPrice != nil
}
```

### Properties
- `id: Int` - Unique product identifier
- `img: String` - Image asset name (e.g., "product_16", "BCAA Powder")
- `name: String` - Product name
- `price: Double` - Current price
- `oldPrice: Double?` - Original price (if on sale)
- `onSale: Bool` - Computed property indicating if product is on sale

### Sample Data
All 12 products from React Store.jsx are included:
1. Whey Sport
2. Whey Protein
3. Protein Bar
4. Creatine
5. BCAA Powder
6. Pre-Workout
7. Glutamine
8. Omega 3 Capsules
9. Vitamin D3
10. Multivitamins
11. Weight Gainer
12. Electrolyte Drink

Access via: `StoreProduct.allProducts`

## Product (Full Structure)

### React Source
From `ProductDetails.jsx`:
```javascript
const products = [
    {
        id: 1,
        img: img1,
        name: "Whey Sport",
        price: 49.99,
        oldPrice: 69.99,
        description: "High-quality whey protein...",
        additionalInfo: "Net weight: 2 lb...",
        reviews: [
            { name: "Jane Doe", rating: 5, comment: "Excellent..." }
        ]
    },
    // ...
];
```

### Swift Structure
```swift
struct Product: Identifiable, Codable {
    let id: Int
    let img: String              // Image asset name
    let name: String
    let price: Double
    let oldPrice: Double?
    let description: String
    let additionalInfo: String?
    let reviews: [Review]?
    
    var onSale: Bool { get }
    var image: String { get }     // Alias for img
    var category: String { get }  // Always "supplements"
}
```

### Properties
- `id: Int` - Unique product identifier
- `img: String` - Image asset name
- `name: String` - Product name
- `price: Double` - Current price
- `oldPrice: Double?` - Original price (if on sale)
- `description: String` - Product description
- `additionalInfo: String?` - Additional product information
- `reviews: [Review]?` - Array of product reviews
- `onSale: Bool` - Computed property
- `image: String` - Alias for `img` (for compatibility)
- `category: String` - Always returns "supplements"

### Sample Data
All 12 products with full details from React ProductDetails.jsx are included.

Access via: `Product.allProducts`

## Review

### React Source
```javascript
{ name: "Jane Doe", rating: 5, comment: "Excellent taste..." }
```

### Swift Structure
```swift
struct Review: Codable, Identifiable {
    let id: UUID()           // Auto-generated for SwiftUI
    let name: String
    let rating: Int          // 1-5 stars
    let comment: String
}
```

### Properties
- `id: UUID` - Unique identifier (auto-generated)
- `name: String` - Reviewer name
- `rating: Int` - Star rating (1-5)
- `comment: String` - Review comment

## Conversion Helpers

### StoreProduct → Product
```swift
let storeProduct = StoreProduct.allProducts[0]
if let fullProduct = storeProduct.toProduct() {
    // Use full product details
}
```

### Product → StoreProduct
```swift
let product = Product.allProducts[0]
let storeProduct = product.toStoreProduct()
```

## Usage Examples

### Store View
```swift
let products = StoreProduct.allProducts

ForEach(products) { product in
    ProductCard(product: product)
}
```

### Product Details View
```swift
// Find product by ID
if let product = Product.find(by: productId) {
    ProductDetailsView(product: product)
}
```

### Accessing Reviews
```swift
if let reviews = product.reviews {
    ForEach(reviews) { review in
        ReviewView(review: review)
    }
}
```

## Image Assets

All products use image asset names that should be added to Assets.xcassets:
- `product_16`, `product_17`, `product_19`, `product_20`
- `BCAA Powder`, `Pre-Workout`, `Glutamine`
- `Omega 3 Capsules`, `Vitamin D3`, `Multivitamins`
- `Weight Gainer`, `Electrolyte Drink`

## Data Matching

All product data exactly matches the React components:
- ✅ Same IDs (1-12)
- ✅ Same names
- ✅ Same prices and old prices
- ✅ Same descriptions
- ✅ Same additional info
- ✅ Same reviews with names, ratings, and comments
- ✅ Same image asset names

