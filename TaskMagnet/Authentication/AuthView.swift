//
//  AuthView.swift
//  TaskMagnet
//
//  Created by Armin Halilovic on 05.11.2023.
//

import SwiftUI
import GoogleSignIn
import GoogleSignInSwift
import FirebaseAuth
import _Concurrency

struct GoogleSignInResultModel {
	let idToken: String
	let accessToken: String
}

@MainActor
final class AuthenticationViewModel: ObservableObject {
	
	func signInGoogle() async throws {
		
		guard let topVC = Utilities.shared.topViewController() else {
			throw URLError(.cannotFindHost)
		}
		
		let gidSignInResult = try await GIDSignIn.sharedInstance.signIn(withPresenting: topVC)
		
		guard let idToken: String = gidSignInResult.user.idToken?.tokenString else {
			throw URLError(.cannotFindHost)
		}
		
		let accessToken = gidSignInResult.user.accessToken.tokenString
		
		let tokens = GoogleSignInResultModel(idToken: idToken, accessToken: accessToken)
		try await AuthenticationManager.shared.signInWithGoogle(tokens: tokens)
		
	}
	
}

struct AuthView: View {
	
	@StateObject private var viewModel = AuthenticationViewModel()
	@Binding var showSignInView: Bool
	
	var body: some View {
		VStack {
			
			NavigationLink{
				SignInEmailView(showSignInView: $showSignInView)
			} label: {
				Text("Sign In with E-Mail")
					.font(.headline)
					.foregroundColor(.white)
					.frame(height: 44)
					.frame(maxWidth: 200)
					.background(Color.blue)
					.cornerRadius(16)
			}
			
			Button {
				_Concurrency.Task {
					do  {
						try await viewModel.signInGoogle()
						showSignInView = false
					} catch {
						print(error)
					}
				}
			} label: {
				Text("Sign in with Google")
					.font(.headline)
					.foregroundColor(.white)
					.frame(height: 44)
					.frame(maxWidth: 200)
					.background(Color.red)
					.cornerRadius(16)
			}
		}
		.padding()
		.navigationTitle("Welcome to TaskMagnet")
	}
}

#Preview {
	NavigationStack {
		AuthView(showSignInView: .constant(false))
	}
}
