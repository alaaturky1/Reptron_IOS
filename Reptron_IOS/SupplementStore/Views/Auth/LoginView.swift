//
//  LoginView.swift
//  SupplementStore
//
//  Created on [Date]
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var userViewModel: UserViewModel
    @EnvironmentObject var navigationCoordinator: NavigationCoordinator
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var showPassword: Bool = false
    @State private var errorMessage: String?
    
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
                        Text("Welcome Back")
                            .font(.system(size: 36, weight: .heavy))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [Color.cyan, Color(red: 0, green: 188/255, blue: 212/255)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                        
                        Text("Sign in to continue")
                            .font(.system(size: 18))
                            .foregroundColor(Color(red: 203/255, green: 213/255, blue: 225/255))
                            .opacity(0.9)
                    }
                    .padding(.top, 64)
                    .padding(.bottom, 32)
                    
                    // Login Form
                    VStack(spacing: 24) {
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
                        }
                        
                        // Error Message
                        if let errorMessage = errorMessage ?? userViewModel.errorMessage {
                            Text(errorMessage)
                                .font(.system(size: 14))
                                .foregroundColor(.red)
                                .padding(.horizontal)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        
                        // Login Button
                        Button(action: handleLogin) {
                            HStack {
                                if userViewModel.isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                } else {
                                    Text("Sign In")
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
                        .disabled(userViewModel.isLoading || email.isEmpty || password.isEmpty)
                        .opacity((userViewModel.isLoading || email.isEmpty || password.isEmpty) ? 0.6 : 1.0)
                        
                        // Register Link
                        HStack {
                            Text("Don't have an account?")
                                .font(.system(size: 16))
                                .foregroundColor(Color(red: 203/255, green: 213/255, blue: 225/255))
                            
                            Button(action: {
                                navigationCoordinator.navigate(to: .register)
                            }) {
                                Text("Sign Up")
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
                // User just logged in - navigate to root which will show MainTabView
                DispatchQueue.main.async {
                    navigationCoordinator.navigateToRoot()
                }
            }
        }
    }
    
    private func handleLogin() {
        errorMessage = nil
        Task {
            await userViewModel.login(email: email, password: password)
            // Navigation will be handled by onChange when isLoggedIn changes
        }
    }
}

// Custom TextField Style
struct LoginTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding()
            .background(Color(red: 30/255, green: 41/255, blue: 59/255).opacity(0.8))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.cyan.opacity(0.3), lineWidth: 1)
            )
            .foregroundColor(.white)
    }
}

#Preview {
    NavigationStack {
        LoginView()
            .environmentObject(UserViewModel())
            .environmentObject(NavigationCoordinator())
    }
}
