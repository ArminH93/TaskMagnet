//
//  AuthenticationManager.swift
//  TaskMagnet
//
//  Created by Armin Halilovic on 05.11.2023.
//

import Foundation
import Firebase
import FirebaseAuth


struct AuthDataResultModel {
	let uid: String
	let email: String?
	let photoUrl: String?
	
	init(user: User) {
		self.uid = user.uid
		self.email = user.email
		self.photoUrl = user.photoURL?.absoluteString
	}
}

final class AuthenticationManager {
	
	static let shared = AuthenticationManager()
	private init() {}
	
	func getAuthenticatedUser() throws -> AuthDataResultModel {
		guard let user = Auth.auth().currentUser else {
			throw URLError(.badServerResponse)
		}
		
		return AuthDataResultModel(user: user)
	}
	
	var currentUser: User? {
		return Auth.auth().currentUser
	}
	
	func signOut() throws {
		try Auth.auth().signOut()
	}
	
}

extension AuthenticationManager{
	
	@discardableResult
	func createUser(email: String, password: String) async throws -> AuthDataResultModel {
		let authDataResult = try await Auth.auth().createUser(withEmail: email, password: password)
		return AuthDataResultModel(user: authDataResult.user)
	}
	
	@discardableResult
	func signInUser(email: String, password: String) async throws -> AuthDataResultModel {
		let authDataResult = try await Auth.auth().signIn(withEmail: email, password: password)
		return AuthDataResultModel(user: authDataResult.user)
	}
	
	/*
	func resetPassword(email: String) async throws{
		try await Auth.auth().sendPasswordReset(withEmail: email)
	}
	
	func updatePassword(password: String) async throws{
		guard let user = Auth.auth().currentUser else {
			// TODO: Update Error Message (Password)
			throw URLError(.badServerResponse)
		}
		
		try await user.updatePassword(to: password)
	}
	
	func updateEmail(email: String) async throws{
		guard let user = Auth.auth().currentUser else {
			throw URLError(.badServerResponse)
		}
		
		try await user.updateEmail(to: email)
	}
	 */
	
}

extension AuthenticationManager {
	
	@discardableResult
	func signInWithGoogle(tokens: GoogleSignInResultModel) async throws -> AuthDataResultModel {
		let credential = GoogleAuthProvider.credential(withIDToken: tokens.idToken,
													   accessToken: tokens.accessToken)
		return try await signIn(credential: credential)
	}
	
	func signIn(credential: AuthCredential) async throws -> AuthDataResultModel {
		let authDataResult = try await Auth.auth().signIn(with: credential)
		return AuthDataResultModel(user: authDataResult.user)
	}
	
}
