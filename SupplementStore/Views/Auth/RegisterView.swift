//
//  RegisterView.swift
//  SupplementStore
//
//  Created on [Date]
//

import SwiftUI

struct RegisterView: View {
    @EnvironmentObject var userViewModel: UserViewModel
    @EnvironmentObject var navigationCoordinator: NavigationCoordinator
    @State private var name: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var phone: String = ""
    @State private var showPassword: Bool = false
    @State private var showConfirmPassword: Bool = false
    @State private var errorMessage: String?
    
    private var isEmailValid: Bool {
        let trimmed = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        return trimmed.contains("@") && trimmed.hasSuffix(".com")
    }

    private var isFormValid: Bool {
        !name.isEmpty &&
        !email.isEmpty &&
        !password.isEmpty &&
        !confirmPassword.isEmpty &&
        !phone.isEmpty &&
        isEmailValid &&
        password == confirmPassword &&
        password.count >= 8
    }
    
    var body: some View {
        ZStack {
            // Background Gradient
            LinearGradient(
                colors: [
                    Color(red: 15/255, green: 23/255, blue: 42/255),
                    Color(red: 30/255, green: 41/255, blue: 59/255),
                    Color(red: 15/255, green: 23/255, blue: 42/255)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 32) {
                    // Header
                    VStack(spacing: 16) {
                        Text("Create Account")
                            .font(.system(size: 36, weight: .heavy))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [Color.cyan, Color(red: 0, green: 188/255, blue: 212/255)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                        
                        Text("Sign up to get started")
                            .font(.system(size: 18))
                            .foregroundColor(Color(red: 203/255, green: 213/255, blue: 225/255))
                            .opacity(0.9)
                    }
                    .padding(.top, 64)
                    .padding(.bottom, 32)
                    
                    // Registration Form
                    VStack(spacing: 24) {
                        // Name Field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Full Name")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                            
                            TextField("Enter your name", text: $name)
                                .textFieldStyle(LoginTextFieldStyle())
                                .autocapitalization(.words)
                        }
                        
                        // Email Field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Email")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                            
                            TextField("Enter your email", text: $email)
                                .textFieldStyle(LoginTextFieldStyle())
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)
                                .autocorrectionDisabled()
                        }
                        
                        // Phone Field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Phone Number")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                            
                            TextField("Enter your phone", text: $phone)
                                .textFieldStyle(LoginTextFieldStyle())
                                .keyboardType(.phonePad)
                        }
                        
                        // Password Field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Password")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                            
                            HStack {
                                if showPassword {
                                    TextField("Enter your password", text: $password)
                                } else {
                                    SecureField("Enter your password", text: $password)
                                }
                                
                                Button(action: { showPassword.toggle() }) {
                                    Image(systemName: showPassword ? "eye.slash.fill" : "eye.fill")
                                        .foregroundColor(Color(red: 203/255, green: 213/255, blue: 225/255))
                                }
                            }
                            .padding()
                            .background(Color(red: 30/255, green: 41/255, blue: 59/255).opacity(0.8))
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.cyan.opacity(0.3), lineWidth: 1)
                            )
                            
