# Navigation Structure

This document describes the navigation structure that matches the React Router setup from the original React app.

## Navigation Architecture

The app uses SwiftUI's `NavigationStack` with a custom routing system that mirrors the React Router structure.

## Route Structure

### Public Routes (No Authentication Required)
- `/` (index) → `HomeView` - Home page
- `/login` → `LoginView` - User login
- `/register` → `RegisterView` - User registration

### Protected Routes (Authentication Required)
- `/aboutUs` → `AboutUsView` - About us page
- `/coaches` → `CoachesView` - Coaches listing
- `/coach/:id` → `CoachDetailsView` - Coach booking page
- `/coachesProfiles/:id` → `CoachesProfilesView` - Coach profile page
- `/equipments` → `EquipmentsView` - Equipment listing
- `/equipments/:id` → `EquipmentsDetailsView` - Equipment details
- `/store` → `StoreView` - Store/supplements listing
- `/product/:id` → `ProductDetailsView` - Product details
- `/cart` → `CartView` - Shopping cart
- `/checkout` → `CheckoutView` - Checkout page
- `/mypurchases` → `MyPurchasesView` - Purchase history

### Error Route
- `*` (catch-all) → `NotFoundView` - 404 error page

## Navigation Components

### NavigationRouter
Main navigation coordinator that handles all routing. Located at the root level and manages the NavigationStack.

### NavigationCoordinator
ObservableObject that manages the navigation path and provides helper methods for navigation.

### AppRoute
Enum defining all possible routes in the app, matching the React Router paths.

### ProtectedRoute
View wrapper that checks authentication status and redirects to login if not authenticated (matches React ProtectedRoute behavior).

### LayoutView
Wrapper component that provides Navbar and Footer to all views (matches React Layout component).

## Usage Examples

### Navigate to a route
```swift
@EnvironmentObject var navigationCoordinator: NavigationCoordinator

// Navigate to store
NavigationHelper.navigateToStore(coordinator: navigationCoordinator)

// Navigate to product details
NavigationHelper.navigateToProduct(coordinator: navigationCoordinator, productId: 123)

// Navigate to login
NavigationHelper.navigateToLogin(coordinator: navigationCoordinator)
```

### Using NavigationLink
```swift
NavigationLink(value: AppRoute.productDetails(id: product.id)) {
    ProductCard(product: product, onTap: {})
}
```

### Programmatic Navigation
```swift
// In a button action
Button("Go to Store") {
    navigationCoordinator.navigate(to: .store)
}
```

## Navigation Flow

1. **App Launch**: Shows `HomeView` if not logged in, or `MainTabView` if logged in
2. **Login Flow**: User can navigate to `/login` or `/register` from any public view
3. **Protected Access**: After login, user can access all protected routes
4. **Tab Navigation**: When logged in, main navigation uses `MainTabView` with tabs
5. **Deep Linking**: All routes support deep linking via `NavigationStack` path

## Layout Structure

All views (except login/register) are wrapped in `LayoutView` which provides:
- `NavbarView` - Navigation bar (shown when logged in)
- Main content area
- `FooterView` - Footer with links and newsletter

This matches the React `Layout` component structure.

## State Management

Navigation state is managed by:
- `NavigationCoordinator` - Navigation path and routing
- `UserViewModel` - Authentication state (affects which routes are accessible)
- `CartViewModel` - Shopping cart state
- `PurchaseViewModel` - Purchase history state

## Differences from React Router

1. **Single NavigationStack**: SwiftUI uses one NavigationStack at the root, not nested routers
2. **Type Safety**: Routes are defined as an enum (`AppRoute`) for type safety
3. **Programmatic Navigation**: Uses `NavigationCoordinator` instead of `useNavigate` hook
4. **Tab Navigation**: Uses SwiftUI's `TabView` for main navigation when logged in

