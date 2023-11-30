//
//  SignInEmailView.swift
//  TaskMagnet
//
//  Created by Armin Halilovic on 05.11.2023.
//

import SwiftUI
import _Concurrency

@MainActor
final class SignInEmailViewModel: ObservableObject {
	
	@Published var email = ""
	@Published var password = ""
	
	func signUp() async throws {
		guard !email.isEmpty, !password.isEmpty else {
			print("No email or Password found.")
			return
		}
		
		_ = try await AuthenticationManager.shared.createUser(email: email, password: password)
	}
	
	func signIn() async throws {
		guard !email.isEmpty, !password.isEmpty else {
			print("No email or Password found.")
			return
		}
		
		_ = try await AuthenticationManager.shared.signInUser(email: email, password: password)
	}
}

struct SignInEmailView: View {
	
	@StateObject private var viewModel = SignInEmailViewModel()
	@Binding var showSignInView: Bool
	
	var body: some View {
		VStack{
			TextField("Email", text: $viewModel.email)
				.padding()
				.background(Color.gray.opacity(0.3))
				.cornerRadius(10)
			
			SecureField("Password", text: $viewModel.password)
				.padding()
				.background(Color.gray.opacity(0.3))
				.cornerRadius(10)
			
			Button {
				_Concurrency.Task {
					do {
						try await viewModel.signUp()
						showSignInView = false
						return
					} catch {
						print(error)
					}
					
					do {
						try await viewModel.signIn()
						showSignInView = false
						return
					} catch {
						print(error)
					}
					
				}
			} label: {
				Text("Sign In")
					.font(.headline)
					.foregroundColor(.white)
					.frame(height: 55)
					.frame(maxWidth: .infinity)
					.background(Color.blue)
					.cornerRadius(10)
			}
		}
		.padding()
		.navigationTitle("Sign In with E-Mail")
	}
}

#Preview {
	NavigationStack {
		SignInEmailView(showSignInView: .constant(false))
	}
}
