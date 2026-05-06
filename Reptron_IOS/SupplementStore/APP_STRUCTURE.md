# Complete App Structure

This document describes the fully assembled SwiftUI app structure matching the React website.

## App Entry Point

### SupplementStoreApp.swift
Main app file that:
- Initializes all ViewModels (UserViewModel, CartViewModel, PurchaseViewModel, NavigationCoordinator)
- Injects them as environment objects
- Launches MainAppView

```swift
@main
struct SupplementStoreApp: App {
    @StateObject private var userViewModel = UserViewModel()
    @StateObject private var cartViewModel = CartViewModel()
    @StateObject private var purchaseViewModel = PurchaseViewModel()
    @StateObject private var navigationCoordinator = NavigationCoordinator()
    
    var body: some Scene {
        WindowGroup {
            MainAppView()
                .environmentObject(userViewModel)
                .environmentObject(cartViewModel)
                .environmentObject(purchaseViewModel)
                .environmentObject(navigationCoordinator)
        }
    }
}
```

## Navigation Structure

### MainAppView
Root view that handles:
- Authentication state checking
- NavigationStack setup
- Route resolution
- Layout wrapping

**When Not Logged In:**
- Shows `LayoutView` with `HomeView`
- Public routes accessible (Home, Login, Register)

**When Logged In:**
- Shows `MainTabView` with 5 tabs
- All protected routes accessible

## Tab Navigation (Logged In)

### MainTabView
Tab-based navigation with 5 tabs:

1. **Home Tab** (Tag 0)
   - LayoutView → HomeView
   - Public access

2. **Store Tab** (Tag 1)
   - LayoutView → ProtectedRoute → StoreView
   - Shows all supplements/products

3. **Equipments Tab** (Tag 2)
   - LayoutView → ProtectedRoute → EquipmentsView
   - Shows gym equipment

4. **Coaches Tab** (Tag 3)
   - LayoutView → ProtectedRoute → CoachesView
   - Shows fitness coaches

5. **Cart Tab** (Tag 4)
   - LayoutView → ProtectedRoute → CartView
   - Shows shopping cart with badge count

Each tab has its own NavigationStack for proper navigation within that tab.

## Route Structure

### Public Routes
- `.home` → HomeView (with Layout)
- `.login` → LoginView (no Layout)
- `.register` → RegisterView (no Layout)

### Protected Routes (Require Authentication)
- `.aboutUs` → AboutUsView
- `.coaches` → CoachesView
- `.coach(id:)` → CoachDetailsView
- `.coachesProfiles(id:)` → CoachesProfilesView
- `.equipments` → EquipmentsView
- `.equipmentDetails(id:)` → EquipmentsDetailsView
- `.store` → StoreView
- `.productDetails(id:)` → ProductDetailsView
- `.cart` → CartView
- `.checkout` → CheckoutView
- `.myPurchases` → MyPurchasesView

### Error Route
- `.notFound` → NotFoundView

## Layout Structure

### LayoutView
Wrapper component matching React Layout:
- **Navbar**: Shown when user is logged in
- **Content**: Main view content
- **Footer**: Always shown

All views (except Login/Register) are wrapped in LayoutView to match React structure.

## State Management

### Environment Objects (Injected at App Level)
1. **UserViewModel** - Authentication state
   - `isLogin: String?` - Token or nil
   - `isLoggedIn: Bool` - Computed property
   - `login()`, `register()`, `logout()`

2. **CartViewModel** - Shopping cart
   - `cart: [CartItemModel]`
   - `addToCart()`, `removeFromCart()`, `clearCart()`
   - `grandTotal`, `itemsCount`

3. **PurchaseViewModel** - Order history
   - `purchases: [PurchaseOrder]`
   - `addPurchase()`

4. **NavigationCoordinator** - Navigation state
   - `path: NavigationPath`
   - `navigate()`, `navigateBack()`, `navigateToRoot()`

## View Hierarchy

```
SupplementStoreApp
└── MainAppView
    └── NavigationStack
        ├── (Not Logged In)
        │   └── LayoutView
        │       ├── NavbarView (hidden)
        │       ├── HomeView
        │       └── FooterView
        │
        └── (Logged In)
            └── MainTabView
                ├── Tab 0: Home
                │   └── LayoutView → HomeView
                ├── Tab 1: Store
                │   └── LayoutView → StoreView
                ├── Tab 2: Equipments
                │   └── LayoutView → EquipmentsView
                ├── Tab 3: Coaches
                │   └── LayoutView → CoachesView
                └── Tab 4: Cart
                    └── LayoutView → CartView
```

## Navigation Flow

### Public Flow (Not Logged In)
1. App launches → HomeView (with Layout)
2. User can navigate to Login or Register
3. After login → MainTabView appears

### Protected Flow (Logged In)
1. App launches → MainTabView
2. User can switch between tabs
3. Each tab can navigate to detail views
4. Navigation preserved within each tab

## Key Features

### ✅ Authentication
- Token-based authentication
- Persistent login (UserDefaults)
- Protected routes with automatic redirect

### ✅ Shopping
- Product browsing
- Shopping cart management
- Checkout process
- Order history

### ✅ Navigation
- Type-safe routing with AppRoute enum
- NavigationStack for stack-based navigation
- TabView for main navigation
- Deep linking support

### ✅ State Management
- MVVM architecture
- Environment objects for global state
- Reactive updates with @Published

### ✅ Data Models
- StoreProduct for simple listings
- Product for detailed views
- CartItemModel for cart
- PurchaseOrder for orders

## File Structure

```
SupplementStore/
├── App/
│   ├── SupplementStoreApp.swift    # @main entry point
│   └── ContentView.swift            # Compatibility wrapper
│
├── Views/
│   ├── Auth/                        # Login, Register
│   ├── Home/                        # HomeView
│   ├── Store/                       # StoreView, ProductDetailsView
│   ├── Equipments/                  # EquipmentsView, EquipmentsDetailsView
│   ├── Coaches/                     # CoachesView, CoachDetailsView, CoachesProfilesView
│   ├── Cart/                        # CartView
│   ├── Checkout/                    # CheckoutView
│   ├── MyPurchases/                 # MyPurchasesView
│   ├── AboutUs/                     # AboutUsView
│   └── NotFound/                     # NotFoundView
│
├── Components/
│   ├── Layout/                      # MainTabView, LayoutView, NavbarView, FooterView
│   └── Common/                      # ProductCard, SearchBar, etc.
│
├── ViewModels/                      # UserViewModel, CartViewModel, etc.
├── Models/                          # Product, Equipment, Coach, etc.
├── Services/                        # APIService, AuthService
├── Utilities/                       # NavigationCoordinator, ProtectedRoute
└── Extensions/                      # View extensions
```

## Usage

The app is ready to run. Simply:
1. Open in Xcode
2. Add images to Assets.xcassets with names matching the product image names
3. Build and run

All navigation, state management, and API calls are implemented and ready to use.

