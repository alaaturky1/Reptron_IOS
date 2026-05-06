# SwiftUI iOS App - Complete Structure

## Overview
This document outlines the complete structure of the SwiftUI iOS app converted from the React + Vite web application.

## Architecture Mapping

### React → SwiftUI Conversion

| React Component | SwiftUI Equivalent | Location |
|----------------|-------------------|----------|
| `App.jsx` | `SupplementStoreApp.swift` | `App/` |
| `Layout.jsx` | `MainTabView.swift` | `Components/Layout/` |
| `Navbar.jsx` | `NavbarView.swift` | `Components/Layout/` |
| `Footer.jsx` | `FooterView.swift` | `Components/Layout/` |
| Context API | `@EnvironmentObject` ViewModels | `ViewModels/` |
| React Router | `NavigationStack` | Throughout `Views/` |
| `ProtectedRoute` | `ProtectedRoute.swift` | `Utilities/` |
| Axios | `URLSession` + `APIService` | `Services/API/` |

## Complete Folder Structure

```
ios-app/
│
├── SupplementStore/                          # Main Application
│   │
│   ├── App/                                  # Application Entry Point
│   │   ├── SupplementStoreApp.swift          # @main app struct with environment objects
│   │   └── ContentView.swift                 # Root view with navigation logic
│   │
│   ├── Views/                                # All Screen Views
│   │   │
│   │   ├── Auth/                             # Authentication Screens
│   │   │   ├── LoginView.swift               # User login (email/password)
│   │   │   └── RegisterView.swift            # User registration (name/email/password/phone)
│   │   │
│   │   ├── Home/                             # Home Screen
│   │   │   └── HomeView.swift                # Landing page with:
│   │   │                                      # - Hero section with search
│   │   │                                      # - Category filters
│   │   │                                      # - Featured products
│   │   │                                      # - Workout programs
│   │   │                                      # - Blog posts
│   │   │                                      # - Testimonials carousel
│   │   │
│   │   ├── Store/                            # Supplements Store
│   │   │   ├── StoreView.swift               # Product listing (12 supplements)
│   │   │   └── ProductDetailsView.swift      # Product details with:
│   │   │                                      # - Image gallery
│   │   │                                      # - Price & sale badge
│   │   │                                      # - Quantity selector
│   │   │                                      # - Tabs (Description/Additional/Reviews)
│   │   │                                      # - Add to cart
│   │   │                                      # - Related products
│   │   │
│   │   ├── Equipments/                       # Gym Equipment
│   │   │   ├── EquipmentsView.swift          # Equipment listing with filters:
│   │   │   │                                  # - All/Chest/Back/Shoulder/Leg
│   │   │   └── EquipmentsDetailsView.swift   # Equipment details with:
│   │   │                                      # - Image & specialty badge
│   │   │                                      # - Price & description
│   │   │                                      # - Tabs (Description/Additional/Reviews)
│   │   │                                      # - Add to cart
│   │   │                                      # - Related equipments
│   │   │
│   │   ├── Coaches/                          # Fitness Coaches
│   │   │   ├── CoachesView.swift             # Coach listing with specialty filters:
│   │   │   │                                  # - All/Bodybuilding/Fitness/Nutrition/etc.
│   │   │   ├── CoachDetailsView.swift        # Coach booking page with:
│   │   │   │                                  # - Profile & bio
│   │   │   │                                  # - Contact info
│   │   │   │                                  # - Availability schedule
│   │   │   │                                  # - Date/time picker
│   │   │   │                                  # - Booking confirmation
│   │   │   └── CoachesProfilesView.swift     # Detailed coach profile with:
│   │   │                                      # - Stats (experience/clients/certs)
│   │   │                                      # - Full bio
│   │   │                                      # - Contact information
│   │   │
│   │   ├── Cart/                             # Shopping Cart
│   │   │   └── CartView.swift                # Cart management with:
│   │   │                                      # - Item list
│   │   │                                      # - Quantity controls (+/-)
│   │   │                                      # - Remove items
│   │   │                                      # - Order summary
│   │   │                                      # - Clear cart
│   │   │                                      # - Proceed to checkout
│   │   │
│   │   ├── Checkout/                         # Checkout Process
│   │   │   └── CheckoutView.swift            # Checkout form with:
│   │   │                                      # - Cart review
│   │   │                                      # - Billing information
│   │   │                                      # - Payment details (card)
│   │   │                                      # - Form validation
│   │   │                                      # - Order placement
│   │   │
│   │   ├── MyPurchases/                      # Order History
│   │   │   └── MyPurchasesView.swift         # Purchase history with:
│   │   │                                      # - Order list
│   │   │                                      # - Order details
│   │   │                                      # - Shipping information
│   │   │                                      # - Item breakdown
│   │   │
│   │   ├── AboutUs/                          # About Page
│   │   │   └── AboutUsView.swift             # Company information:
│   │   │                                      # - Story
│   │   │                                      # - Mission & Vision
│   │   │                                      # - Core values
│   │   │                                      # - Team members
│   │   │                                      # - Contact info
│   │   │
│   │   └── NotFound/                         # Error Handling
│   │       └── NotFoundView.swift            # 404 error page
│   │
│   ├── Components/                           # Reusable UI Components
│   │   │
│   │   ├── Layout/                           # Layout Components
│   │   │   ├── MainTabView.swift             # Tab-based navigation:
│   │   │   │                                  # - Home tab
│   │   │   │                                  # - Store tab
│   │   │   │                                  # - Equipments tab
│   │   │   │                                  # - Coaches tab
│   │   │   │                                  # - Cart tab
│   │   │   ├── NavbarView.swift              # Navigation bar with:
│   │   │   │                                  # - Logo/brand
│   │   │   │                                  # - Menu items (conditional on login)
│   │   │   │                                  # - Cart icon with badge
│   │   │   │                                  # - User actions (login/logout)
│   │   │   └── FooterView.swift               # Footer with:
│   │   │                                      # - Quick links
│   │   │                                      # - Categories
│   │   │                                      # - Newsletter signup
│   │   │
│   │   └── Common/                           # Common Components
│   │       └── ScrollToTopButton.swift       # Floating scroll-to-top button
│   │
│   ├── ViewModels/                           # State Management (MVVM)
│   │   │
│   │   ├── UserViewModel.swift               # Authentication state:
│   │   │                                      # - isLoggedIn
│   │   │                                      # - userToken
│   │   │                                      # - login() / register() / logout()
│   │   │                                      # - Token persistence (UserDefaults)
│   │   │
│   │   ├── CartViewModel.swift               # Shopping cart state:
│   │   │                                      # - cartItems array
│   │   │                                      # - addToCart() / removeFromCart()
│   │   │                                      # - increaseQuantity() / decreaseQuantity()
│   │   │                                      # - clearCart()
│   │   │                                      # - Computed: totalItems, grandTotal
│   │   │
│   │   ├── PurchaseViewModel.swift           # Purchase history:
│   │   │                                      # - purchases array
│   │   │                                      # - addPurchase()
│   │   │                                      # - Persistence (UserDefaults)
│   │   │
│   │   ├── StoreViewModel.swift              # Store/Products state:
│   │   │                                      # - products array
│   │   │                                      # - isLoading / errorMessage
│   │   │
│   │   ├── EquipmentsViewModel.swift         # Equipment state:
│   │   │                                      # - equipments array
│   │   │                                      # - Filtering logic
│   │   │
│   │   └── CoachesViewModel.swift            # Coaches state:
│   │                                        # - coaches array
│   │                                        # - Filtering by specialty
│   │
│   ├── Models/                               # Data Models
│   │   │
│   │   ├── Product.swift                    # Supplement product model:
│   │   │                                      # - id, name, category
│   │   │                                      # - price, oldPrice, onSale
│   │   │                                      # - image, description
│   │   │                                      # - additionalInfo, reviews, rating
│   │   │
│   │   ├── Equipment.swift                  # Gym equipment model:
│   │   │                                      # - id, name, specialty
│   │   │                                      # - price, salePrice
│   │   │                                      # - image, description, bio
│   │   │                                      # - additionalInfo, reviews
│   │   │
│   │   ├── Coach.swift                      # Coach model:
│   │   │                                      # - id, name, specialty, title
│   │   │                                      # - bio, fullBio
│   │   │                                      # - experience, clients, certifications
│   │   │                                      # - image, phone, email
│   │   │                                      # - hourlyRate, availability
│   │   │
│   │   ├── CartItem.swift                   # Cart item model:
│   │   │                                      # - product (Product)
│   │   │                                      # - quantity (Int)
│   │   │
│   │   ├── Purchase.swift                    # Purchase/Order model:
│   │   │                                      # - id, date
│   │   │                                      # - items (CartItem array)
│   │   │                                      # - total
│   │   │                                      # - shippingAddress
│   │   │
│   │   └── BillingInfo.swift                # Checkout forms:
│   │                                        # - BillingInfo struct
│   │                                        # - PaymentInfo struct
│   │
│   ├── Services/                             # Business Logic & API
│   │   │
│   │   ├── API/                              # API Service
│   │   │   └── APIService.swift              # Generic API client:
│   │   │                                      # - Base URL configuration
│   │   │                                      # - Request builder
│   │   │                                      # - Token injection
│   │   │                                      # - Generic request<T>() method
│   │   │
│   │   └── Auth/                             # Authentication Service
│   │       └── AuthService.swift             # Auth endpoints:
│   │                                        # - signIn(email, password)
│   │                                        # - signUp(name, email, password, phone)
│   │                                        # - Returns AuthResponse (token)
│   │
│   ├── Utilities/                            # Helper Utilities
│   │   └── ProtectedRoute.swift             # Route protection:
│   │                                        # - Checks isLoggedIn
│   │                                        # - Redirects to LoginView if not authenticated
│   │
│   ├── Extensions/                           # Swift Extensions
│   │   └── View+Extensions.swift             # View utilities:
│   │                                        # - hideKeyboard() helper
│   │
│   ├── Resources/                            # Assets & Resources
│   │   │
│   │   ├── Assets/                           # Asset Catalog
│   │   │   └── Assets.xcassets/             # Image assets, colors, etc.
│   │   │
│   │   ├── Images/                          # Image files (if needed)
│   │   │
│   │   └── Fonts/                           # Custom fonts (if needed)
│   │
│   └── Info.plist                           # App Configuration
│
├── SupplementStore.xcodeproj/               # Xcode Project
│   ├── project.xcworkspace/                 # Workspace settings
│   └── xcshareddata/
│       └── xcschemes/                       # Build schemes
│
├── SupplementStoreTests/                    # Unit Tests
│   └── SupplementStoreTests.swift
│
├── SupplementStoreUITests/                   # UI Tests
│   └── SupplementStoreUITests.swift
│
└── README.md                                # Project documentation

```

