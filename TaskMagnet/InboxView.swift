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
	@State private var showingDeleteConfirmation = false
	@State private var showingAddTaskView = false
	
	private static let taskDateFormat: DateFormatter = {
		let formatter = DateFormatter()
		formatter.dateStyle = .medium
		formatter.timeStyle = .none
		return formatter
	}()
	
	let formattedDate = Self.taskDateFormat.string(from: Date())
	
	var body: some View {
		
		NavigationView {
			List {
				ForEach(["Today", "Tomorrow", "Upcoming"], id: \.self) { category in
					Section(header: Text(category)) {
						ForEach(viewModel.categorizedTasks[category] ?? [], id: \.firestoreID) { task in
							TaskRow(task: task, markAsComplete: {
								viewModel.markTaskAsComplete(for: task)
							})
						}
					}
				}
			}
			.navigationTitle("Inbox")
			.toolbar {
				ToolbarItem(placement: .navigationBarTrailing) {
					Button(action: {
						showingAddTaskView = true
					}) {
						Image(systemName: "plus.circle.fill")
							.foregroundColor(.green)
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
