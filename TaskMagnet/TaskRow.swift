//
//  TaskRow.swift
//  TaskMagnet
//
//  Created by Armin Halilovic on 06.12.2023.
//
import SwiftUI

struct TaskRow: View {
	var task: Task
	var markAsComplete: () -> Void
	
	private var formattedDueDate: String? {
		guard let dueDate = task.dueDate else { return nil }
		return DateFormatting.taskDateFormat.string(from: dueDate)
	}
	
	var body: some View {
		HStack {
			Button(action: markAsComplete) {
				Image(systemName: task.isComplete ? "checkmark.circle.fill" : "circle")
					.foregroundColor(task.isComplete ? .green : .gray)
			}
			.buttonStyle(PlainButtonStyle())
			
			VStack(alignment: .leading) {
				Text(task.title)
					.strikethrough(task.isComplete, color: .gray)
				
				if let dueDateString = formattedDueDate {
					Text("Due: \(dueDateString)")
						.font(.subheadline)
						.foregroundColor(.gray)
				}
			}
		}
	}
}

struct TaskRow_Previews: PreviewProvider {
	static var previews: some View {
		TaskRow(task: Task.mock, markAsComplete: {})
			.previewLayout(.sizeThatFits)
	}
}

// Extension to provide mock data for previewing
extension Task {
	static var mock: Task {
		Task(id: UUID(), firestoreID: "1", title: "Sample Task", isComplete: false, dueDate: Date())
	}
}
