import PhotosUI
import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var userViewModel: UserViewModel
    @EnvironmentObject var navigationCoordinator: NavigationCoordinator
    @EnvironmentObject var purchaseViewModel: PurchaseViewModel
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var profileImage: Image?
    @AppStorage("profile_image_data") private var profileImageData: Data = Data()
    @AppStorage("profile_name") private var profileName: String = "Gym Athlete"
    @AppStorage("profile_email") private var profileEmail: String = ""
    @State private var isEditingProfile = false

    var body: some View {
        ScrollView {
            VStack(spacing: DeviceSize.spacing(base: 18)) {
                profileHeader
                userInfoSection
                ordersSection
                paymentsSection
                actionButtons
            }
            .padding(.horizontal, DeviceSize.padding(base: 16))
            .padding(.top, DeviceSize.padding(base: 10))
            .padding(.bottom, DeviceSize.padding(base: 20))
        }
        .appScreenBackground()
        .task {
            if profileImage == nil, let image = UIImage(data: profileImageData) {
                profileImage = Image(uiImage: image)
            }
        }
        .onChange(of: selectedPhoto) { newItem in
            guard let newItem else { return }
            Task {
                if let data = try? await newItem.loadTransferable(type: Data.self),
                   let uiImage = UIImage(data: data) {
                    await MainActor.run {
                        profileImageData = data
                        profileImage = Image(uiImage: uiImage)
                    }
                }
            }
        }
    }

    private var profileHeader: some View {
        VStack(alignment: .leading, spacing: DeviceSize.spacing(base: 12)) {
            HStack {
                Text("Profile")
                    .appSectionTitle()
                Spacer()
                Text(userViewModel.isLoggedIn ? "ACTIVE" : "GUEST")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(userViewModel.isLoggedIn ? .green : .orange)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(AppTheme.cardOverlay.opacity(0.8), in: Capsule())
            }

            Text("Manage your account, orders, and payments in one place.")
                .font(.system(size: DeviceSize.fontSize(base: 14), weight: .medium))
                .foregroundColor(AppTheme.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(DeviceSize.padding(base: 16))
        .appCardStyle()
    }

    private var userInfoSection: some View {
        VStack(alignment: .leading, spacing: DeviceSize.spacing(base: 14)) {
            sectionTitle("User Info", systemImage: "person.crop.circle.fill")

            HStack(spacing: DeviceSize.spacing(base: 14)) {
                profileAvatar

                VStack(alignment: .leading, spacing: DeviceSize.spacing(base: 8)) {
                    profileInputRow(title: "Name", value: $profileName, editable: isEditingProfile)

                    profileInputRow(title: "Email", value: $profileEmail, editable: isEditingProfile, keyboardType: .emailAddress)

                    Text(userViewModel.isLoggedIn ? "Logged In" : "Guest")
                        .font(.system(size: DeviceSize.fontSize(base: 12), weight: .medium))
                        .foregroundColor(AppTheme.cyan.opacity(0.9))
                }
            }

            Button(action: { isEditingProfile.toggle() }) {
                Label(isEditingProfile ? "Done Editing" : "Edit Profile", systemImage: isEditingProfile ? "checkmark.circle.fill" : "pencil.circle.fill")
            }
            .buttonStyle(SecondaryGlassButtonStyle())
        }
        .padding(DeviceSize.padding(base: 16))
        .appCardStyle()
    }

    private var profileAvatar: some View {
        ZStack(alignment: .bottomTrailing) {
            Group {
                if let profileImage {
                    profileImage
                        .resizable()
                        .scaledToFill()
                } else {
                    Circle()
                        .fill(AppTheme.cardOverlay)
                        .overlay(
                            Image(systemName: "person.crop.circle.fill")
                                .font(.system(size: 42))
                                .foregroundColor(AppTheme.cyan.opacity(0.85))
                        )
                }
            }
            .frame(width: 92, height: 92)
            .clipShape(Circle())
            .overlay(Circle().stroke(AppTheme.cyan.opacity(0.45), lineWidth: 2))

            PhotosPicker(selection: $selectedPhoto, matching: .images) {
                Image(systemName: "camera.fill")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(AppTheme.bgBottom)
                    .padding(8)
                    .background(AppTheme.primaryGradient, in: Circle())
            }
        }
    }

    private var ordersSection: some View {
        VStack(alignment: .leading, spacing: DeviceSize.spacing(base: 12)) {
            sectionTitle("Orders", systemImage: "shippingbox.fill")

            if purchaseViewModel.purchasesReversed.isEmpty {
                sectionEmptyState("No orders yet")
            } else {
                ForEach(purchaseViewModel.purchasesReversed.prefix(5)) { order in
                    VStack(alignment: .leading, spacing: DeviceSize.spacing(base: 8)) {
                        ForEach(order.items.prefix(3)) { item in
                            HStack(spacing: DeviceSize.spacing(base: 8)) {
                                Text(item.name)
                                    .font(.system(size: DeviceSize.fontSize(base: 14), weight: .semibold))
                                    .foregroundColor(AppTheme.textPrimary)
                                    .lineLimit(1)
                                Spacer()
                                Text("$\(item.price, specifier: "%.2f")")
                                    .font(.system(size: DeviceSize.fontSize(base: 14), weight: .bold))
                                    .foregroundColor(AppTheme.cyan)
                                Text(orderStatus(for: order))
                                    .font(.system(size: DeviceSize.fontSize(base: 11), weight: .bold))
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 5)
                                    .background(statusColor(for: order).opacity(0.2), in: Capsule())
                                    .foregroundColor(statusColor(for: order))
                            }
                        }

                        HStack {
                            Text("Order #\(order.id)")
                                .font(.system(size: DeviceSize.fontSize(base: 12), weight: .medium))
                                .foregroundColor(AppTheme.textSecondary)
                            Spacer()
                            Text(order.date)
                                .font(.system(size: DeviceSize.fontSize(base: 11), weight: .regular))
                                .foregroundColor(AppTheme.textSecondary.opacity(0.85))
                        }
                    }
                    .padding(DeviceSize.padding(base: 12))
                    .appCardStyle(cornerRadius: 12)
                }
            }
        }
        .padding(DeviceSize.padding(base: 16))
        .appCardStyle()
    }

    private var paymentsSection: some View {
        VStack(alignment: .leading, spacing: DeviceSize.spacing(base: 12)) {
            sectionTitle("Payments", systemImage: "creditcard.fill")

            if purchaseViewModel.purchasesReversed.isEmpty {
                sectionEmptyState("No completed payments")
            } else {
                ForEach(purchaseViewModel.purchasesReversed.prefix(5)) { order in
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("$\(order.total, specifier: "%.2f")")
                                .font(.system(size: DeviceSize.fontSize(base: 17), weight: .bold))
                                .foregroundColor(AppTheme.cyan)
                            Text(order.date)
                                .font(.system(size: DeviceSize.fontSize(base: 12)))
                                .foregroundColor(AppTheme.textSecondary)
                        }
                        Spacer()
                        Text(paymentMethod(for: order))
                            .font(.system(size: DeviceSize.fontSize(base: 12), weight: .semibold))
                            .foregroundColor(AppTheme.textPrimary)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(AppTheme.cardOverlay.opacity(0.75), in: Capsule())
                    }
                    .padding(DeviceSize.padding(base: 12))
                    .appCardStyle(cornerRadius: 12)
                }
            }
        }
        .padding(DeviceSize.padding(base: 16))
        .appCardStyle()
    }

    private var actionButtons: some View {
        VStack(spacing: DeviceSize.spacing(base: 12)) {
            if userViewModel.isLoggedIn {
                Button(action: {
                    navigationCoordinator.navigate(to: .myPurchases)
                }) {
                    Label("View Full Purchase History", systemImage: "clock.arrow.trianglehead.counterclockwise.rotate.90")
                }
                .buttonStyle(PrimaryGlowButtonStyle())

                Button(action: {
                    userViewModel.logout()
                    navigationCoordinator.navigateToRoot()
                }) {
                    Label("Logout", systemImage: "arrow.right.square.fill")
                }
                .buttonStyle(SecondaryGlassButtonStyle())
            } else {
                Button(action: { navigationCoordinator.navigate(to: .login) }) {
                    Text("Go to Login")
                }
                .buttonStyle(PrimaryGlowButtonStyle())
            }

            PageFooterView()
                .padding(.top, DeviceSize.padding(base: 8))
        }
    }

    private func orderStatus(for order: PurchaseOrder) -> String {
        order.id % 2 == 0 ? "Delivered" : "Pending"
    }

    private func statusColor(for order: PurchaseOrder) -> Color {
        order.id % 2 == 0 ? .green : .orange
    }

    private func sectionEmptyState(_ text: String) -> some View {
        Text(text)
            .font(.system(size: DeviceSize.fontSize(base: 14), weight: .medium))
            .foregroundColor(AppTheme.textSecondary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(DeviceSize.padding(base: 12))
            .appCardStyle(cornerRadius: 12)
    }

    private func sectionTitle(_ title: String, systemImage: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: systemImage)
                .foregroundColor(AppTheme.cyan)
            Text(title)
                .font(.system(size: DeviceSize.fontSize(base: 18), weight: .bold))
                .foregroundColor(AppTheme.textPrimary)
        }
    }

    @ViewBuilder
    private func profileInputRow(
        title: String,
        value: Binding<String>,
        editable: Bool,
        keyboardType: UIKeyboardType = .default
    ) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.system(size: DeviceSize.fontSize(base: 12), weight: .medium))
                .foregroundColor(AppTheme.textSecondary.opacity(0.9))

            if editable {
                TextField("Enter \(title.lowercased())", text: value)
                    .textFieldStyle(.plain)
                    .font(.system(size: DeviceSize.fontSize(base: 15), weight: .semibold))
                    .foregroundColor(AppTheme.textPrimary)
                    .keyboardType(keyboardType)
                    .textInputAutocapitalization(keyboardType == .emailAddress ? .never : .words)
                    .autocorrectionDisabled()
            } else {
                Text(value.wrappedValue.isEmpty ? "Not set" : value.wrappedValue)
                    .font(.system(size: DeviceSize.fontSize(base: 15), weight: .semibold))
                    .foregroundColor(value.wrappedValue.isEmpty ? AppTheme.textSecondary : AppTheme.textPrimary)
            }
        }
    }

    private func paymentMethod(for _: PurchaseOrder) -> String {
        "Card"
    }
}

#Preview {
    NavigationStack {
        ProfileView()
            .environmentObject(UserViewModel())
            .environmentObject(NavigationCoordinator())
            .environmentObject(PurchaseViewModel())
    }
}
