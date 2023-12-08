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

struct Task: Codable, Identifiable, Equatable {
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
	@Published var completedSearchQuery = ""
	
	private let dataService = DataService.shared
	private var userID: String? {
		Auth.auth().currentUser?.uid
	}
	
	func refreshTasks() {
		guard let userID = userID else { return }
		
		dataService.fetchTasks(for: userID) { [weak self] newTasks, error in
			DispatchQueue.main.async {
				if let newTasks = newTasks {
					self?.tasks = newTasks
				} else if let error = error {
					print("Error fetching tasks: \(error)")
				}
			}
		}
	}
	
	var categorizedTasks: [String: [Task]] {
		var categories: [String: [Task]] = ["Today": [], "Tomorrow": [], "Upcoming": []]
		let today = Calendar.current.startOfDay(for: Date())
		
		for task in tasks where !task.isComplete {
			guard let dueDate = task.dueDate else { continue }
			if Calendar.current.isDateInToday(dueDate) {
				categories["Today"]?.append(task)
			} else if Calendar.current.isDateInTomorrow(dueDate) {
				categories["Tomorrow"]?.append(task)
			} else if dueDate > today {
				categories["Upcoming"]?.append(task)
			}
		}
		return categories
	}
	
	func logout() throws {
		try AuthenticationManager.shared.signOut()
	}
	
	private var listener: ListenerRegistration?
	
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
	
	func deleteTasks(at offsets: IndexSet, from category: String) {
		guard let userID = Auth.auth().currentUser?.uid else { return }
		
		for index in offsets {
			if let taskToDelete = categorizedTasks[category]?[index],
			   let firestoreID = taskToDelete.firestoreID {
				
				// Remove task from Firestore
				DataService.shared.deleteTask(with: firestoreID, for: userID) { error in
					// Handle errors if necessary
				}
				
				// Remove task from local tasks array
				if let globalIndex = tasks.firstIndex(where: { $0.firestoreID == firestoreID }) {
					tasks.remove(at: globalIndex)
				}
			}
		}
	}
	
	// Method to handle the deletion process
	func deleteSelectedTasks(at offsets: IndexSet) {
		guard let userID = Auth.auth().currentUser?.uid else { return }
		
		DataService.shared.deleteTask(at: offsets, from: tasks, for: userID) { error in
			if error == nil {
				DispatchQueue.main.async {
					self.tasks.remove(atOffsets: offsets)
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
		}
	}
	
	func markTaskAsComplete(for task: Task) {
		DataService.shared.markTaskAsComplete(for: task) {
			if let index = self.tasks.firstIndex(where: { $0.firestoreID == task.firestoreID }) {
				DispatchQueue.main.async {
					self.tasks[index].isComplete = true
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
				InboxView(viewModel: viewModel)
			}.tabItem {
				Label("Inbox", systemImage: "archivebox")
			}.tag(1)
			
			NavigationStack {
				CompletedTaskView(viewModel: viewModel, searchQuery: $viewModel.completedSearchQuery, isCurrentlySelected: Binding(get: {
					self.selectedTab == 2
				}, set: { _ in }))
			}.tabItem {
				Label("Completed", systemImage: "checklist.checked")
			}.tag(2)
			
			NavigationStack {
				SettingsView(showSignInView: $showSignInView)
			}.tabItem {
				Label("Settings", systemImage: "gearshape")
			}.tag(3)
		}
	}
}

struct ContentView_Previews: PreviewProvider {
	static var previews: some View {
		ContentView(showSignInView: .constant(true))
	}
}
