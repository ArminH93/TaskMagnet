//
//  DataService.swift
//  TaskMagnet
//
//  Created by Armin Halilovic on 02.12.2023.
//

import Foundation
import Firebase
import FirebaseFirestore

class DataService {
	static let shared = DataService()
	private let db = Firestore.firestore()
	
	private init() {}
	
	func fetchTasks(for userID: String, completion: @escaping ([Task]?, Error?) -> Void) {
		db.collection("users").document(userID).collection("tasks")
			.addSnapshotListener { querySnapshot, error in
				if let error = error {
					completion(nil, error)
				} else {
					let tasks = querySnapshot?.documents.compactMap { document in
						var task = try? document.data(as: Task.self)
						task?.firestoreID = document.documentID
						return task
					}
					completion(tasks, nil)
				}
			}
	}
	
	func addTask(_ task: Task, for userID: String, completion: (() -> Void)? = nil) {
		let db = Firestore.firestore()
		var ref: DocumentReference? = nil
		ref = db.collection("users").document(userID).collection("tasks").addDocument(data: [
			"title": task.title,
			"isComplete": task.isComplete,
			"dueDate": task.dueDate ?? NSNull()
		]) { err in
			if let err = err {
				print("Error adding task: \(err)")
			} else if let documentID = ref?.documentID {
				print("Task added with ID: \(documentID)")
				completion?()
			}
		}
	
	}
	
	// Frontend code to delete a task from the List
	func deleteTask(at offsets: IndexSet, from tasks: [Task], for userID: String, completion: @escaping (Error?) -> Void) {
		for index in offsets {
			let task = tasks[index]
			if let firestoreID = task.firestoreID {
				deleteTask(with: firestoreID, for: userID) { error in
					completion(error)
				}
			}
		}
	}
	
	// Backend code to delete a task from Firestore
	func deleteTask(with firestoreID: String, for userID: String, completion: @escaping (Error?) -> Void) {
		db.collection("users").document(userID).collection("tasks").document(firestoreID).delete { error in
			completion(error)
		}
	}
	
	func markTaskAsComplete(for task: Task, completion: @escaping () -> Void) {
		guard let userID = Auth.auth().currentUser?.uid, let firestoreID = task.firestoreID else { return }
		
		let db = Firestore.firestore()
		db.collection("users").document(userID).collection("tasks").document(firestoreID).updateData(["isComplete": true]) { error in
			if let error = error {
				print("Error updating task: \(error)")
			} else {
				// No action needed
			}
		}
		completion()
	}
}

class DateFormatting {
	static let taskDateFormat: DateFormatter = {
		let formatter = DateFormatter()
		formatter.dateStyle = .medium
		formatter.timeStyle = .none
		return formatter
	}()
}