## Key Features Implementation

### 1. Authentication Flow
- **Login**: Email/password validation → API call → Token storage
- **Register**: Form validation (name, email, password, phone) → API call → Auto-login
- **Logout**: Clear token → Reset state → Navigate to home
- **Protected Routes**: Check authentication before showing protected views

### 2. Shopping Flow
- **Browse**: Store (supplements) & Equipments with filters
- **Details**: Product/Equipment detail pages with tabs
- **Cart**: Add/remove items, quantity management
- **Checkout**: Billing + Payment forms → Order creation
- **History**: View past purchases with details

### 3. Coaches Flow
- **Browse**: Filter by specialty
- **Profile**: View detailed coach information
- **Booking**: Select date/time → Confirm session

### 4. State Management
- **UserViewModel**: Authentication state (ObservableObject)
- **CartViewModel**: Shopping cart state (ObservableObject)
- **PurchaseViewModel**: Order history (ObservableObject)
- **Environment Objects**: Injected at app level, accessible throughout

### 5. API Integration
- **Base URL**: `http://power-fuelgym00.runasp.net`
- **Endpoints**:
  - `POST /auth/signin` - Login
  - `POST /auth/signup` - Registration
- **Token Management**: Stored in UserDefaults, injected in API headers

### 6. Data Persistence
- **UserDefaults**: Token, purchase history
- **In-Memory**: Cart items (can be persisted if needed)

