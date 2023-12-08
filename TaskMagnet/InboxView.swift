//
//  TodayTaskView.swift
//  TaskMagnet
//
//  Created by Armin Halilovic on 03.12.2023.
//
import SwiftUI
import Firebase
import FirebaseFirestore
import Foundation

struct InboxView: View {
	@ObservedObject var viewModel: ContentViewModel
	@State private var showingAddTaskView = false
	@State private var showingDeleteAlert = false
	@State private var taskToDelete: Task?
	
	private func delete(at offsets: IndexSet, from category: String) {
		guard let index = offsets.first else { return }
		taskToDelete = viewModel.categorizedTasks[category]?[index]
		showingDeleteAlert = true
	}
	
	private static let taskDateFormat: DateFormatter = {
		let formatter = DateFormatter()
		formatter.dateStyle = .medium
		formatter.timeStyle = .none
		return formatter
	}()
	
	let formattedDate = Self.taskDateFormat.string(from: Date())
	
	var body: some View {
		NavigationView {
			VStack {
				taskList
					.navigationTitle("Inbox")
					.toolbar {
						ToolbarItem(placement: .navigationBarTrailing) {
							Button(action: {
								showingAddTaskView = true
							}) {
								Image(systemName: "plus.circle.fill")
									.foregroundColor(.mint)
							}
						}
					}
					.sheet(isPresented: $showingAddTaskView) {
						AddTaskView(isPresented: $showingAddTaskView, viewModel: viewModel)
					}
					.onAppear {
						if let userID = Auth.auth().currentUser?.uid {
							viewModel.attachListener(for: userID)
						}
					}
					.onDisappear {
						viewModel.detachListener()
					}
			}
		}
	}
	
	private var taskList: some View {
		List {
			ForEach(["Today", "Tomorrow", "Upcoming"], id: \.self) { category in
				Section(header: Text(category)) {
					taskSection(for: category)
				}
			}
		}
		.refreshable {
			viewModel.refreshTasks()
		}
	}
	
	private func taskSection(for category: String) -> some View {
		ForEach(viewModel.categorizedTasks[category] ?? [], id: \.firestoreID) { task in
			TaskRow(task: task, markAsComplete: { viewModel.markTaskAsComplete(for: task) },
					deleteTask: {
				if let index = viewModel.tasks.firstIndex(of: task) {
					viewModel.deleteSelectedTasks(at: IndexSet(arrayLiteral: index))
				}
			})
		}
		.onDelete(perform: { indexSet in
			delete(at: indexSet, from: category)
		})
		.alert(isPresented: $showingDeleteAlert) {
			Alert(
				title: Text("Delete Task"),
				message: Text("Are you sure you want to delete this task?"),
				primaryButton: .destructive(Text("Delete")) {
					if let task = taskToDelete,
					   let category = findCategory(for: task),
					   let index = viewModel.categorizedTasks[category]?.firstIndex(of: task) {
						viewModel.deleteTasks(at: IndexSet(integer: index), from: category)
					}
				}, secondaryButton: .cancel()
			)
		}
	}
	
	private func findCategory(for task: Task) -> String? {
		if viewModel.categorizedTasks["Today"]?.contains(task) == true {
			return "Today"
		} else if viewModel.categorizedTasks["Tomorrow"]?.contains(task) == true {
			return "Tomorrow"
		} else if viewModel.categorizedTasks["Upcoming"]?.contains(task) == true {
			return "Upcoming"
		}
		return nil
	}
}

struct AddTaskView: View {
	@Binding var isPresented: Bool
	@ObservedObject var viewModel: ContentViewModel
	
	@State private var taskTitle: String = ""
	@State private var dueDate: Date = Date()
	
	var body: some View {
		NavigationView {
			Form {
				TextField("Task Name", text: $taskTitle)
				DatePicker("Due Date", selection: $dueDate, displayedComponents: .date)
			}
			.navigationBarItems(leading: Button("Cancel") {
				isPresented = false
			}, trailing: Button("Add") {
				viewModel.addTask(title: taskTitle, dueDate: dueDate)
				isPresented = false
			})
			.navigationBarTitle("Add Task", displayMode: .inline)
		}
	}
}

struct TodayTaskView_Previews: PreviewProvider {
	static var previews: some View {
		InboxView(viewModel: .mock)
	}
}