                            if !password.isEmpty && password.count < 8 {
                                Text("Invalid password: must be at least 8 characters")
                                    .font(.system(size: 12))
                                    .foregroundColor(.orange)
                                    .padding(.top, 4)
                            }
                        }
                        
                        // Confirm Password Field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Confirm Password")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                            
                            HStack {
                                if showConfirmPassword {
                                    TextField("Confirm your password", text: $confirmPassword)
                                } else {
                                    SecureField("Confirm your password", text: $confirmPassword)
                                }
                                
                                Button(action: { showConfirmPassword.toggle() }) {
                                    Image(systemName: showConfirmPassword ? "eye.slash.fill" : "eye.fill")
                                        .foregroundColor(Color(red: 203/255, green: 213/255, blue: 225/255))
                                }
                            }
                            .padding()
                            .background(Color(red: 30/255, green: 41/255, blue: 59/255).opacity(0.8))
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(passwordMatch ? Color.cyan.opacity(0.3) : Color.red.opacity(0.5), lineWidth: 1)
                            )
                            
                            if !confirmPassword.isEmpty && !passwordMatch {
                                Text("Passwords do not match")
                                    .font(.system(size: 12))
                                    .foregroundColor(.red)
                                    .padding(.top, 4)
                            }
                        }
                        
                        // Error Message
                        if let errorMessage = errorMessage ?? userViewModel.errorMessage {
                            Text(errorMessage)
                                .font(.system(size: 14))
                                .foregroundColor(.red)
                                .padding(.horizontal)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }

                        if !email.isEmpty && !isEmailValid {
                            Text("Invalid email")
                                .font(.system(size: 12))
                                .foregroundColor(.orange)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        
                        // Register Button
                        Button(action: handleRegister) {
                            HStack {
                                if userViewModel.isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                } else {
                                    Text("Sign Up")
                                        .font(.system(size: 18, weight: .semibold))
                                }
                            }
                            .foregroundColor(Color(red: 15/255, green: 23/255, blue: 42/255))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                LinearGradient(
                                    colors: [Color.cyan, Color(red: 0, green: 188/255, blue: 212/255)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.cyan.opacity(0.3), lineWidth: 1)
                            )
                        }
                        .disabled(!isFormValid || userViewModel.isLoading)
                        .opacity((!isFormValid || userViewModel.isLoading) ? 0.6 : 1.0)

                        HStack {
                            Rectangle()
                                .fill(Color.cyan.opacity(0.2))
                                .frame(height: 1)
                            Text("OR")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(Color(red: 203/255, green: 213/255, blue: 225/255))
                            Rectangle()
                                .fill(Color.cyan.opacity(0.2))
                                .frame(height: 1)
                        }

                        Button(action: handleGoogleSignUp) {
                            HStack(spacing: 10) {
                                ZStack {
                                    Circle()
                                        .fill(Color.white)
                                        .frame(width: 22, height: 22)
                                    Text("G")
                                        .font(.system(size: 13, weight: .bold))
                                        .foregroundColor(.black)
                                }
                                Text("Continue with Google")
                                    .font(.system(size: 16, weight: .semibold))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color.white.opacity(0.08))
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
                            )
                        }
                        .disabled(userViewModel.isLoading)
                        .opacity(userViewModel.isLoading ? 0.6 : 1.0)
                        
                        // Login Link
                        HStack {
                            Text("Already have an account?")
                                .font(.system(size: 16))
                                .foregroundColor(Color(red: 203/255, green: 213/255, blue: 225/255))
                            
                            Button(action: {
                                navigationCoordinator.navigateBack()
                            }) {
                                Text("Sign In")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: [Color.cyan, Color(red: 0, green: 188/255, blue: 212/255)],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                            }
                        }
                        .padding(.top, 8)
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 32)
                    .background(
                        RoundedRectangle(cornerRadius: 24)
                            .fill(Color(red: 15/255, green: 23/255, blue: 42/255).opacity(0.3))
                            .overlay(
                                RoundedRectangle(cornerRadius: 24)
                                    .stroke(Color.cyan.opacity(0.2), lineWidth: 1)
                            )
                    )
                    .padding(.horizontal, 24)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: userViewModel.isLoggedIn) { oldValue, newValue in
            if newValue && !oldValue {
                // User just registered - navigate to root which will show MainTabView
                DispatchQueue.main.async {
                    navigationCoordinator.navigateToRoot()
                }
            }
        }
    }
    
    private var passwordMatch: Bool {
        password.isEmpty || confirmPassword.isEmpty || password == confirmPassword
    }
    
    private func handleRegister() {
        errorMessage = nil
        
        // Validate passwords match
        guard password == confirmPassword else {
            errorMessage = "Passwords do not match"
            return
        }

        // Validate email format
        guard isEmailValid else {
            errorMessage = "Invalid email"
            return
        }
        
        // Validate password length
        guard password.count >= 8 else {
            errorMessage = "Invalid password: must be at least 8 characters"
            return
        }
        
        Task {
            await userViewModel.register(name: name, email: email, password: password, phone: phone)
            // Navigation will be handled by onChange when isLoggedIn changes
        }
    }

    private func handleGoogleSignUp() {
        // Requires backend Google OAuth endpoint + app client configuration.
        errorMessage = "Google sign up is not configured yet"
    }
}

#Preview {
    NavigationStack {
        RegisterView()
            .environmentObject(UserViewModel())
            .environmentObject(NavigationCoordinator())
    }
}
