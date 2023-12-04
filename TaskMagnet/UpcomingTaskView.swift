//
//  UpcomingTaskView.swift
//  TaskMagnet
//
//  Created by Armin Halilovic on 03.12.2023.
//

import SwiftUI

struct UpcomingTaskView: View {
	@ObservedObject var viewModel: ContentViewModel
	
	private static let dateFormatter: DateFormatter = {
		let formatter = DateFormatter()
		formatter.dateStyle = .medium
		formatter.timeStyle = .none
		return formatter
	}()
	
	private var upcomingTasks: [Task] {
		let today = Calendar.current.startOfDay(for: Date())
		let calendar = Calendar.current
		
		return viewModel.tasks.filter { task in
			guard let dueDate = task.dueDate else { return false }
			let isToday = calendar.isDate(dueDate, inSameDayAs: today)
			let isFuture = dueDate > today
			return isFuture && !isToday
		}
	}
	
	
	var body: some View {
		NavigationView {
			List(upcomingTasks, id: \.firestoreID) { task in
				HStack {
					Text(task.title)
					Spacer()
					if let dueDate = task.dueDate {
						Text(Self.dateFormatter.string(from: dueDate))
							.foregroundColor(.gray)
					}
				}
			}
			.navigationTitle("Upcoming Tasks")
		}
	}
}


struct UpcomingTaskView_Previews: PreviewProvider {
	static var previews: some View {
		UpcomingTaskView(viewModel: ContentViewModel())
	}
}

