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
				
			}
			.navigationTitle("Settings")
			.toolbar {
				ToolbarItem(placement: .navigationBarTrailing) {
					Button(action: {
						showingSignOutAlert = true
					}) {
						Image(systemName: "rectangle.portrait.and.arrow.forward")
							.foregroundColor(.pink)
					}
					.alert("Are you sure you want to log off", isPresented: $showingSignOutAlert) {
						Button("Yes, log me off", role: .destructive) {
							signOut()
						}
						Button("Cancel", role: .cancel) {}
					}
				}
			}
		}
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
