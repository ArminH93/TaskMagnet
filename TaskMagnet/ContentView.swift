//
//  ContentView.swift
//  TaskMagnets
//
//  Created by Armin Halilovic on 05.11.2023.
//

import SwiftUI
import Firebase
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
	
	func logout() throws {
		try AuthenticationManager.shared.signOut()
	}
	
}

struct ContentView: View {
	@StateObject private var viewModel = ContentViewModel()
	@Binding var showSignInView: Bool
	@State private var tasks: [Task] = []
	
	private static let taskDateFormat: DateFormatter = {
		let formatter = DateFormatter()
		formatter.dateStyle = .medium
		formatter.timeStyle = .none
		return formatter
	}()
	
	var body: some View {
		var formattedDate: String {
			Self.taskDateFormat.string(from: Date())
		}
		
		TabView {
			// First Tab with Tasks
			NavigationView {
				List {
					ForEach(tasks) { task in
						Text(task.title)
					}
					.onDelete(perform: deleteTask)
				}
				.navigationTitle("Today, \(formattedDate)")
				.toolbar {
					ToolbarItem(placement: .navigationBarTrailing) {
						Button(action: {
							if let userID = Auth.auth().currentUser?.uid {
								let newTask = Task(title: "New Task", isComplete: false)
								addTask(newTask, for: userID)
							}
						}) {
							Label("Add Task", systemImage: "plus.circle.fill")
						}
					}
				}
				.onAppear {
					if let userID = Auth.auth().currentUser?.uid {
						loadTasks(for: userID) { fetchedTasks in
							DispatchQueue.main.async {
								self.tasks = fetchedTasks
							}
							
						}
					}
				}
			}
			.tabItem {
				Label("Tasks", systemImage: "list.bullet")
			}
			
			// Second Tab with Settings
			NavigationView {
				SettingsView(showSignInView: $showSignInView)
			}
			.tabItem {
				Label("More", systemImage: "ellipsis.circle")
			}
			.navigationTitle("Settings")
		}
	}
	
	
	private func deleteTask(at offsets: IndexSet) {
		guard let userID = Auth.auth().currentUser?.uid else { return }

		offsets.forEach { index in
			if let firestoreID = tasks[index].firestoreID {
				removeTask(firestoreID, for: userID)
			}
		}

		DispatchQueue.main.async {
			self.tasks.remove(atOffsets: offsets)
		}
	}
	
	/*private func deleteTask(at offsets: IndexSet) {
	 guard let userID = Auth.auth().currentUser?.uid else { return }

		offsets.forEach { index in
			if let firestoreID = tasks[index].firestoreID {
				removeTask(firestoreID, for: userID)
				tasks.remove(at: index)
			}
		}
	}
	 */

}

struct ContentView_Previews: PreviewProvider {
	static var previews: some View {
		ContentView(showSignInView: .constant(true))
	}
}
