//
//  Account.swift
//  ServiceForSociety
//
//  Created by Shriyans Dwivedi on 9/5/25.
//

import SwiftUI

struct Account: View {
    @State private var fullName = ""
    @State private var gmail = ""
    @State private var isProfileCreated = false
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Header
                VStack(spacing: 10) {
                    Text("Create Your Profile")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text("Join our community and start making a difference")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 40)
                
                Spacer()
                
                // Profile Icon
                Image(systemName: "person.circle.fill")
                    .font(.system(size: 100))
                    .foregroundColor(.blue)
                    .padding(.bottom, 30)
                
                // Input Fields
                VStack(spacing: 16) {
                    // Name Field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Full Name")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        TextField("Enter your full name", text: $fullName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .font(.body)
                    }
                    
                    // Gmail Field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Gmail Address")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        TextField("Enter your Gmail", text: $gmail)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .font(.body)
                    }
                }
                .padding(.horizontal, 20)
                
                Spacer()
                
                // Create Profile Button
                Button(action: createProfile) {
                    Text("Create Profile")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [.blue, .purple]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(12)
                        .shadow(radius: 3)
                }
                .padding(.horizontal, 20)
                .disabled(fullName.isEmpty || gmail.isEmpty || !isValidGmail(gmail))
                .opacity((fullName.isEmpty || gmail.isEmpty || !isValidGmail(gmail)) ? 0.6 : 1.0)
                
                // Validation Text
                if !gmail.isEmpty && !isValidGmail(gmail) {
                    Text("Please enter a valid Gmail address")
                        .font(.caption)
                        .foregroundColor(.red)
                        .padding(.horizontal, 20)
                }
                
                Spacer()
            }
            .navigationTitle("Account")
            .navigationBarTitleDisplayMode(.inline)
            .alert("Profile Status", isPresented: $showingAlert) {
                Button("OK") { }
            } message: {
                Text(alertMessage)
            }
            .sheet(isPresented: $isProfileCreated) {
                ProfileCreatedView(name: fullName, gmail: gmail)
            }
        }
    }
    
    // MARK: - Functions
    
    private func createProfile() {
        if isValidGmail(gmail) && !fullName.isEmpty {
            // Here you would typically save to UserDefaults, Core Data, or send to a server
            saveProfile()
            isProfileCreated = true
        } else {
            alertMessage = "Please fill in all fields with valid information."
            showingAlert = true
        }
    }
    
    private func isValidGmail(_ email: String) -> Bool {
        let gmailPattern = "^[a-zA-Z0-9._%+-]+@gmail\\.com$"
        let regex = NSPredicate(format: "SELF MATCHES %@", gmailPattern)
        return regex.evaluate(with: email)
    }
    
    private func saveProfile() {
        // Save to UserDefaults (you might want to use Core Data or another storage solution later)
        UserDefaults.standard.set(fullName, forKey: "userFullName")
        UserDefaults.standard.set(gmail, forKey: "userGmail")
        UserDefaults.standard.set(true, forKey: "profileCreated")
        
        alertMessage = "Profile created successfully!"
    }
}

// MARK: - Profile Created Success View

struct ProfileCreatedView: View {
    let name: String
    let gmail: String
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack(spacing: 30) {
            // Success Icon
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.green)
            
            // Success Message
            Text("Profile Created!")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Text("Welcome to Service For Society")
                .font(.title2)
                .foregroundColor(.secondary)
            
            // Profile Info
            VStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Name")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    Text(name)
                        .font(.title2)
                        .fontWeight(.medium)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Gmail")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    Text(gmail)
                        .font(.title2)
                        .fontWeight(.medium)
                }
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(12)
            
            Spacer()
            
            Button("Get Started") {
                presentationMode.wrappedValue.dismiss()
            }
            .font(.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.green)
            .cornerRadius(12)
        }
        .padding()
        .navigationBarHidden(true)
    }
}

// MARK: - Preview

struct Account_Previews: PreviewProvider {
    static var previews: some View {
        Account()
    }
}
