//
//  HomeView.swift
//  SupplementStore
//
//  Created on [Date]
//
import SwiftUI
import UIKit

// MARK: - Device Size Helper
// Local implementation of DeviceSize for HomeView
private enum DeviceSize {
    // Base values are for iPhone 12/13/14 (390x844 points)
    private static let baseScreenWidth: CGFloat = 390
    
    // Calculate a scaled value based on the current device width
    private static func scaleValue(_ value: CGFloat) -> CGFloat {
        let screenWidth = UIScreen.main.bounds.width
        return value * (screenWidth / baseScreenWidth)
    }
    
    // MARK: - Spacing
    static func spacing(base: CGFloat) -> CGFloat { scaleValue(base) }
    
    // MARK: - Padding
    static func padding(base: CGFloat) -> CGFloat { scaleValue(base) }
    
    // MARK: - Font Size
    static func fontSize(base: CGFloat) -> CGFloat { scaleValue(base) }
    
    // MARK: - Corner Radius
    static func cornerRadius(base: CGFloat) -> CGFloat { scaleValue(base) }

    static var isProMax: Bool {
        UIScreen.main.bounds.width >= 428
    }
}

struct HomeView: View {
    @EnvironmentObject var userViewModel: UserViewModel
    @EnvironmentObject var cartViewModel: CartViewModel
    @EnvironmentObject var navigationCoordinator: NavigationCoordinator
    @StateObject private var storeViewModel = StoreViewModel()
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @State private var searchTerm: String = ""
    @State private var selectedCategory: String = "all"
    @State private var activeTestimonial: Int = 0
    
    private let testimonials: [Testimonial] = []
    
    private let categories: [Category] = [
        Category(id: "all", name: "All Products", icon: "bolt.fill"),
        Category(id: "supplements", name: "Supplements", icon: "pills.fill"),
        Category(id: "equipment", name: "Equipment", icon: "dumbbell.fill")
    ]
    
    private let features: [Feature] = [
        Feature(id: 1, icon: "star.fill", title: "Premium Quality", description: "Lab-tested ingredients"),
        Feature(id: 2, icon: "trophy.fill", title: "Trusted by Athletes", description: "Used worldwide"),
        Feature(id: 3, icon: "shippingbox.fill", title: "Fast Shipping", description: "Free delivery over $50"),
        Feature(id: 4, icon: "shield.fill", title: "Money Back Guarantee", description: "30 days return")
    ]
    
    private let workoutPrograms: [WorkoutProgram] = []
    
    private let blogPosts: [BlogPost] = []
    
    private var filteredProducts: [HomeProduct] {
        storeViewModel.products.map {
            HomeProduct(
                id: $0.id,
                name: $0.name,
                category: $0.category,
                price: $0.price,
                rating: $0.rating ?? 0,
                image: $0.img ?? "",
                description: $0.description,
                onSale: $0.onSale,
                originalPrice: $0.oldPrice
            )
        }.filter { product in
            let matchSearch = searchTerm.isEmpty || 
                product.name.localizedCaseInsensitiveContains(searchTerm) ||
                product.description.localizedCaseInsensitiveContains(searchTerm)
            let matchCategory = selectedCategory == "all" || product.category == selectedCategory
            return matchSearch && matchCategory
        }
    }
    