## Navigation Structure

```
ContentView
├── (Not Logged In)
│   └── HomeView (public)
│       ├── LoginView
│       └── RegisterView
│
└── (Logged In)
    └── MainTabView
        ├── Home Tab
        ├── Store Tab
        │   └── ProductDetailsView
        ├── Equipments Tab
        │   └── EquipmentsDetailsView
        ├── Coaches Tab
        │   ├── CoachDetailsView
        │   └── CoachesProfilesView
        └── Cart Tab
            └── CheckoutView
                └── MyPurchasesView
```

## UI/UX Patterns

1. **Tab Navigation**: Main app navigation via TabView
2. **Stack Navigation**: Detail views via NavigationStack
3. **Modal Presentation**: Login/Register as sheets/modals
4. **State-Driven UI**: Views react to ViewModel state changes
5. **Loading States**: isLoading flags for async operations
6. **Error Handling**: errorMessage properties for user feedback
7. **Form Validation**: Client-side validation before API calls

## Next Steps

1. **Implement UI**: Complete all view implementations with SwiftUI
2. **Add Images**: Import product/equipment/coach images to Assets
3. **Styling**: Apply design system (colors, fonts, spacing)
4. **Animations**: Add transitions and animations
5. **Error Handling**: Comprehensive error handling and user feedback
6. **Testing**: Unit tests for ViewModels, UI tests for flows
7. **Performance**: Optimize image loading, caching
8. **Accessibility**: Add accessibility labels and support

