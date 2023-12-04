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

struct TodayTaskView: View {
	@ObservedObject var viewModel: ContentViewModel
	@State private var showingDeleteConfirmation = false
	@State private var showingAddTaskView = false
	
	private static let taskDateFormat: DateFormatter = {
		let formatter = DateFormatter()
		formatter.dateStyle = .medium
		formatter.timeStyle = .none
		return formatter
	}()
	
	private var todaysTasks: [Task] {
		let today = Calendar.current.startOfDay(for: Date())
		return viewModel.tasks.filter { task in
			guard let dueDate = task.dueDate else { return false }
			return dueDate <= today && !task.isComplete
		}
	}
	
	var body: some View {
		let formattedDate = Self.taskDateFormat.string(from: Date())
		let today = Calendar.current.startOfDay(for: Date())
		
		NavigationView {
			List {
				ForEach(todaysTasks, id: \.firestoreID) { task in
					HStack {
						Button(action: {
							viewModel.markTaskAsComplete(for: task)
						}) {
							Image(systemName: task.isComplete ? "checkmark.circle.fill" : "circle")
								.foregroundColor(task.isComplete ? .green : .gray)
						}
						.buttonStyle(PlainButtonStyle())
						
						Text(task.title)
							.strikethrough(task.isComplete, color: .gray)
							.foregroundColor(isOverdue(task: task, today: today) ? .red : .primary)
						Spacer()
					}
				}
				.onDelete { offsets in
					viewModel.deleteSelectedTasks(at: offsets)
				}
				
			}
			.navigationTitle("Today, \(formattedDate)")
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
	
	private func isOverdue(task: Task, today: Date) -> Bool {
		guard let dueDate = task.dueDate, !task.isComplete else { return false }
		return dueDate < today
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
		TodayTaskView(viewModel: .mock)
	}
}
