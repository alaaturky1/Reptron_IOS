# Supplement Store iOS App


## Project Structure

```
ios-app/
├── SupplementStore/                    # Main app folder
│   ├── App/                            # App entry point
│   │   ├── SupplementStoreApp.swift    # Main app struct
│   │   └── ContentView.swift           # Root content view
│   │
│   ├── Views/                          # All view screens
│   │   ├── Auth/
│   │   │   ├── LoginView.swift
│   │   │   └── RegisterView.swift
│   │   ├── Home/
│   │   │   └── HomeView.swift
│   │   ├── Store/
│   │   │   ├── StoreView.swift
│   │   │   └── ProductDetailsView.swift
│   │   ├── Equipments/
│   │   │   ├── EquipmentsView.swift
│   │   │   └── EquipmentsDetailsView.swift
│   │   ├── Coaches/
│   │   │   ├── CoachesView.swift
│   │   │   ├── CoachDetailsView.swift
│   │   │   └── CoachesProfilesView.swift
│   │   ├── Cart/
│   │   │   └── CartView.swift
│   │   ├── Checkout/
│   │   │   └── CheckoutView.swift
│   │   ├── MyPurchases/
│   │   │   └── MyPurchasesView.swift
│   │   ├── AboutUs/
│   │   │   └── AboutUsView.swift
│   │   └── NotFound/
│   │       └── NotFoundView.swift
│   │
│   ├── Components/                     # Reusable UI components
│   │   ├── Layout/
│   │   │   ├── MainTabView.swift
│   │   │   ├── NavbarView.swift
│   │   │   └── FooterView.swift
│   │   └── Common/
│   │       └── ScrollToTopButton.swift
│   │
│   ├── ViewModels/                     # State management
│   │   ├── UserViewModel.swift
│   │   ├── CartViewModel.swift
│   │   ├── PurchaseViewModel.swift
│   │   ├── StoreViewModel.swift
│   │   ├── EquipmentsViewModel.swift
│   │   └── CoachesViewModel.swift
│   │
│   ├── Models/                         # Data models
│   │   ├── Product.swift
│   │   ├── Equipment.swift
│   │   ├── Coach.swift
│   │   ├── CartItem.swift
│   │   ├── Purchase.swift
│   │   └── BillingInfo.swift
│   │
│   ├── Services/                       # API and business logic
│   │   ├── API/
│   │   │   └── APIService.swift
│   │   └── Auth/
│   │       └── AuthService.swift
│   │
│   ├── Utilities/                      # Helper utilities
│   │   └── ProtectedRoute.swift
│   │
│   ├── Extensions/                     # Swift extensions
│   │   └── View+Extensions.swift
│   │
│   ├── Resources/                      # Assets and resources
│   │   ├── Assets/
│   │   │   └── Assets.xcassets/
│   │   ├── Images/
│   │   └── Fonts/
│   │
│   └── Info.plist                      # App configuration
│
├── SupplementStore.xcodeproj/         # Xcode project files
│   ├── project.xcworkspace/
│   └── xcshareddata/
│       └── xcschemes/
│
├── SupplementStoreTests/              # Unit tests
│   └── SupplementStoreTests.swift
│
└── SupplementStoreUITests/            # UI tests
    └── SupplementStoreUITests.swift
```

## Features

### Authentication
- User login with email/password
- User registration with validation
- Token-based authentication
- Persistent login state

### Shopping
- Product browsing (Supplements)
- Equipment browsing
- Product/Equipment details with reviews
- Shopping cart management
- Checkout process
- Order history

### Coaches
- Coach listings with filters
- Coach profiles
- Session booking

### UI/UX
- Modern SwiftUI design
- Tab-based navigation
- Protected routes
- Responsive layouts

## API Integration

- **Base URL**: `http://power-fuelgym00.runasp.net`
- **Authentication Endpoints**:
  - POST `/auth/signin` - User login
  - POST `/auth/signup` - User registration

## State Management

The app uses SwiftUI's `@StateObject` and `@EnvironmentObject` for state management:
- `UserViewModel` - Authentication state
- `CartViewModel` - Shopping cart state
- `PurchaseViewModel` - Purchase history

## Requirements

- iOS 15.0+
- Xcode 14.0+
- Swift 5.7+

## Setup Instructions

1. Open `SupplementStore.xcodeproj` in Xcode
2. Configure your bundle identifier
3. Add your API keys if needed
4. Build and run

## Notes

- This is a skeleton structure. Each view file contains placeholder implementations.
- Images and assets need to be added to `Resources/Assets/Assets.xcassets`
- API endpoints may need additional configuration
- Local data storage uses `UserDefaults` for simplicity

