//
//
//  TaskMagnet
//
//  Created by Armin Halilovic on 05.11.2023.
//

import SwiftUI
import _Concurrency

@MainActor
final class SettingsViewmodel: ObservableObject {
	
	func signOut() throws {
		try AuthenticationManager.shared.signOut()
	}
}

struct SettingsView: View {
	
	@StateObject private var viewModel = SettingsViewmodel()
	@Binding var showSignInView: Bool
	@State private var showingSignOutAlert = false
	
	var body: some View {
		NavigationView {
			VStack {
				Spacer()
				
				Button("Log Out", systemImage: "rectangle.portrait.and.arrow.right") {
					showingSignOutAlert = true
				}
				.alert("Are you sure you want to log out?", isPresented: $showingSignOutAlert) {
					Button("Log Out", role: .destructive) {
						signOut()
					}
					Button("Cancel", role: .cancel) { }
				}
				Spacer().frame(height: 20)
			}
		}
		.padding()
		.navigationTitle("Settings")
	}
	
	private func signOut() {
		_Concurrency.Task {
			do {
				try viewModel.signOut()
				showSignInView = true
			} catch {
				
			}
		}
	}
}

#Preview {
	NavigationStack{
		SettingsView(showSignInView: .constant(false))
	}
}
