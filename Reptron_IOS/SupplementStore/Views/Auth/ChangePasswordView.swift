import SwiftUI
import UIKit

private enum DeviceSize {
    private static let baseScreenWidth: CGFloat = 390

    private static func scaleValue(_ value: CGFloat) -> CGFloat {
        let screenWidth = UIScreen.main.bounds.width
        return value * (screenWidth / baseScreenWidth)
    }

    static func spacing(base: CGFloat) -> CGFloat { scaleValue(base) }
    static func padding(base: CGFloat) -> CGFloat { scaleValue(base) }
    static func fontSize(base: CGFloat) -> CGFloat { scaleValue(base) }
}

struct ChangePasswordView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var userViewModel: UserViewModel

    @State private var currentPassword = ""
    @State private var newPassword = ""
    @State private var confirmPassword = ""
    @State private var showCurrent = false
    @State private var showNew = false
    @State private var showConfirm = false
    @State private var localError: String?
    @State private var showSuccessAlert = false

    private var passwordsMatch: Bool {
        confirmPassword.isEmpty || newPassword == confirmPassword
    }

    private var canSubmit: Bool {
        !currentPassword.isEmpty &&
            !newPassword.isEmpty &&
            !confirmPassword.isEmpty &&
            newPassword.count >= 8 &&
            newPassword == confirmPassword &&
            newPassword != currentPassword
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: DeviceSize.spacing(base: 16)) {
                    Text("Use at least 8 characters. Your new password must differ from the current one.")
                        .font(.system(size: DeviceSize.fontSize(base: 13), weight: .medium))
                        .foregroundColor(AppTheme.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)

                    passwordField(
                        title: "Current password",
                        text: $currentPassword,
                        showPlain: $showCurrent
                    )

                    passwordField(
                        title: "New password",
                        text: $newPassword,
                        showPlain: $showNew
                    )

                    if !newPassword.isEmpty && newPassword.count < 8 {
                        Text("New password must be at least 8 characters")
                            .font(.system(size: DeviceSize.fontSize(base: 12), weight: .medium))
                            .foregroundColor(.orange.opacity(0.95))
                    }

                    passwordField(
                        title: "Confirm new password",
                        text: $confirmPassword,
                        showPlain: $showConfirm
                    )

                    if !confirmPassword.isEmpty && !passwordsMatch {
                        Text("Passwords do not match")
                            .font(.system(size: DeviceSize.fontSize(base: 12), weight: .medium))
                            .foregroundColor(.red.opacity(0.9))
                    }

                    if !newPassword.isEmpty, !currentPassword.isEmpty, newPassword == currentPassword {
                        Text("New password must be different from your current password")
                            .font(.system(size: DeviceSize.fontSize(base: 12), weight: .medium))
                            .foregroundColor(.orange.opacity(0.95))
                    }

                    if let msg = localError ?? userViewModel.errorMessage, !msg.isEmpty {
                        Text(msg)
                            .font(.system(size: DeviceSize.fontSize(base: 13), weight: .medium))
                            .foregroundColor(.red.opacity(0.9))
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Button(action: submit) {
                        HStack {
                            if userViewModel.isLoading {
                                ProgressView()
                                    .tint(AppTheme.bgBottom)
                            }
                            Text("Update password")
                                .font(.system(size: DeviceSize.fontSize(base: 16), weight: .bold))
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(PrimaryGlowButtonStyle())
                    .disabled(!canSubmit || userViewModel.isLoading)
                    .opacity((!canSubmit || userViewModel.isLoading) ? 0.55 : 1)
                }
                .padding(DeviceSize.padding(base: 18))
            }
            .appScreenBackground()
            .navigationTitle("Change password")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                    .foregroundColor(AppTheme.cyan)
                }
            }
            .alert("Password updated", isPresented: $showSuccessAlert) {
                Button("OK") {
                    dismiss()
                }
            } message: {
                Text("You can keep using the app with your existing session.")
            }
        }
    }

    private func passwordField(title: String, text: Binding<String>, showPlain: Binding<Bool>) -> some View {
        VStack(alignment: .leading, spacing: DeviceSize.spacing(base: 6)) {
            Text(title)
                .font(.system(size: DeviceSize.fontSize(base: 12), weight: .medium))
                .foregroundColor(AppTheme.textSecondary.opacity(0.9))

            HStack(spacing: 10) {
                Group {
                    if showPlain.wrappedValue {
                        TextField("Enter \(title.lowercased())", text: text)
                    } else {
                        SecureField("Enter \(title.lowercased())", text: text)
                    }
                }
                .textFieldStyle(.plain)
                .font(.system(size: DeviceSize.fontSize(base: 15), weight: .semibold))
                .foregroundColor(AppTheme.textPrimary)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()

                Button {
                    showPlain.wrappedValue = !showPlain.wrappedValue
                } label: {
                    Image(systemName: showPlain.wrappedValue ? "eye.slash.fill" : "eye.fill")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(AppTheme.cyan.opacity(0.85))
                }
                .accessibilityLabel(showPlain.wrappedValue ? "Hide password" : "Show password")
            }
            .padding(DeviceSize.padding(base: 12))
            .background(AppTheme.cardOverlay.opacity(0.65), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(AppTheme.cyan.opacity(0.25), lineWidth: 1)
            )
        }
    }

    private func submit() {
        localError = nil
        userViewModel.errorMessage = nil
        Task {
            let ok = await userViewModel.changePassword(
                currentPassword: currentPassword,
                newPassword: newPassword,
                confirmNewPassword: confirmPassword
            )
            if ok {
                currentPassword = ""
                newPassword = ""
                confirmPassword = ""
                showSuccessAlert = true
            }
        }
    }
}

#Preview {
    ChangePasswordView()
        .environmentObject(UserViewModel())
}