    var body: some View {
        ZStack {
            // Glow Effect
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color.cyan.opacity(0.3), Color.clear],
                        center: .center,
                        startRadius: 0,
                        endRadius: 150
                    )
                )
                .frame(width: 300, height: 300)
                .blur(radius: 60)
                .offset(x: 0, y: 0)
            
            ScrollView {
                VStack(spacing: 0) {
                    // Hero Section
                    heroSection
                        .padding(.horizontal, DeviceSize.padding(base: 16))
                        .padding(.top, DeviceSize.padding(base: 32))
                        .padding(.bottom, DeviceSize.padding(base: 48))
                    
                    // Features Section
                    featuresSection
                        .padding(.horizontal, DeviceSize.padding(base: 16))
                        .padding(.bottom, DeviceSize.padding(base: 64))
                    
                    // Products Section
                    productsSection
                        .padding(.horizontal, DeviceSize.padding(base: 16))
                        .padding(.bottom, DeviceSize.padding(base: 64))
                    
                    // Workout Programs Section
                    workoutSection
                        .padding(.horizontal, DeviceSize.padding(base: 16))
                        .padding(.bottom, DeviceSize.padding(base: 64))
                    
                    // Blog Section
                    blogSection
                        .padding(.horizontal, DeviceSize.padding(base: 16))
                        .padding(.bottom, DeviceSize.padding(base: 64))
                    
                    // Testimonial Section
                    testimonialSection
                        .padding(.horizontal, DeviceSize.padding(base: 16))
                        .padding(.bottom, DeviceSize.padding(base: 64))

                    PageFooterView()
                }
            }
        }
        .appScreenBackground()
        .onAppear {
            startTestimonialTimer()
        }
    }
    
    // MARK: - Hero Section
    private var heroSection: some View {
        VStack(spacing: DeviceSize.spacing(base: 24)) {
            // Title
            VStack(spacing: DeviceSize.spacing(base: 8)) {
                (Text("LEVEL UP YOUR ")
                    .font(.system(size: DeviceSize.fontSize(base: 56), weight: .heavy))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.white, Color(red: 203/255, green: 213/255, blue: 225/255)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                 + Text("FITNESS")
                    .font(.system(size: DeviceSize.fontSize(base: 56), weight: .heavy))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.cyan, Color(red: 0, green: 188/255, blue: 212/255)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    ))
                
                Text("Premium supplements, elite equipment, and expert workout programs.")
                    .font(.system(size: DeviceSize.fontSize(base: 20)))
                    .foregroundColor(Color(red: 203/255, green: 213/255, blue: 225/255))
                    .opacity(0.9)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, DeviceSize.padding(base: 16))
            }
            
            // Search Bar
            SearchBar(searchTerm: $searchTerm, placeholder: "Search products...")
                .padding(.horizontal, DeviceSize.padding(base: 16))
            
            // Category Buttons
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: DeviceSize.spacing(base: 16)) {
                    ForEach(categories) { category in
                        CategoryButton(
                            id: category.id,
                            name: category.name,
                            icon: category.icon,
                            isSelected: selectedCategory == category.id
                        ) {
                            selectedCategory = category.id
                        }
                    }
                }
                .padding(.horizontal, DeviceSize.padding(base: 16))
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, DeviceSize.padding(base: 64))
        .padding(.horizontal, DeviceSize.padding(base: 16))
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color(red: 15/255, green: 23/255, blue: 42/255).opacity(0.3))
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color.cyan.opacity(0.2), lineWidth: 1)
                )
        )
        .overlay(
            VStack {
                LinearGradient(
                    colors: [Color.cyan, Color(red: 0, green: 188/255, blue: 212/255), Color(red: 0, green: 151/255, blue: 167/255)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .frame(height: 4)
                Spacer()
            }
            .cornerRadius(24, corners: [.topLeft, .topRight])
        )
    }
    
    // MARK: - Features Section
    private var featuresSection: some View {
        VStack(spacing: DeviceSize.spacing(base: 32)) {
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: DeviceSize.spacing(base: 16)),
                GridItem(.flexible(), spacing: DeviceSize.spacing(base: 16))
            ], spacing: DeviceSize.spacing(base: 16)) {
                ForEach(features) { feature in
                    FeatureCard(
                        icon: feature.icon,
                        title: feature.title,
                        description: feature.description
                    )
                }
            }
        }
    }
    
    // MARK: - Products Section
    private var productGridColumns: [GridItem] {
        let spacing = DeviceSize.spacing(base: 16)
        if horizontalSizeClass == .compact {
            return [GridItem(.flexible(), spacing: spacing)]
        } else {
            return [
                GridItem(.flexible(), spacing: spacing),
                GridItem(.flexible(), spacing: spacing)
            ]
        }
    }
    
    private var productsSection: some View {
        VStack(spacing: DeviceSize.spacing(base: 32)) {
            // Section Title
            HStack {
                
                Text("Best Sellers")
                    .font(.system(size: DeviceSize.fontSize(base: 32), weight: .heavy))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.cyan, Color(red: 0, green: 188/255, blue: 212/255)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
            }
            
            // Products Grid
            LazyVGrid(columns: productGridColumns, spacing: DeviceSize.spacing(base: 16)) {
                ForEach(filteredProducts) { product in
                    ProductCard(product: ProductCardStoreProduct(from: product)) {
                        handleProductTap(product)
                    }
                }
            }
        }
    }
    
    // MARK: - Workout Section
    private var workoutSection: some View {
        VStack(spacing: DeviceSize.spacing(base: 32)) {
            // Section Title
            HStack {
                Text("🏋️")
                    .font(.system(size: DeviceSize.fontSize(base: 32)))
                Text("Elite Workout Programs")
                    .font(.system(size: DeviceSize.fontSize(base: 32), weight: .heavy))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.cyan, Color(red: 0, green: 188/255, blue: 212/255)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
            }
            
            // Workout Cards
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: DeviceSize.spacing(base: 16)) {
                    ForEach(workoutPrograms) { program in
                        Button(action: {
                            navigationCoordinator.navigate(to: .workoutProgram(id: program.id))
                        }) {
                            WorkoutCard(
                                image: program.image,
                                title: program.title,
                                description: program.description
                            )
                            .frame(width: DeviceSize.isProMax ? 320 : 300)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, DeviceSize.padding(base: 16))
            }
        }
    }
    
    // MARK: - Blog Section
    private var blogSection: some View {
        VStack(spacing: DeviceSize.spacing(base: 32)) {
            // Section Title
            HStack {
                Text("📝")
                    .font(.system(size: DeviceSize.fontSize(base: 32)))
                Text("Latest Articles")
                    .font(.system(size: DeviceSize.fontSize(base: 32), weight: .heavy))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.cyan, Color(red: 0, green: 188/255, blue: 212/255)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
            }
            
            // Blog Cards
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: DeviceSize.spacing(base: 16)) {
                    ForEach(blogPosts) { post in
                        BlogCard(
                            image: post.image,
                            title: post.title,
                            date: post.date
                        ) {
                            handleBlogTap(post)
                        }
                        .frame(width: DeviceSize.isProMax ? 320 : 300)
                    }
                }
                .padding(.horizontal, DeviceSize.padding(base: 16))
            }
        }
    }
    
    // MARK: - Testimonial Section
    private var testimonialSection: some View {
        VStack(spacing: 0) {
            if testimonials.isEmpty {
                EmptyView()
            } else {
                TestimonialCard(testimonial: testimonials[activeTestimonial])
            }
        }
    }
    
    // MARK: - Helper Functions
    private func handleProductTap(_ product: HomeProduct) {
        if !userViewModel.isLoggedIn {
            navigationCoordinator.navigate(to: .login)
            return
        }
        // Navigate to product details
        navigationCoordinator.navigate(to: .productDetails(id: product.id))
    }
    
    private func handleBlogTap(_ post: BlogPost) {
        // Blog card tapped - could navigate to blog detail page or show content
        // For now, we'll just provide visual feedback (handled by BlogCard button)
        // TODO: Add blog detail route if needed
    }
    
    private func startTestimonialTimer() {
        guard !testimonials.isEmpty else { return }
        Timer.scheduledTimer(withTimeInterval: 4.0, repeats: true) { _ in
            withAnimation(.easeInOut(duration: 0.5)) {
                activeTestimonial = (activeTestimonial + 1) % testimonials.count
            }
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(UserViewModel())
        .environmentObject(CartViewModel())
}
