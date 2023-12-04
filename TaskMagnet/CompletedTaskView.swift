//
//  CompletedTaskView.swift
//  TaskMagnet
//
//  Created by Armin Halilovic on 03.12.2023.
//

import SwiftUI

struct CompletedTaskView: View {
	@ObservedObject var viewModel: ContentViewModel
	@Binding var searchQuery: String
	@Binding var isCurrentlySelected: Bool
	
	var filteredTasks: [Task] {
		viewModel.tasks.filter {
			$0.isComplete &&
			(searchQuery.isEmpty || $0.title.localizedCaseInsensitiveContains(searchQuery))
		}
	}
	
	var body: some View {
		// NavigationStack is buggy -> Using NavigationView instead
		NavigationView {
			if searchQuery.isEmpty {
				VStack {
					
					Image(systemName: "checklist.checked")
						.resizable()
						.scaledToFit()
						.frame(width: 30, height: 30)
						.foregroundColor(.green)
					Text("You have \(viewModel.tasks.filter { $0.isComplete }.count) completed tasks")
						.font(.subheadline)
					
				}
			} else {
				List(filteredTasks, id: \.firestoreID) { task in
					HStack {
						Image(systemName: "checkmark.circle.fill").foregroundColor(.green)
						Text(task.title).strikethrough(true, color: .gray)
						Spacer()
					}
				}
			}
		}
		.searchable(text: $searchQuery, prompt: "Search")
	}
}


// Preview Code for Xcode

extension ContentViewModel {
	static var mock: ContentViewModel {
		let mockViewModel = ContentViewModel()
		// Populate the mockViewModel with some sample data
		mockViewModel.tasks = [
			Task(id: UUID(), title: "Completed Task 1", isComplete: true),
			Task(id: UUID(), title: "Completed Task 2", isComplete: true),
		]
		return mockViewModel
	}
}

struct CompletedTaskView_Previews: PreviewProvider {
	static var previews: some View {
		CompletedTaskView(
			viewModel: .mock,
			searchQuery: .constant(""),
			isCurrentlySelected: .constant(true)
		)
	}
}
