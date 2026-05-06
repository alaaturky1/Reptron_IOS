import Foundation

// Minimal usage example (non-invasive, not wired into UI)
@MainActor
final class ProductsAPIExample {
    func loadProducts() async {
        do {
            let products = try await NetworkManager.shared.getProducts()
            print("Fetched products count: \(products.count)")
        } catch {
            print("Failed to fetch products: \(error.localizedDescription)")
        }
    }
}
