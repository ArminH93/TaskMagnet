//
//  ContentView.swift
//  TaskMagnets
//
//  Created by Armin Halilovic on 05.11.2023.
//

import SwiftUI
import Firebase
import FirebaseFirestore
import _Concurrency

struct Task: Codable, Identifiable {
	let id: UUID?
	var firestoreID: String?
	var title: String
	var isComplete: Bool
	var dueDate: Date?
	
	init(id: UUID = UUID(), firestoreID: String? = nil, title: String, isComplete: Bool, dueDate: Date? = nil) {
		self.id = id
		self.title = title
		self.isComplete = isComplete
		self.dueDate = dueDate
	}
}

@MainActor
final class ContentViewModel: ObservableObject {
	@Published var tasks: [Task] = []
	@Published var archiveSearchQuery = ""
	private var listener: ListenerRegistration?
	
	func logout() throws {
		try AuthenticationManager.shared.signOut()
	}
	
	func attachListener(for userID: String) {
		DataService.shared.fetchTasks(for: userID) { [weak self] (tasks, error) in
			if let tasks = tasks {
				self?.tasks = tasks
			} else if error != nil {
				// Handle error
			}
		}
	}
	
	func detachListener() {
		listener?.remove()
		listener = nil
	}
	
	private func countOfTasksDueToday() -> Int {
		let today = Calendar.current.startOfDay(for: Date())
		return tasks.filter { task in
			guard let dueDate = task.dueDate, !task.isComplete else { return false }
			return Calendar.current.isDate(dueDate, inSameDayAs: today)
		}.count
	}
	
	func updateAppBadge() {
		DispatchQueue.main.async {
			let today = Calendar.current.startOfDay(for: Date())
			let count = self.tasks.filter { task in
				guard let dueDate = task.dueDate else { return false }
				return Calendar.current.isDate(dueDate, inSameDayAs: today)
			}.count
			UIApplication.shared.applicationIconBadgeNumber = count
		}
	}
	
	// Method to handle the deletion process
	func deleteSelectedTasks(at offsets: IndexSet) {
		guard let userID = Auth.auth().currentUser?.uid else { return }
		
		DataService.shared.deleteTask(at: offsets, from: tasks, for: userID) { error in
			if error == nil {
				DispatchQueue.main.async {
					self.tasks.remove(atOffsets: offsets)
					self.updateAppBadge() // Update after task removal
				}
			} else {
				// Handle error
			}
		}
	}
	
	func addTask(title: String, dueDate: Date? = nil) {
		guard let userID = Auth.auth().currentUser?.uid else { return }
		let newTask = Task(title: title, isComplete: false, dueDate: dueDate)
		DataService.shared.addTask(newTask, for: userID) {
			self.updateAppBadge() // Update after adding the task
		}
	}
	
	func markTaskAsComplete(for task: Task) {
		DataService.shared.markTaskAsComplete(for: task) {
			if let index = self.tasks.firstIndex(where: { $0.firestoreID == task.firestoreID }) {
				DispatchQueue.main.async {
					self.tasks[index].isComplete = true
					self.updateAppBadge() // Update after marking task as complete
				}
			}
		}
	}
}

struct ContentView: View {
	@StateObject private var viewModel = ContentViewModel()
	@Binding var showSignInView: Bool
	@State private var selectedTab: Int = 0
	
	var body: some View {
		TabView(selection: $selectedTab) {
			NavigationStack {
				TodayTaskView(viewModel: viewModel)
			}.tabItem {
				Label("Today", systemImage: "list.bullet")
			}.tag(1)
			
			NavigationStack {
				UpcomingTaskView(viewModel: viewModel)
			}.tabItem {
				Label("Upcoming", systemImage: "calendar")
			}.tag(2)
			
			NavigationStack {
				CompletedTaskView(viewModel: viewModel, searchQuery: $viewModel.archiveSearchQuery, isCurrentlySelected: Binding(get: {
					self.selectedTab == 3
				}, set: { _ in }))
			}.tabItem {
				Label("Completed", systemImage: "checklist.checked")
			}.tag(3)
			
			NavigationStack {
				SettingsView(showSignInView: $showSignInView)
			}.tabItem {
				Label("Settings", systemImage: "gearshape")
			}.tag(4)
		}
	}
}

struct ContentView_Previews: PreviewProvider {
	static var previews: some View {
		ContentView(showSignInView: .constant(true))
	}
}
