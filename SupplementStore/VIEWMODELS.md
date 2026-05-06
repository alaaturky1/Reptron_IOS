# ViewModels - React Context to SwiftUI Conversion

This document describes how the React contexts have been converted to SwiftUI ObservableObject ViewModels.

## Conversion Overview

| React Context | SwiftUI ViewModel | Key Properties/Methods |
|--------------|------------------|----------------------|
| `UserContext` | `UserViewModel` | `isLogin`, `setLogin()`, `login()`, `register()`, `logout()` |
| `CartContext` | `CartViewModel` | `cart`, `addToCart()`, `removeFromCart()`, `decreaseQuantity()`, `clearCart()` |
| `PurchaseContext` | `PurchaseViewModel` | `purchases`, `addPurchase()` |

## UserViewModel

### React Implementation
```javascript
const [isLogin, setLogin] = useState(null);
// isLogin is null when not logged in, or token string when logged in
```

### SwiftUI Implementation
```swift
@Published var isLogin: String? = nil
// isLogin is nil when not logged in, or token string when logged in

func setLogin(_ token: String?)
func login(email: String, password: String) async
func register(name: String, email: String, password: String, phone: String) async
func logout()
```

### Key Features
- **State Management**: `isLogin` matches React's nullable token state
- **Persistence**: Uses `UserDefaults` (equivalent to `localStorage`)
- **Computed Property**: `isLoggedIn` provides boolean convenience
- **Token Storage**: Automatically saves/removes token from `UserDefaults`

### Usage
```swift
@EnvironmentObject var userViewModel: UserViewModel

// Check login status
if userViewModel.isLoggedIn {
    // User is logged in
}

// Login
await userViewModel.login(email: "user@example.com", password: "Password123")

// Logout
userViewModel.logout()
```

## CartViewModel

### React Implementation
```javascript
const [cart, setCart] = useState([]);

const addToCart = (product) => {
    const exists = prev.find(item => item.id === product.id);
    if (exists) {
        return prev.map(item => 
            item.id === product.id 
                ? { ...item, quantity: item.quantity + product.quantity } 
                : item
        );
    }
    return [...prev, { ...product, quantity: product.quantity }];
};

const removeFromCart = (id) => {
    setCart(prev => prev.filter(item => item.id !== id));
};

const decreaseQuantity = (id) => {
    setCart(prev =>
        prev.map(item =>
            item.id === id ? { ...item, quantity: item.quantity - 1 } : item
        ).filter(item => item.quantity > 0)
    );
};

const clearCart = () => setCart([]);
```

### SwiftUI Implementation
```swift
@Published var cart: [CartItemModel] = []

func addToCart(_ product: CartItemModel)
func addProductToCart(_ product: Product, quantity: Int = 1)
func addEquipmentToCart(_ equipment: Equipment, quantity: Int = 1)
func removeFromCart(_ id: Int)
func decreaseQuantity(_ id: Int)
func clearCart()

var grandTotal: Double { get }
var itemsCount: Int { get }
```

### Key Features
- **Cart Items**: `CartItemModel` matches React cart item structure (flat properties, not nested)
- **Add Logic**: Matches React's existence check and quantity update
- **Remove Logic**: Filters out items by ID
- **Decrease Logic**: Decrements quantity and removes if <= 0
- **Computed Properties**: `grandTotal` and `itemsCount` for UI display

### CartItemModel Structure
Matches React cart items which have product properties directly:
```swift
struct CartItemModel {
    let id: Int
    let name: String
    let price: Double
    var quantity: Int  // Mutable for updates
    let img: String
    let category: String?
    let description: String?
    let oldPrice: Double?
    let onSale: Bool?
}
```

### Usage
```swift
@EnvironmentObject var cartViewModel: CartViewModel

// Add product to cart
cartViewModel.addProductToCart(product, quantity: 2)

// Remove from cart
cartViewModel.removeFromCart(productId: 123)

// Decrease quantity
cartViewModel.decreaseQuantity(id: 123)

// Get totals
let total = cartViewModel.grandTotal
let count = cartViewModel.itemsCount

// Clear cart
cartViewModel.clearCart()
```

## PurchaseViewModel

### React Implementation
```javascript
const [purchases, setPurchases] = useState([]);

const addPurchase = (order) => {
    setPurchases(prev => [...prev, order]);
};

// Stored in localStorage
localStorage.setItem("purchases", JSON.stringify([...previousOrders, newOrder]));
const previousOrders = JSON.parse(localStorage.getItem("purchases")) || [];
```

### SwiftUI Implementation
```swift
@Published var purchases: [PurchaseOrder] = []

func addPurchase(_ order: PurchaseOrder)

// Automatically saves/loads from UserDefaults
private func loadPurchases()
private func savePurchases()

var purchasesReversed: [PurchaseOrder] { get }
```

### Key Features
- **Persistence**: Automatically saves to `UserDefaults` (matches `localStorage`)
- **Order Structure**: `PurchaseOrder` matches React order structure
- **Auto-load**: Loads purchases on initialization
- **Reverse Order**: Provides reversed array for newest-first display

### PurchaseOrder Structure
Matches React order structure:
```swift
struct PurchaseOrder {
    let id: Int
    let date: String  // Formatted date string
    let items: [CartItemModel]  // Cart items directly
    let total: Double
    let shippingAddress: ShippingAddress
}
```

### Usage
```swift
@EnvironmentObject var purchaseViewModel: PurchaseViewModel

// Create order from cart
let order = PurchaseOrder(
    items: cartViewModel.cart,
    total: cartViewModel.grandTotal,
    shippingAddress: ShippingAddress(...)
)

// Add purchase
purchaseViewModel.addPurchase(order)

// Access purchases (newest first)
let recentPurchases = purchaseViewModel.purchasesReversed
```

## Data Flow

### React Flow
1. Context providers wrap app
2. Components access context via `useContext()`
3. State updates trigger re-renders
4. Data persists in `localStorage`

### SwiftUI Flow
1. ViewModels injected as `@EnvironmentObject` at app root
2. Views access via `@EnvironmentObject` property wrapper
3. `@Published` properties trigger view updates
4. Data persists in `UserDefaults`

## Migration Notes

1. **Cart Items**: Changed from nested `CartItem(product: Product)` to flat `CartItemModel` matching React structure
2. **User State**: `isLogin` is optional String (nil/token) matching React's null/token pattern
3. **Persistence**: All persistence uses `UserDefaults` matching React's `localStorage`
4. **Async Operations**: Login/Register use async/await for API calls
5. **Computed Properties**: Added convenience properties like `isLoggedIn`, `grandTotal`, `itemsCount`

## Testing

All ViewModels maintain the same logic as React contexts:
- ✅ Add to cart with quantity handling
- ✅ Remove from cart
- ✅ Decrease quantity with auto-removal
- ✅ Clear cart
- ✅ User session persistence
- ✅ Purchase history persistence
- ✅ Login/logout flow

