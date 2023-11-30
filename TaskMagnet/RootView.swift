//
//  RootView.swift
//  TaskMagnet
//
//  Created by Armin Halilovic on 05.11.2023.
//

import SwiftUI

struct RootView: View {
	
	@State private var showSignInView: Bool = false
	var body: some View {
		ZStack {
			NavigationStack {
				ContentView(showSignInView: $showSignInView)
			}
		}
		.onAppear {
			let authUser = try? AuthenticationManager.shared.getAuthenticatedUser()
			self.showSignInView = authUser == nil
		}
		.fullScreenCover(isPresented: $showSignInView) {
			NavigationStack {
				AuthView(showSignInView: $showSignInView)
			}
		}
	}
}

#Preview {
	RootView()
}
