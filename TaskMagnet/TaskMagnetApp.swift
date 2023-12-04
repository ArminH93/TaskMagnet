//
//  TaskMagnetApp.swift
//  TaskMagnet
//
//  Created by Armin Halilovic on 05.11.2023.
//

import SwiftUI
import Firebase
import UIKit
import UserNotifications

@main
struct TaskMagnetApp: App {
	@UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
	
	var body: some Scene {
		WindowGroup {
			NavigationStack {
				RootView()
			}
		}
	}
}

class AppDelegate: NSObject, UIApplicationDelegate {
	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
		
		FirebaseApp.configure()
		// For the App Badge
		requestNotificationPermission()
		
		return true
	}
	
	func requestNotificationPermission() {
		UNUserNotificationCenter.current().requestAuthorization(options: [.badge]) { granted, error in
			if granted {
				// Permission granted
			} else if let error = error {
				print("Notification Permission Error: \(error)")
			}
		}
	}
}
